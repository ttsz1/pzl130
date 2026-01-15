class Topic {
  final String id;
  final String title;
  final String? description;
  final String? fileUrl;

  Topic({
    required this.id,
    required this.title,
    this.description,
    this.fileUrl,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      fileUrl: json['file_url'],
    );
  }
}
