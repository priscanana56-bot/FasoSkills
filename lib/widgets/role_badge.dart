import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Badge indiquant le rôle choisi (lecture seule, sans re-sélection).
class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  bool get _isArtisan => role == 'artisan';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryTint(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isArtisan ? Icons.construction : Icons.person,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            _isArtisan ? 'Compte Artisan' : 'Compte Client',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
