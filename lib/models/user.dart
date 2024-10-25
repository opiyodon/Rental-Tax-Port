class User {
  String uid;
  String name;
  String email;
  String role; // landlord, tenant, agent, admin
  String kraPin;

  User({required this.uid, required this.name, required this.email, required this.role, required this.kraPin});

  factory User.fromMap(Map data) {
    return User(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      role: data['role'],
      kraPin: data['kraPin'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'kraPin': kraPin,
    };
  }
}