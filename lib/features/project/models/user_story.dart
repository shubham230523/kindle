class UserStory {
  final String id;
  final String actor;
  final String action;
  final String benefit;

  const UserStory({
    required this.id,
    required this.actor,
    required this.action,
    required this.benefit,
  });

  String get fullText => 'As a $actor, I want to $action so that $benefit.';

  UserStory copyWith({
    String? id,
    String? actor,
    String? action,
    String? benefit,
  }) {
    return UserStory(
      id: id ?? this.id,
      actor: actor ?? this.actor,
      action: action ?? this.action,
      benefit: benefit ?? this.benefit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actor': actor,
      'action': action,
      'benefit': benefit,
    };
  }

  factory UserStory.fromMap(Map<String, dynamic> map) {
    return UserStory(
      id: map['id'] ?? '',
      actor: map['actor'] ?? '',
      action: map['action'] ?? '',
      benefit: map['benefit'] ?? '',
    );
  }
}
