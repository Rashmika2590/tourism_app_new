class User {
  final String uid;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;
  final bool isVerified;
  final DateTime createdTime;
  final DateTime updatedTime;
  final String updatedBy;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.role = 'user',
    this.isVerified = false,
    required this.createdTime,
    required this.updatedTime,
    required this.updatedBy,
  });

  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String? ?? 'user',
      isVerified: json['is_verified'] as bool? ?? false,
      createdTime: DateTime.parse(json['created_time'] as String),
      updatedTime: DateTime.parse(json['updated_time'] as String),
      updatedBy: json['updated_by'] as String,
    );
  }

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'is_verified': isVerified,
      'created_time': createdTime.toIso8601String(),
      'updated_time': updatedTime.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  // Method to create JSON for API request (without sensitive fields for responses)
  Map<String, dynamic> toCreateUserJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'is_verified': isVerified,
      'created_time': createdTime.toIso8601String(),
      'updated_time': updatedTime.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  // Copy with method for easy updates
  User copyWith({
    String? uid,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? role,
    bool? isVerified,
    DateTime? createdTime,
    DateTime? updatedTime,
    String? updatedBy,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdTime: createdTime ?? this.createdTime,
      updatedTime: updatedTime ?? this.updatedTime,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  String toString() {
    return 'User{uid: $uid, name: $name, email: $email, role: $role, isVerified: $isVerified}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
