/// Categories for Vicdan tasks
enum TaskCategory {
  ibadet, // Worship (e.g., Namaz, Zikir)
  iyilik, // Goodness (e.g., Sadaka, Smile)
  zihin, // Mind (e.g., Sukur, Tefekkur)
}

extension TaskCategoryExtension on TaskCategory {
  String get displayName {
    switch (this) {
      case TaskCategory.ibadet:
        return 'İbadet';
      case TaskCategory.iyilik:
        return 'İyilik';
      case TaskCategory.zihin:
        return 'Zihin';
    }
  }
}
