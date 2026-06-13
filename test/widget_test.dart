import 'package:flutter_test/flutter_test.dart';
import 'package:qari24_7/features/auth/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('should serialize to and from JSON correctly', () {
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'testuser@example.com',
        'photo': 'https://example.com/photo.jpg',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.email, 'testuser@example.com');
      expect(user.photo, 'https://example.com/photo.jpg');

      final serialized = user.toJson();
      expect(serialized['id'], 1);
      expect(serialized['username'], 'testuser');
      expect(serialized['email'], 'testuser@example.com');
      expect(serialized['photo'], 'https://example.com/photo.jpg');
    });
  });
}

