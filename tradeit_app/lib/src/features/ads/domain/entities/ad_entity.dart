class AdEntity {
  final String id;
  final String title;
  final String titleLowercase;
  final String description;
  final String category;
  final String condition;
  final String? imageUrl;
  final List<String> imageUrls;
  final String ownerId;
  final DateTime createdAt;
  final String userName;
  final String? location;
  final String status;

  AdEntity({
    required this.id,
    required this.title,
    required this.titleLowercase,
    required this.description,
    required this.category,
    required this.condition,
    this.imageUrl,
    required this.imageUrls,
    required this.ownerId,
    required this.createdAt,
    required this.userName,
    this.location,
    required this.status,
  });

  factory AdEntity.fromMap(Map<String, dynamic> map, String id) {
    return AdEntity(
      id: id,
      title: map['title'] ?? '',
      titleLowercase: map['titleLowercase'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      condition: map['condition'] ?? '',
      imageUrl: map['imageUrl'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      ownerId: map['ownerId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      userName: map['userName'] ?? '',
      location: map['location'],
      status: map['status']?.toString().toLowerCase().trim() ?? 'ativo',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'titleLowercase': titleLowercase,
      'description': description,
      'category': category,
      'condition': condition,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'userName': userName,
      'location': location,
      'status': status,
    };
  }
}