// lib/services/local_auth_service.dart
class LocalAuthService {
  // Base de données en mémoire (sera remplacée par Firestore plus tard)
  static final Map<String, Map<String, dynamic>> _users = {
    'test@djerbakite.com': {
      'password': 'test1234',
      'role': 'client',
      'nom': 'Test',
      'prenom': 'User',
      'telephone': '12345678',
    },
    'admin@djerbakite.com': {
      'password': 'admin1234',
      'role': 'admin',
      'nom': 'Admin',
      'prenom': 'DjerbaKite',
      'telephone': '99999999',
    },
  };

  static String? _currentUserEmail;

  // Connexion
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 800)); // Simule latence réseau
    
    if (!_users.containsKey(email)) {
      throw Exception('Aucun utilisateur trouvé avec cet email');
    }
    
    if (_users[email]!['password'] != password) {
      throw Exception('Mot de passe incorrect');
    }
    
    _currentUserEmail = email;
    return {
      'email': email,
      ..._users[email]!,
    };
  }

  // Inscription
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    if (_users.containsKey(email)) {
      throw Exception('Cet email est déjà utilisé');
    }
    
    if (password.length < 8) {
      throw Exception('Le mot de passe doit contenir au moins 8 caractères');
    }
    
    // Ajoute le nouvel utilisateur
    _users[email] = {
      'password': password,
      'role': 'client', // Par défaut, tous les nouveaux users sont clients
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
    };
    
    _currentUserEmail = email;
    
    return {
      'email': email,
      ..._users[email]!,
    };
  }

  // Déconnexion
  Future<void> signOut() async {
    _currentUserEmail = null;
  }

  // Récupère l'utilisateur courant
  Map<String, dynamic>? getCurrentUser() {
    if (_currentUserEmail == null) return null;
    
    return {
      'email': _currentUserEmail,
      ..._users[_currentUserEmail]!,
    };
  }

  // Vérifie si connecté
  bool isLoggedIn() => _currentUserEmail != null;

  // Récupère le rôle
  String? getUserRole() {
    if (_currentUserEmail == null) return null;
    return _users[_currentUserEmail]!['role'];
  }
}