/// Model class for achievements
class Achievement {
  final int id;
  final String key;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final String? unlockedDate;
  final int progress;
  final int target;

  Achievement({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedDate,
    required this.progress,
    required this.target,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked': unlocked ? 1 : 0,
      'unlockedDate': unlockedDate,
      'progress': progress,
      'target': target,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int,
      key: map['key'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
      unlocked: (map['unlocked'] as int) == 1,
      unlockedDate: map['unlockedDate'] as String?,
      progress: map['progress'] as int,
      target: map['target'] as int,
    );
  }

  Achievement copyWith({
    int? id,
    String? key,
    String? title,
    String? description,
    String? icon,
    bool? unlocked,
    String? unlockedDate,
    int? progress,
    int? target,
  }) {
    return Achievement(
      id: id ?? this.id,
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  double get progressPercentage {
    if (target == 0) return 0.0;
    return (progress / target) * 100;
  }
}
