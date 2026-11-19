class User {
  const User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  final int id;
  final String username;
  final String fullName;
  final String role;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'role': role,
      };

  String get initials {
    final words = fullName.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    if (words.isEmpty) {
      return username.isEmpty ? '?' : username.substring(0, 1).toUpperCase();
    }
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return (words.first.substring(0, 1) + words.last.substring(0, 1)).toUpperCase();
  }

  String get roleLabel => role
      .split('_')
      .map((part) => part.isEmpty ? part : part[0] + part.substring(1).toLowerCase())
      .join(' ');
}
