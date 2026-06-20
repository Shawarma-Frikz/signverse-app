enum SignCategory {
  alphabet,
  greetings,
  numbers,
  colors,
  family,
  emotions,
  food,
  common,
}

extension SignCategoryX on SignCategory {
  String get label => switch (this) {
    SignCategory.alphabet => 'Alphabet',
    SignCategory.greetings => 'Greetings',
    SignCategory.numbers => 'Numbers',
    SignCategory.colors => 'Colors',
    SignCategory.family => 'Family',
    SignCategory.emotions => 'Emotions',
    SignCategory.food => 'Food',
    SignCategory.common => 'Common Words',
  };

  String get emoji => switch (this) {
    SignCategory.alphabet => '🔤',
    SignCategory.greetings => '👋',
    SignCategory.numbers => '🔢',
    SignCategory.colors => '🎨',
    SignCategory.family => '👨‍👩‍👧',
    SignCategory.emotions => '😊',
    SignCategory.food => '🍎',
    SignCategory.common => '💬',
  };
}

class SignModel {
  final String id;
  final String word;
  final String description;
  final String handShape;
  final String movement;
  final String location;
  final SignCategory category;
  final List<String> tips;
  final bool isDynamic; // requires motion (J, Z etc.)
  final int difficulty; // 1=easy 2=medium 3=hard

  const SignModel({
    required this.id,
    required this.word,
    required this.description,
    required this.handShape,
    required this.movement,
    required this.location,
    required this.category,
    this.tips = const [],
    this.isDynamic = false,
    this.difficulty = 1,
  });
}
