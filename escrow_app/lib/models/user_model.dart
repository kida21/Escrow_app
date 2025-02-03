class AppUser {
  final String id;
  final String email;
  final String name;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
  });
   @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AppUser &&
            runtimeType == other.runtimeType &&
            id == other.id);
  }
   @override
  int get hashCode => id.hashCode;

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
    };
  }
}
