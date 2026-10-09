class AppUser {
  const AppUser({required this.id, required this.fullName, required this.email});
  final String id;
  final String fullName;
  final String email;

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
    id: map['id'] as String,
    fullName: map['full_name'] as String,
    email: map['email'] as String,
  );
}