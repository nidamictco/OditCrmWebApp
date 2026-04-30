class UserModel {
  final String id;
  final String? name;
  final String email;
  final String? role;
  final String password;

  const UserModel({
    required this.id,
     this.name,
    required this.email,
    this.role,
    required this.password,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: map['STAFF_ID'] as String,
      name: map['NAME'] as String?,
      email: map['EMAIL'] as String ,
      role: map['ROLE'] as String?,
      password: map['PASSWORD'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'NAME': name,
     'EMAIL': email,
      if (role != null) 'ROLE': role,
       'PASSWORD': password,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      password: password ?? this.password,
    );
  }

  @override
  String toString() => 'UserModel(uid: $id, name: $name, role: $role)';
}