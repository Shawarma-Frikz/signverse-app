import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sign_model.dart';
import '../data/sign_database.dart';

// Currently selected category
final selectedCategoryProvider = StateProvider<SignCategory?>((ref) => null);

// Signs for selected category (or all if null)
final signsProvider = Provider<List<SignModel>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  if (category == null) return SignDatabase.all;
  return SignDatabase.byCategory(category);
});

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtered signs
final filteredSignsProvider = Provider<List<SignModel>>((ref) {
  final signs = ref.watch(signsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  if (query.isEmpty) return signs;
  return signs
      .where(
        (s) =>
            s.word.toLowerCase().contains(query) ||
            s.description.toLowerCase().contains(query),
      )
      .toList();
});

// Practice session state
class PracticeState {
  final List<SignModel> queue;
  final int currentIndex;
  final int correct;
  final int incorrect;
  final bool isFinished;

  const PracticeState({
    required this.queue,
    this.currentIndex = 0,
    this.correct = 0,
    this.incorrect = 0,
    this.isFinished = false,
  });

  SignModel? get current =>
      currentIndex < queue.length ? queue[currentIndex] : null;

  double get progress => queue.isEmpty ? 0 : currentIndex / queue.length;

  int get total => queue.length;

  PracticeState copyWith({
    int? currentIndex,
    int? correct,
    int? incorrect,
    bool? isFinished,
  }) => PracticeState(
    queue: queue,
    currentIndex: currentIndex ?? this.currentIndex,
    correct: correct ?? this.correct,
    incorrect: incorrect ?? this.incorrect,
    isFinished: isFinished ?? this.isFinished,
  );
}

class PracticeNotifier extends StateNotifier<PracticeState> {
  PracticeNotifier(List<SignModel> signs)
    : super(PracticeState(queue: _shuffled(signs)));

  static List<SignModel> _shuffled(List<SignModel> signs) {
    final list = [...signs];
    list.shuffle();
    return list;
  }

  void markCorrect() {
    final next = state.currentIndex + 1;
    state = state.copyWith(
      currentIndex: next,
      correct: state.correct + 1,
      isFinished: next >= state.total,
    );
  }

  void markIncorrect() {
    final next = state.currentIndex + 1;
    state = state.copyWith(
      currentIndex: next,
      incorrect: state.incorrect + 1,
      isFinished: next >= state.total,
    );
  }

  void restart() {
    state = PracticeState(queue: _shuffled(state.queue));
  }
}

// ── Fixed: Added the missing '<' for the generic type arguments ──
final practiceProvider =
    StateNotifierProvider.family<
      PracticeNotifier,
      PracticeState,
      List<SignModel>
    >((ref, signs) => PracticeNotifier(signs));
