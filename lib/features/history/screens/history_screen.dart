import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/translation_model.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();
  String _filter = 'all'; // 'all' | 'alphabet' | 'word'

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(historyProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<TranslationModel> _filtered(List<TranslationModel> all) {
    if (_filter == 'all') return all;
    return all.where((t) => t.inputType == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: context.bgPrimary,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent500.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(state),
                _buildFilterChips(),
                Expanded(child: _buildBody(state)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────
  Widget _buildHeader(HistoryState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s6,
        AppSpacing.s6,
        AppSpacing.s6,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History',
                style: AppTextStyles.displaySmall.copyWith(fontSize: 28),
              ).animate().fadeIn(),
              if (state.total > 0)
                Text(
                  '${state.total} translation${state.total == 1 ? '' : 's'}',
                  style: AppTextStyles.bodySmall,
                ).animate().fadeIn(delay: 100.ms),
            ],
          ),
          IconButton(
            onPressed: () => ref.read(historyProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent500),
          ).animate().fadeIn(delay: 100.ms),
        ],
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s6,
        AppSpacing.s4,
        AppSpacing.s6,
        0,
      ),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _filter == 'all',
            onTap: () => setState(() => _filter = 'all'),
          ),
          const SizedBox(width: AppSpacing.s2),
          _FilterChip(
            label: 'Alphabet',
            isSelected: _filter == 'alphabet',
            onTap: () => setState(() => _filter = 'alphabet'),
            icon: Icons.abc_rounded,
          ),
          const SizedBox(width: AppSpacing.s2),
          _FilterChip(
            label: 'Words',
            isSelected: _filter == 'word',
            onTap: () => setState(() => _filter = 'word'),
            icon: Icons.sign_language_rounded,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  // ── Body ───────────────────────────────────────────────────────
  Widget _buildBody(HistoryState state) {
    if (state.isLoading) return _buildLoading();
    if (state.error != null) return _buildError(state.error!);

    final items = _filtered(state.translations);

    if (items.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      onRefresh: () => ref.read(historyProvider.notifier).refresh(),
      color: AppColors.accent500,
      backgroundColor: context.bgSurface,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s6,
          AppSpacing.s4,
          AppSpacing.s6,
          AppSpacing.s16,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.s4),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.accent500),
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return _TranslationCard(
            translation: items[index],
            index: index,
            onDelete: () => _confirmDelete(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.s6),
      itemCount: 6,
      itemBuilder: (_, i) => _SkeletonCard(delay: i * 80),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.s4),
            Text('Something went wrong', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.s2),
            Text(
              error,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s6),
            ElevatedButton.icon(
              onPressed: () => ref.read(historyProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent500.withValues(alpha: 0.12),
                    AppColors.accent500.withValues(alpha: 0.02),
                  ],
                ),
                border: Border.all(
                  color: AppColors.accent500.withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: Text('📭', style: TextStyle(fontSize: 44)),
              ),
            ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
            const SizedBox(height: AppSpacing.s6),
            Text(
              'No translations yet',
              style: AppTextStyles.headlineMedium,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.s2),
            Text(
              'Start translating ASL signs and\nyour history will appear here.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(TranslationModel t) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteSheet(translation: t),
    );
    if (confirmed == true) {
      ref.read(historyProvider.notifier).delete(t.id);
    }
  }
}

// ── Translation card ──────────────────────────────────────────────
class _TranslationCard extends StatelessWidget {
  final TranslationModel translation;
  final int index;
  final VoidCallback onDelete;

  const _TranslationCard({
    required this.translation,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
          key: Key('translation_${translation.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s3),
            decoration: BoxDecoration(
              color: AppColors.error500.withValues(alpha: 0.15),
              borderRadius: AppRadius.xlBorder,
              border: Border.all(
                color: AppColors.error500.withValues(alpha: 0.3),
              ),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.s6),
            child: const Icon(
              Icons.delete_rounded,
              color: AppColors.error400,
              size: 24,
            ),
          ),
          confirmDismiss: (_) async {
            onDelete();
            return false; // Let the provider handle removal
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s3),
            decoration: BoxDecoration(
              color: context.bgSurface,
              borderRadius: AppRadius.xlBorder,
              border: Border.all(color: context.border),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showDetail(context),
                borderRadius: AppRadius.xlBorder,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: translation.inputType == 'alphabet'
                              ? AppGradients.accent
                              : AppGradients.primary,
                          borderRadius: AppRadius.lgBorder,
                        ),
                        child: Center(
                          child: Icon(
                            translation.inputType == 'alphabet'
                                ? Icons.abc_rounded
                                : Icons.sign_language_rounded,
                            color: AppColors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.s3),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translation.resultText,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.s1),
                            Row(
                              children: [
                                Text(
                                  translation.formattedDate,
                                  style: AppTextStyles.bodySmall,
                                ),
                                const SizedBox(width: AppSpacing.s2),
                                Text('·', style: AppTextStyles.bodySmall),
                                const SizedBox(width: AppSpacing.s2),
                                Text(
                                  translation.formattedTime,
                                  style: AppTextStyles.bodySmall,
                                ),
                                if (translation.confidence != null) ...[
                                  const SizedBox(width: AppSpacing.s2),
                                  Text('·', style: AppTextStyles.bodySmall),
                                  const SizedBox(width: AppSpacing.s2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s2,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success500.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: AppRadius.fullBorder,
                                    ),
                                    child: Text(
                                      '${(translation.confidence! * 100).toInt()}%',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.success400,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary300,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: index * 60),
          duration: 400.ms,
        )
        .slideY(begin: 0.1);
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DetailSheet(translation: translation),
    );
  }
}

// ── Detail bottom sheet ───────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final TranslationModel translation;
  const _DetailSheet({required this.translation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.s3),
      padding: const EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: context.bgSurface,
        borderRadius: AppRadius.xl2Border,
        border: Border.all(color: context.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: AppRadius.fullBorder,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s5),

          Text('Translation Detail', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.s5),

          // Result text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s4),
            decoration: BoxDecoration(
              gradient: AppGradients.card,
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: context.border),
            ),
            child: Text(
              translation.resultText,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.accent300,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppSpacing.s4),

          // Meta info
          _DetailRow(
            icon: Icons.category_outlined,
            label: 'Type',
            value: translation.inputType == 'alphabet'
                ? 'Alphabet spelling'
                : 'Word sign',
          ),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value:
                '${translation.formattedDate} at ${translation.formattedTime}',
          ),
          if (translation.confidence != null)
            _DetailRow(
              icon: Icons.analytics_outlined,
              label: 'Avg confidence',
              value: '${(translation.confidence! * 100).toStringAsFixed(1)}%',
            ),
          if (translation.durationMs != null)
            _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Session length',
              value: '${(translation.durationMs! / 1000).toStringAsFixed(1)}s',
            ),
          _DetailRow(
            icon: Icons.fingerprint_rounded,
            label: 'Signs detected',
            value: translation.detectedSigns,
            isLast: true,
          ),

          const SizedBox(height: AppSpacing.s5),

          // Copy button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: translation.resultText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Copied to clipboard',
                      style: AppTextStyles.bodyMedium,
                    ),
                    backgroundColor: AppColors.surfaceVariant,
                    behavior: SnackBarBehavior.floating,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.lgBorder,
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy to clipboard'),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent500, size: 18),
              const SizedBox(width: AppSpacing.s3),
              Text(label, style: AppTextStyles.bodySmall),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: context.border),
      ],
    );
  }
}

// ── Delete confirmation sheet ──────────────────────────────────────
class _DeleteSheet extends StatelessWidget {
  final TranslationModel translation;
  const _DeleteSheet({required this.translation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.s3),
      padding: const EdgeInsets.all(AppSpacing.s6),
      decoration: BoxDecoration(
        color: context.bgSurface,
        borderRadius: AppRadius.xl2Border,
        border: Border.all(color: context.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: AppRadius.fullBorder,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s5),

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error500.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error500.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.delete_rounded,
              color: AppColors.error400,
              size: 28,
            ),
          ),

          const SizedBox(height: AppSpacing.s4),

          Text('Delete translation?', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.s2),

          Text(
            '"${translation.resultText}"',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.s6),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s3,
                    ),
                    side: BorderSide(color: context.border),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.lgBorder,
                    ),
                  ),
                  child: Text('Cancel', style: AppTextStyles.labelLarge),
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error500,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s3,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.lgBorder,
                    ),
                  ),
                  child: Text('Delete', style: AppTextStyles.buttonLabel),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent500.withValues(alpha: 0.15)
              : context.bgSurface,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(
            color: isSelected
                ? AppColors.accent500.withValues(alpha: 0.5)
                : context.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.accent500 : AppColors.primary300,
              ),
              const SizedBox(width: AppSpacing.s1),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.accent500 : AppColors.primary300,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton loading card ─────────────────────────────────────────
class _SkeletonCard extends StatefulWidget {
  final int delay;
  const _SkeletonCard({required this.delay});

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmer = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: context.bgSurface,
          borderRadius: AppRadius.xlBorder,
          border: Border.all(color: context.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.bgVariant.withValues(alpha: _shimmer.value),
                borderRadius: AppRadius.lgBorder,
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.bgVariant.withValues(
                        alpha: _shimmer.value,
                      ),
                      borderRadius: AppRadius.smBorder,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Container(
                    height: 10,
                    width: 140,
                    decoration: BoxDecoration(
                      color: context.bgVariant.withValues(
                        alpha: _shimmer.value * 0.7,
                      ),
                      borderRadius: AppRadius.smBorder,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.delay));
  }
}
