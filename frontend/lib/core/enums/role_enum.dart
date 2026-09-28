/// UserRole defines the platform access roles.
enum UserRole {
  student('STUDENT', 'Student'),
  admin('ADMIN', 'Admin'),
  institute('INSTITUTE', 'Institute');

  final String value;
  final String label;

  const UserRole(this.value, this.label);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value.toUpperCase() == value.toUpperCase(),
      orElse: () => UserRole.student,
    );
  }
}
