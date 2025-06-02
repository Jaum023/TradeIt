class AdEntity {
  final String id;
  final String title;
  final String titleLowercase;
  final String description;
  final String category;
  final String condition;
  final String? imageUrl;
  final String ownerId;
  final DateTime createdAt;
  final String userName;

  AdEntity({
    required this.id,
    required this.title,
    required this.titleLowercase,
    required this.description,
    required this.category,
    required this.condition,
    required this.ownerId,
    required this.createdAt,
    this.imageUrl,
    required this.userName,
  });
}