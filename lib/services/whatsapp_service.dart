import 'package:url_launcher/url_launcher.dart';
import '../models/reservation.dart';

class WhatsAppService {
  /// Envoyer notification de confirmation
  static Future<bool> sendConfirmationMessage({
    required String phoneNumber,
    required Reservation reservation,
  }) async {
    final message = _buildConfirmationMessage(reservation);
    return _sendMessage(phoneNumber, message);
  }

  /// Envoyer notification de proposition
  static Future<bool> sendProposalMessage({
    required String phoneNumber,
    required Reservation reservation,
  }) async {
    final message = _buildProposalMessage(reservation);
    return _sendMessage(phoneNumber, message);
  }

  /// Envoyer notification de refus
  static Future<bool> sendRejectionMessage({
    required String phoneNumber,
    required Reservation reservation,
    String? reason,
  }) async {
    final message = _buildRejectionMessage(reservation, reason);
    return _sendMessage(phoneNumber, message);
  }
  /// Envoyer demande d'avis après fin de séance
static Future<bool> sendFeedbackRequestMessage({
  required String phoneNumber,
  required String userName,
  required String stageName,
}) async {
  final message = _buildFeedbackMessage(userName, stageName);
  return _sendMessage(phoneNumber, message);
}

  /// Message de confirmation
  static String _buildConfirmationMessage(Reservation reservation) {
    return '''
✅ *Réservation Confirmée - DjerbaKite*

Bonjour ${reservation.userName},

Votre réservation a été confirmée ! 🎉

📅 *Date:* ${reservation.dateConfirmee!.day}/${reservation.dateConfirmee!.month}/${reservation.dateConfirmee!.year}
🕒 *Heure:* ${reservation.heureConfirmee}
🪁 *Stage:* ${reservation.stageName}
💰 *Prix:* ${reservation.prixFinal.toStringAsFixed(0)} TND

À bientôt sur la plage ! 🏖️
''';
  }

  /// Message de proposition
  static String _buildProposalMessage(Reservation reservation) {
    return '''
📅 *Nouvelle Proposition - DjerbaKite*

Bonjour ${reservation.userName},

Nous vous proposons une nouvelle date pour votre stage:

📅 *Date proposée:* ${reservation.dateConfirmee!.day}/${reservation.dateConfirmee!.month}/${reservation.dateConfirmee!.year}
🕒 *Heure proposée:* ${reservation.heureConfirmee}
🪁 *Stage:* ${reservation.stageName}

${reservation.notesAdmin != null ? '\n📝 *Note:* ${reservation.notesAdmin}\n' : ''}
Merci de confirmer votre disponibilité dans l\'application.
''';
  }

  /// Message de refus
  static String _buildRejectionMessage(Reservation reservation, String? reason) {
    return '''
❌ *Réservation Refusée - DjerbaKite*

Bonjour ${reservation.userName},

Nous sommes désolés, nous ne pouvons pas accepter votre demande de réservation.

🪁 *Stage:* ${reservation.stageName}
📅 *Date demandée:* ${reservation.dateDemande.day}/${reservation.dateDemande.month}/${reservation.dateDemande.year}

${reason != null && reason.isNotEmpty ? '📝 *Raison:* $reason\n' : ''}
N\'hésitez pas à nous contacter pour d\'autres dates disponibles.
''';
  }

  /// Envoyer message WhatsApp
  static Future<bool> _sendMessage(String phoneNumber, String message) async {
    try {
      // Nettoyer le numéro (enlever espaces, tirets, etc.)
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Ajouter code pays si manquant (Tunisie = +216)
      if (!cleanPhone.startsWith('+')) {
        if (cleanPhone.startsWith('00')) {
          cleanPhone = '+${cleanPhone.substring(2)}';
        } else if (cleanPhone.length == 8) {
          cleanPhone = '+216$cleanPhone';
        }
      }

      // Encoder le message pour URL
      final encodedMessage = Uri.encodeComponent(message);
      
      // URL WhatsApp (utilise "wa.me" au lieu de "whatsapp://")
      final url = 'https://wa.me/$cleanPhone?text=$encodedMessage';
      
      print('🔵 WHATSAPP: Ouverture URL: $url');
      
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ WHATSAPP: Message pré-rempli');
        return true;
      } else {
        print('❌ WHATSAPP: Impossible d\'ouvrir WhatsApp');
        return false;
      }
    } catch (e) {
      print('❌ WHATSAPP ERROR: $e');
      return false;
    }
  }
  static String _buildFeedbackMessage(String userName, String stageName) {
  return '''
🌊 *Merci ${userName} !*

Votre stage "$stageName" est terminé ! Nous espérons que vous avez passé un excellent moment avec DjerbaKite 🪁

📝 *Votre avis compte beaucoup pour nous !*

Merci de partager votre expérience :

👍 Laissez-nous un avis sur Facebook : 
https://www.facebook.com/DjerbaKite/reviews

À très bientôt sur les vagues ! 🏄‍♂️
''';
}
}