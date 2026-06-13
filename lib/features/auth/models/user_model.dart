class UserModel {
  final int id;
  final String username;
  final String email;
  final String? photo;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.photo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var photoUrl = json['photo'] as String?;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (!photoUrl.startsWith('http://') && !photoUrl.startsWith('https://')) {
        photoUrl = "https://quran-app-backend-8b57.onrender.com${photoUrl.startsWith('/') ? photoUrl : '/$photoUrl'}";
      }
    }
    if (photoUrl != null &&
        photoUrl.contains('ui-avatars.com') &&
        !photoUrl.contains('format=png')) {
      photoUrl = photoUrl.contains('?')
          ? '$photoUrl&format=png'
          : '$photoUrl?format=png';
    }
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      photo: photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'email': email, 'photo': photo};
  }
}
