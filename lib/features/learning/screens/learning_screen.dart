import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/sign_database.dart';
import '../models/sign_model.dart';
import '../providers/learning_provider.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = SignDatabase.grouped();
    final selected = ref.watch(selectedCategoryProvider);
    final filtered = ref.watch(filteredSignsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary500.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s6,
                      AppSpacing.s6,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Learn',
                                    style: AppTextStyles.displaySmall.copyWith(
                                      fontSize: 28,
                                    ),
                                  ).animate().fadeIn(),
                                  Text(
                                    '${SignDatabase.all.length} signs across ${grouped.length} categories',
                                    style: AppTextStyles.bodySmall,
                                  ).animate().fadeIn(delay: 100.ms),
                                ],
                              ),
                            ),
                            // Practice all button
                            GestureDetector(
                              onTap: () => _startPractice(
                                context,
                                SignDatabase.all,
                                'All Signs',
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s4,
                                  vertical: AppSpacing.s2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.accent,
                                  borderRadius: AppRadius.fullBorder,
                                  boxShadow: AppShadows.glowCyan,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      color: AppColors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: AppSpacing.s1),
                                    Text(
                                      'Practice',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.white,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 150.ms),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Search bar ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s4,
                      AppSpacing.s6,
                      0,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) =>
                          ref.read(searchQueryProvider.notifier).state = v,
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search signs...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary300,
                          size: 20,
                        ),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: AppColors.primary300,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                },
                              )
                            : null,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ),

                // ── Category chips ───────────────────────────────
                if (query.isEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s6,
                          AppSpacing.s3,
                          AppSpacing.s6,
                          0,
                        ),
                        scrollDirection: Axis.horizontal,
                        children: [
                          _CategoryChip(
                            label: 'All',
                            emoji: '✨',
                            isSelected: selected == null,
                            onTap: () =>
                                ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state =
                                    null,
                          ),
                          const SizedBox(width: AppSpacing.s2),
                          ...SignCategory.values.map((cat) {
                            final count = grouped[cat]?.length ?? 0;
                            if (count == 0) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.s2,
                              ),
                              child: _CategoryChip(
                                label: cat.label,
                                emoji: cat.emoji,
                                count: count,
                                isSelected: selected == cat,
                                onTap: () =>
                                    ref
                                            .read(
                                              selectedCategoryProvider.notifier,
                                            )
                                            .state =
                                        cat,
                              ),
                            );
                          }),
                        ],
                      ),
                    ).animate().fadeIn(delay: 250.ms),
                  ),

                // ── Category headers + grids ─────────────────────
                if (query.isEmpty && selected == null)
                  ...grouped.entries.map((entry) {
                    final cat = entry.key;
                    final signs = entry.value;
                    return SliverToBoxAdapter(
                      child: _CategorySection(
                        category: cat,
                        signs: signs,
                        onPractice: () =>
                            _startPractice(context, signs, cat.label),
                        onTapSign: (sign) => _openDetail(context, sign),
                      ),
                    );
                  })
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s4,
                      AppSpacing.s6,
                      AppSpacing.s16,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _SignCard(
                          sign: filtered[i],
                          index: i,
                          onTap: () => _openDetail(context, filtered[i]),
                        ),
                        childCount: filtered.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: AppSpacing.s3,
                            mainAxisSpacing: AppSpacing.s3,
                            childAspectRatio: 0.85,
                          ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.s16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, SignModel sign) {
    HapticFeedback.lightImpact();
    context.push('/learn/${sign.id}');
  }

  void _startPractice(
    BuildContext context,
    List<SignModel> signs,
    String label,
  ) {
    HapticFeedback.mediumImpact();
    context.push('/learn/practice', extra: signs);
  }
}

// ── Category section ──────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final SignCategory category;
  final List<SignModel> signs;
  final VoidCallback onPractice;
  final void Function(SignModel) onTapSign;

  const _CategorySection({
    required this.category,
    required this.signs,
    required this.onPractice,
    required this.onTapSign,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s6,
        AppSpacing.s6,
        AppSpacing.s6,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: AppSpacing.s2),
                  Text(category.label, style: AppTextStyles.headlineMedium),
                  const SizedBox(width: AppSpacing.s2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s2,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent500.withValues(alpha: 0.1),
                      borderRadius: AppRadius.fullBorder,
                    ),
                    child: Text(
                      '${signs.length}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accent400,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onPractice,
                child: Text(
                  'Practice',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.accent500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.s3,
              mainAxisSpacing: AppSpacing.s3,
              childAspectRatio: 0.85,
            ),
            itemCount: signs.length,
            itemBuilder: (_, i) => _SignCard(
              sign: signs[i],
              index: i,
              onTap: () => onTapSign(signs[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sign card ─────────────────────────────────────────────────────
class _SignCard extends StatefulWidget {
  final SignModel sign;
  final int index;
  final VoidCallback onTap;

  const _SignCard({
    required this.sign,
    required this.index,
    required this.onTap,
  });

  @override
  State<_SignCard> createState() => _SignCardState();
}

class _SignCardState extends State<_SignCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _difficultyColor => switch (widget.sign.difficulty) {
    1 => AppColors.success400,
    2 => AppColors.warning400,
    _ => AppColors.error400,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.xlBorder,
                border: Border.all(
                  color: AppColors.primary400.withValues(alpha: 0.2),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.s3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Text(
                          widget.sign.word,
                          style: AppTextStyles.displaySmall.copyWith(
                            fontSize: widget.sign.word.length > 3 ? 18 : 26,
                            color: AppColors.accent300,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          widget.sign.handShape,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 9,
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  // Dynamic badge
                  if (widget.sign.isDynamic)
                    Positioned(
                      top: AppSpacing.s2,
                      left: AppSpacing.s2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning500.withValues(alpha: 0.15),
                          borderRadius: AppRadius.smBorder,
                        ),
                        child: const Icon(
                          Icons.gesture_rounded,
                          color: AppColors.warning400,
                          size: 10,
                        ),
                      ),
                    ),

                  // Difficulty dot
                  Positioned(
                    top: AppSpacing.s2,
                    right: AppSpacing.s2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _difficultyColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: widget.index * 40),
          duration: 300.ms,
        )
        .scale(begin: const Offset(0.9, 0.9));
  }
}

// ── Category chip ─────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const _CategoryChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    this.count,
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
          horizontal: AppSpacing.s3,
          vertical: AppSpacing.s1,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent500.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: AppRadius.fullBorder,
          border: Border.all(
            color: isSelected
                ? AppColors.accent500.withValues(alpha: 0.5)
                : AppColors.primary400.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: AppSpacing.s1),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.accent500 : AppColors.primary300,
                letterSpacing: 0,
                fontSize: 12,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: AppSpacing.s1),
              Text(
                '($count)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.accent400 : AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
