class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  Map<String, Object?> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
      };

  factory Post.fromJson(Map<String, Object?> json) => Post(
        id: (json['id'] as num).toInt(),
        userId: (json['userId'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );
}