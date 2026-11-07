class AppConstants {
  // Change these to the real ALU domains.
  static const List<String> allowedEmailDomains = [
    'alustudent.com',
    'alueducation.com',
  ];

  static const List<String> categories = [
    'Broken facility',
    'Water shortage',
    'Electricity outage',
    'Damaged furniture',
    'Sanitation',
    'Safety concern',
    'Other',
  ];

  static const List<String> statuses = [
    'Submitted',
    'In Review',
    'In Progress',
    'Resolved',
  ];
}

class UserRole {
  static const String student = 'student';
  static const String staff = 'staff';
}
