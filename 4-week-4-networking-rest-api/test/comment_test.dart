import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  // Verifies that omitted API fields receive safe defaults.
  test('Comment.fromJson aman terhadap field yang hilang', () {
    final comment = Comment.fromJson({'id': 7});

    expect(comment.postId, 0);
    expect(comment.id, 7);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
