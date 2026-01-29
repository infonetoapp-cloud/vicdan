class JourneyItem {

  const JourneyItem({
    required this.day,
    required this.title,
    required this.content,
    required this.action,
    this.isCompleted = false,
    this.isLocked = true,
  });
  final int day;
  final String title;
  final String content;
  final String action; // Micro-action for the day
  final bool isCompleted;
  final bool isLocked;

  JourneyItem copyWith({
    bool? isCompleted,
    bool? isLocked,
  }) {
    return JourneyItem(
      day: day,
      title: title,
      content: content,
      action: action,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
