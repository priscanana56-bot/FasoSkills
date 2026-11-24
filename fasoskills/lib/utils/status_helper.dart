import 'package:flutter/material.dart';
import '../theme/theme.dart';

class StatusHelper {
  StatusHelper._();

  static String label(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Acceptée';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      case 'rejected':
        return 'Rejetée';
      default:
        return status;
    }
  }

  static Color requestColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.statusPending;
      case 'accepted':
      case 'in_progress':
        return AppTheme.statusAccepted;
      case 'completed':
        return AppTheme.statusCompleted;
      case 'cancelled':
      case 'rejected':
        return AppTheme.statusUnavailable;
      default:
        return AppTheme.textSecondary;
    }
  }

  static Color quoteColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.statusPending;
      case 'accepted':
        return AppTheme.statusAccepted;
      case 'rejected':
        return AppTheme.destructiveColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}
