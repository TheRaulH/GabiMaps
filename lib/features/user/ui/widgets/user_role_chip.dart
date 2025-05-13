import 'package:flutter/material.dart';

class UserRoleChip extends StatelessWidget {
  final String role;

  const UserRoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (chipColor, chipLabel, chipIcon) = _getRoleProperties(
      role,
      colorScheme,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(
            chipLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String, IconData) _getRoleProperties(
    String role,
    ColorScheme colorScheme,
  ) {
    switch (role.toLowerCase()) {
      case 'admin':
        return (colorScheme.error, 'Admin', Icons.admin_panel_settings);
      case 'entrepreneur':
        return (Colors.amber.shade700, 'Emprendedor', Icons.trending_up);
      case 'institutional':
        return (Colors.green.shade700, 'Institucional', Icons.business);
      default:
        return (colorScheme.primary, 'Usuario', Icons.person);
    }
  }
}
