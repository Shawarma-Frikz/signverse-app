import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translation_model.dart';
import '../repositories/history_repository.dart';

final historyRepositoryProvider = Provider<HistoryRepository>(
  (_) => HistoryRepository(),
);

// ── State ──────────────────────────────────────────────────────────
class HistoryState {
  final List<TranslationModel> translations;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int total;
  final bool hasMore;

  const HistoryState({
    this.translations = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.total = 0,
    this.hasMore = false,
  });

  HistoryState copyWith({
    List<TranslationModel>? translations,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? total,
    bool? hasMore,
  }) => HistoryState(
    translations: translations ?? this.translations,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: error,
    total: total ?? this.total,
    hasMore: hasMore ?? this.hasMore,
  );
}

// ── Notifier ───────────────────────────────────────────────────────
class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryRepository _repo;
  static const _pageSize = 20;

  HistoryNotifier(this._repo) : super(const HistoryState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _repo.getTranslations(skip: 0, limit: _pageSize);
      state = state.copyWith(
        translations: items,
        isLoading: false,
        total: items.length,
        hasMore: items.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load history');
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final more = await _repo.getTranslations(
        skip: state.translations.length,
        limit: _pageSize,
      );
      state = state.copyWith(
        translations: [...state.translations, ...more],
        isLoadingMore: false,
        hasMore: more.length == _pageSize,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteTranslation(id);
      state = state.copyWith(
        translations: state.translations.where((t) => t.id != id).toList(),
        total: state.total - 1,
      );
    } catch (_) {}
  }

  Future<void> refresh() => fetch();
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((
  ref,
) {
  return HistoryNotifier(ref.watch(historyRepositoryProvider));
});
