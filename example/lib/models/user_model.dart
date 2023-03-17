class UserModel {
  UserModel({
    this.firstName,
    this.lastName,
  });

  final String? firstName;
  final String? lastName;

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
