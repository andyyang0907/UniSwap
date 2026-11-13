class UniUser {
  final String id;
  final String name;
  final String? avatar;
  final String campus;
  final String bio;
  final int rating;
  final int completedTrades;

  const UniUser({
    required this.id,
    required this.name,
    this.avatar,
    this.campus = '呈贡校区',
    this.bio = '校园里的闲置好物猎手 🌿',
    this.rating = 5,
    this.completedTrades = 0,
  });

  UniUser copyWith({
    String? name,
    String? avatar,
    String? campus,
    String? bio,
    int? rating,
    int? completedTrades,
  }) {
    return UniUser(
      id: id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      campus: campus ?? this.campus,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      completedTrades: completedTrades ?? this.completedTrades,
    );
  }

  static const UniUser demo = UniUser(
    id: 'me_demo',
    name: '同学阿绿',
    campus: '呈贡校区',
    bio: '让每一件闲置找到新主人 🌱',
    rating: 5,
    completedTrades: 12,
  );
}
