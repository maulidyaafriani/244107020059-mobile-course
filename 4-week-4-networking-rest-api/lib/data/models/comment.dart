/// Represents one comment returned by JSONPlaceholder.
class Comment {
  /// Creates an immutable comment value.
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  /// The id of the post that owns this comment.
  final int postId;

  /// The unique id of this comment.
  final int id;

  /// The comment author's display name.
  final String name;

  /// The comment author's email address.
  final String email;

  /// The comment text.
  final String body;

  /// Builds a comment safely, using empty/default values for missing fields.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  /// Converts this comment back into the API field format.
  Map<String, dynamic> toJson() => {
    'postId': postId,
    'id': id,
    'name': name,
    'email': email,
    'body': body,
  };
}
