import 'package:flutter/material.dart';
import '../../../models/reservation.dart';
import '../../../services/firebase_reservation_service.dart';
import '../../../services/whatsapp_service.dart';

class EndSessionButton extends StatefulWidget {
  final Reservation reservation;

  const EndSessionButton({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  @override
  _EndSessionButtonState createState() => _EndSessionButtonState();
}

class _EndSessionButtonState extends State<EndSessionButton> {
  bool _isLoading = false;

  Future<void> _handleEndSession(BuildContext context) async {
    // Validation préalable
    if (widget.reservation.isTerminee) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ce stage est déjà terminé'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Dialog de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Confirmation de fin de stage',
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.05, // Taille adaptative
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voulez-vous vraiment marquer ce stage comme terminé ?',
                      style: TextStyle(
                        fontSize: constraints.maxWidth * 0.04,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Stage: ${widget.reservation.stageName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: constraints.maxWidth * 0.035,
                      ),
                    ),
                    Text(
                      'Client: ${widget.reservation.userName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: constraints.maxWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.035,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  'Confirmer',
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.035,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Reste du code inchangé
    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final reservationService = FirebaseReservationService();
      
      await reservationService.markAsCompleted(widget.reservation.id);

      await WhatsAppService.sendFeedbackRequestMessage(
        phoneNumber: widget.reservation.userPhone,
        userName: widget.reservation.userName,
        stageName: widget.reservation.stageName,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stage marqué comme terminé'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _handleEndSession(context),
            icon: _isLoading 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)
                )
              : Icon(Icons.check_circle, size: 20),
            label: Text(
              _isLoading ? 'En cours...' : 'Marquer comme terminée',
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.04,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
          ),
        );
      },
    );
  }
}