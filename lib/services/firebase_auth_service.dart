import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// INSCRIPTION
// INSCRIPTION
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    try {
      print('🔵 REGISTER: Inscription $email...');
      
      // 1. Créer dans Firebase Auth D'ABORD
      User? firebaseUser;
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        firebaseUser = userCredential.user;
        print('✅ REGISTER: Compte Auth créé');
      } catch (e) {
        print('⚠️ Auth: Erreur (bug Pigeon): $e');
        // Récupérer l'user malgré l'erreur Pigeon
        await Future.delayed(Duration(milliseconds: 500));
        firebaseUser = _auth.currentUser;
        if (firebaseUser == null) {
          throw Exception('Erreur création compte Auth');
        }
      }

      // 2. Utiliser l'UID de Firebase Auth pour Firestore
      final uid = firebaseUser!.uid;
      print('🔵 REGISTER: UID Firebase = $uid');
      
      Map<String, dynamic> userData = {
        'email': email,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'role': 'client',
        'created_at': FieldValue.serverTimestamp(),
      };

      // 3. Créer le document Firestore avec le BON UID
      await _firestore.collection('users').doc(uid).set(userData);
      print('✅ REGISTER: Document Firestore créé avec UID $uid');

      return {'uid': uid, ...userData};
    } catch (e) {
      print('❌ REGISTER ERROR: $e');
      throw Exception('Erreur inscription: $e');
    }
  }

  // CONNEXION - WORKAROUND COMPLET
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Récupérer user depuis Firestore
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('Email ou mot de passe incorrect');
      }

      // 2. Valider password avec Firebase Auth (ignorer erreur de cast)
      bool passwordValid = false;
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        passwordValid = true;
      } catch (authError) {
        // Si erreur contient "Pigeon" ou "List<Object>" = bug de cast
        String errorStr = authError.toString();
        if (errorStr.contains('PigeonUserDetails') || 
            errorStr.contains('List<Object') ||
            errorStr.contains('type cast')) {
          // C'est le bug connu, password est validé
          passwordValid = true;
          print('✅ Auth réussie malgré bug Pigeon');
        } else if (authError is FirebaseAuthException) {
          // Vraie erreur d'authentification
          if (authError.code == 'wrong-password' || 
              authError.code == 'invalid-credential' ||
              authError.code == 'user-not-found') {
            throw Exception('Email ou mot de passe incorrect');
          }
          throw Exception('Erreur: ${authError.message}');
        } else {
          throw authError;
        }
      }

      if (!passwordValid) {
        throw Exception('Email ou mot de passe incorrect');
      }

      // 3. Retourner données Firestore
      Map<String, dynamic> userData = userQuery.docs.first.data() as Map<String, dynamic>;
      String uid = userQuery.docs.first.id;

      print('✅ Connexion réussie: ${userData['email']} (${userData['role']})');
      return {'uid': uid, ...userData};
      
    } catch (e) {
      if (e.toString().contains('Email ou mot de passe')) {
        rethrow;
      }
      throw Exception('Erreur connexion: $e');
    }
  }

  // DÉCONNEXION
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('⚠️ Erreur signOut ignorée: $e');
    }
  }

  // RÉCUPÉRER USER ACTUEL
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      // Chercher par email dans Firestore (plus fiable)
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) return null;
      
      Map<String, dynamic> userData = query.docs.first.data() as Map<String, dynamic>;
      return {'uid': query.docs.first.id, ...userData};
    } catch (e) {
      print('⚠️ Erreur getCurrentUser: $e');
      return null;
    }
  }

  // VÉRIFIE SI CONNECTÉ
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // RÉCUPÈRE LE RÔLE
  Future<String?> getUserRole() async {
    try {
      Map<String, dynamic>? user = await getCurrentUser();
      return user?['role'];
    } catch (e) {
      return null;
    }
  }
}