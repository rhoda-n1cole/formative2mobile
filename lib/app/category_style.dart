import 'package:flutter/material.dart';

/// Icon for each category in AppConstants.categories.
IconData categoryIcon(String category) {
  switch (category) {
    case 'Broken facility':
      return Icons.apartment_rounded;
    case 'Water shortage':
      return Icons.water_drop_outlined;
    case 'Electricity outage':
      return Icons.bolt_rounded;
    case 'Damaged furniture':
      return Icons.chair_outlined;
    case 'Sanitation':
      return Icons.cleaning_services_outlined;
    case 'Safety concern':
      return Icons.shield_outlined;
    default:
      return Icons.more_horiz_rounded;
  }
}
