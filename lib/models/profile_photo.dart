class ProfilePhoto {
  final String id;
  final String userId;
  final String url;
  final int sortOrder;
  final DateTime createdAt;

  ProfilePhoto({
    required this.id,
    required this.userId,
    required this.url,
    required this.sortOrder,
    required this.createdAt,
  });

  factory ProfilePhoto.fromJson(Map<String, dynamic> json) {
    // Handle null values safely with defaults
    final id = json['id'];
    final userId = json['user_id'];
    final url = json['url'];
    final sortOrder = json['sort_order'];
    final createdAt = json['created_at'];

    return ProfilePhoto(
      id: id is String ? id : (id?.toString() ?? ''),
      userId: userId is String ? userId : (userId?.toString() ?? ''),
      url: url is String ? url : (url?.toString() ?? ''),
      sortOrder: sortOrder is int ? sortOrder : (sortOrder is num ? sortOrder.toInt() : 0),
      createdAt: createdAt is String
          ? DateTime.parse(createdAt)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'url': url,
        'sort_order': sortOrder,
        'created_at': createdAt.toIso8601String(),
      };
}
