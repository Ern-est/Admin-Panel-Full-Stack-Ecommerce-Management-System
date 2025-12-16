class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String role;
  final String status;

  AppUser({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    required this.status,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      fullName: map['full_name'],
      role: map['role'],
      status: map['status'],
    );
  }
}
