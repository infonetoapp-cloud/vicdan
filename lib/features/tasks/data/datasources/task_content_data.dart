import '../../domain/entities/task_category.dart';

class TaskBlueprint {
  final String title;
  final String description;
  final TaskCategory category;
  final int xpValue;
  final int startHour;

  const TaskBlueprint({
    required this.title,
    required this.description,
    required this.category,
    required this.xpValue,
    required this.startHour,
  });
}

class TaskContentData {
  static List<TaskBlueprint> getTasksForDay(int dayIndex) {
    // dayIndex is 0-29. Cycle if larger.
    final index = dayIndex % 30;

    // If we haven't defined this specific day yet, return a generated set
    if (!_thirtyDayJourney.containsKey(index)) {
      return _generateFallbackTasks(index);
    }
    return _thirtyDayJourney[index] ?? _defaultTasks;
  }

  static List<TaskBlueprint> _generateFallbackTasks(int index) {
    return [
      TaskBlueprint(
          title: 'Günün Başlangıcı',
          description: 'Bugünü Allah rızası için yaşa.',
          category: TaskCategory.ibadet,
          xpValue: 33,
          startHour: 5),
      TaskBlueprint(
          title: 'İyilik Vakti',
          description: 'Çevrene bir güzellik kat.',
          category: TaskCategory.iyilik,
          xpValue: 33,
          startHour: 12),
      TaskBlueprint(
          title: 'Günün Sonu',
          description: 'Bugün neler yaptın? Düşün.',
          category: TaskCategory.zihin,
          xpValue: 34,
          startHour: 17),
    ];
  }

  static const List<TaskBlueprint> _defaultTasks = [
    TaskBlueprint(
      title: 'Güne Bismillah',
      description: 'Yeni güne Niyet ve Şükür ile başla.',
      category: TaskCategory.ibadet,
      xpValue: 33,
      startHour: 5,
    ),
    TaskBlueprint(
      title: 'Tebessüm Et',
      description: 'Karşılaştığın birine gülümse.',
      category: TaskCategory.iyilik,
      xpValue: 33,
      startHour: 12,
    ),
    TaskBlueprint(
      title: 'Gün Sonu Muhasebesi',
      description: 'Bugün vicdanın rahat mı?',
      category: TaskCategory.zihin,
      xpValue: 34,
      startHour: 17,
    ),
  ];

  static final Map<int, List<TaskBlueprint>> _thirtyDayJourney = {
    0: [
      // Day 1
      const TaskBlueprint(
          title: 'Güne Bismillah',
          description: 'Yeni güne Rabbini anarak başla.',
          category: TaskCategory.ibadet,
          xpValue: 33,
          startHour: 5),
      const TaskBlueprint(
          title: 'Tebessüm Et',
          description: 'Gülümsemek en kolay sadakadır.',
          category: TaskCategory.iyilik,
          xpValue: 33,
          startHour: 12),
      const TaskBlueprint(
          title: 'Günün Muhasebesi',
          description: 'Bugün kalbini kırdığın biri oldu mu?',
          category: TaskCategory.zihin,
          xpValue: 34,
          startHour: 17),
    ],
    1: [
      // Day 2
      const TaskBlueprint(
          title: 'Sabahın Huzuru',
          description: 'Güneş doğmadan uyanmanın bereketini hisset.',
          category: TaskCategory.ibadet,
          xpValue: 33,
          startHour: 5),
      const TaskBlueprint(
          title: 'Birini Ara',
          description: 'Uzun zamandır konuşmadığın bir dostunu hatırla.',
          category: TaskCategory.iyilik,
          xpValue: 33,
          startHour: 12),
      const TaskBlueprint(
          title: 'Öfke Kontrolü',
          description: 'Bugün seni kızdıran bir şeyi affet.',
          category: TaskCategory.zihin,
          xpValue: 34,
          startHour: 17),
    ],
    2: [
      // Day 3
      const TaskBlueprint(
          title: 'Şükür Notu',
          description: 'Sahip olduğun 3 nimet için şükret.',
          category: TaskCategory.zihin,
          xpValue: 33,
          startHour: 5),
      const TaskBlueprint(
          title: 'Su İkramı',
          description: 'Bir canlıya (insan, kedi, kuş) su ver.',
          category: TaskCategory.iyilik,
          xpValue: 33,
          startHour: 12),
      const TaskBlueprint(
          title: 'Kuran Vakti',
          description: 'Ruhunu dinlendirmek için biraz Kuran dinle.',
          category: TaskCategory.ibadet,
          xpValue: 34,
          startHour: 17),
    ],
    3: [
      // Day 4
      const TaskBlueprint(
          title: 'Niyet Tazele',
          description: 'Tüm işlerini ibadet niyetiyle yap.',
          category: TaskCategory.ibadet,
          xpValue: 33,
          startHour: 5),
      const TaskBlueprint(
          title: 'Yolu Temizle',
          description: 'Yoldaki bir engeli veya çöpü kaldır.',
          category: TaskCategory.iyilik,
          xpValue: 33,
          startHour: 12),
      const TaskBlueprint(
          title: 'Aile Zamanı',
          description: 'Ailenle kaliteli vakit geçir.',
          category: TaskCategory.iyilik,
          xpValue: 34,
          startHour: 17),
    ],
    4: [
      // Day 5
      const TaskBlueprint(
          title: 'Erken Kalk',
          description: 'Günün en verimli saatlerini kaçırma.',
          category: TaskCategory.zihin,
          xpValue: 33,
          startHour: 5),
      const TaskBlueprint(
          title: 'Sadaka Ver',
          description: 'Az da olsa bugün bir sadaka ver.',
          category: TaskCategory.iyilik,
          xpValue: 33,
          startHour: 12),
      const TaskBlueprint(
          title: 'Tefekkür',
          description: 'Gökyüzüne bak ve yaratılışı düşün.',
          category: TaskCategory.ibadet,
          xpValue: 34,
          startHour: 17),
    ],
    // I can stick to 5 days for the verification, and add more later.
  };
}
