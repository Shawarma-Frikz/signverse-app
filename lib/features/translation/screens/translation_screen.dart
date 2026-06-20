import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/camera_service.dart';
import 'package:hand_detection/hand_detection.dart';
import '../../../core/services/hand_landmark_service.dart';
import '../widgets/landmark_painter.dart';
import '../services/prediction_service.dart';
import '../../../core/services/tts_service.dart';
import '../../history/repositories/history_repository.dart';
import '../../../core/services/connectivity_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isFrontCamera = true;
  bool _isMuted = false;

  // New state fields for hand detection
  List<Hand> _detectedHands = [];
  Size _imageSize = Size.zero;
  bool _isStreaming = false;

  // ── No-hand timeout ──────────────────────────────────────────
  DateTime? _lastHandSeen;
  bool _showNoHandWarning = false;
  static const _noHandTimeoutMs = 2000;

  // ── Prediction state ─────────────────────────────────────────
  PredictionResult? _prediction;
  double _lastRawConfidence = 0.0;
  String _builtSentence = '';
  final List<String> _wordBuffer = [];

  // ── History state ────────────────────────────────────────────
  final HistoryRepository _historyRepo = HistoryRepository();
  final List<String> _detectedSigns = [];
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      await CameraService.instance.initialize(useFrontCamera: _isFrontCamera);
      await HandLandmarkService.instance.initialize();
      await TtsService.instance.initialize();
      setState(() => _isLoading = false);
      _startStream();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e is CameraException
            ? e.description ?? 'Camera error'
            : 'Could not access camera';
      });
    }
  }

  void _startStream() {
    final controller = CameraService.instance.controller;
    if (controller == null || _isStreaming) return;
    _isStreaming = true;

    controller.startImageStream((image) async {
      final result = await HandLandmarkService.instance.detect(
        image,
        sensorOrientation: controller.description.sensorOrientation,
        isFrontCamera: _isFrontCamera,
      );

      if (result == null || !mounted) return;

      // ── Update landmark overlay ──────────────────────────────
      final orientation = controller.description.sensorOrientation;
      final isSwapped = orientation == 90 || orientation == 270;

      setState(() {
        _detectedHands = result.hands;
        _imageSize = isSwapped
            ? Size(image.height.toDouble(), image.width.toDouble())
            : Size(image.width.toDouble(), image.height.toDouble());

        // ── No-hand tracking ──────────────────────────────────
        if (result.hands.isNotEmpty) {
          _lastHandSeen = DateTime.now();
          _showNoHandWarning = false;
        } else {
          final elapsed = _lastHandSeen != null
              ? DateTime.now().difference(_lastHandSeen!).inMilliseconds
              : _noHandTimeoutMs + 1;
          _showNoHandWarning = elapsed > _noHandTimeoutMs;
        }
      });

      // ── Send to API ──────────────────────────────────────────
      final flat = result.flatLandmarks;
      if (flat == null || flat.length != 63) return;

      final prediction = await PredictionService.instance.predictAlphabet(flat);
      if (prediction == null || !mounted) return;

      // Only accept predictions above 70% confidence
      setState(() => _lastRawConfidence = prediction.confidence);
      if (prediction.confidence < 0.70) return;

      setState(() => _prediction = prediction);
    });
  }

  Future<void> _switchCamera() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    final controller = CameraService.instance.controller;
    await controller?.stopImageStream();
    _isStreaming = false;

    _isFrontCamera = !_isFrontCamera;
    await CameraService.instance.switchCamera();
    await HandLandmarkService.instance.reset();

    setState(() => _isLoading = false);
    _startStream();
  }

  void _toggleMute() {
    HapticFeedback.lightImpact();
    setState(() {
      _isMuted = !_isMuted;
      TtsService.instance.setEnabled(!_isMuted);
    });
    if (_isMuted) TtsService.instance.stop();
  }

  void _stopTranslation() {
    HapticFeedback.mediumImpact();
    Navigator.maybePop(context);
  }

  Future<void> _saveTranslation(double confidence) async {
    if (_builtSentence.trim().isEmpty) return;

    // ── Offline guard ──────────────────────────────────────────────
    if (!ConnectivityService.instance.isOnline) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.warning400,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.s2),
              Text(
                'You\'re offline — translation not saved',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        ),
      );
      return;
    }

    final durationMs = _sessionStart != null
        ? DateTime.now().difference(_sessionStart!).inMilliseconds
        : null;

    try {
      await _historyRepo.saveTranslation(
        inputType: 'alphabet',
        detectedSigns: _detectedSigns.join(','),
        resultText: _builtSentence.trim(),
        confidence: confidence,
        durationMs: durationMs,
      );

      if (!mounted) return;
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success400,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.s2),
              Text('Translation saved!', style: AppTextStyles.bodyMedium),
            ],
          ),
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
          duration: const Duration(seconds: 2),
        ),
      );

      // Reset session
      setState(() {
        _builtSentence = '';
        _detectedSigns.clear();
        _sessionStart = null;
        _prediction = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save. Check your connection.',
            style: AppTextStyles.bodyMedium,
          ),
          backgroundColor: AppColors.error500,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = CameraService.instance.controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.stopImageStream();
      _isStreaming = false;
      CameraService.instance.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CameraService.instance.controller?.stopImageStream();
    HandLandmarkService.instance.dispose();
    TtsService.instance.stop();
    CameraService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary900,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                child: _buildViewfinder(),
              ),
            ),
            _buildTranslationOutput(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s2,
        AppSpacing.s4,
        AppSpacing.s2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _IconTapTarget(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.maybePop(context),
          ),

          // Live status pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingDot(active: !_isLoading && !_hasError),
              const SizedBox(width: AppSpacing.s2),
              Text(
                'Live',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.accent300,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),

          _IconTapTarget(icon: Icons.more_horiz_rounded, onTap: () {}),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Viewfinder ─────────────────────────────────────────────────
  Widget _buildViewfinder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: AppRadius.xl2Border,
        border: Border.all(
          color: AppColors.accent500.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isLoading)
            _buildLoadingState()
          else if (_hasError)
            _buildErrorState()
          else
            _buildCameraFeed(),

          // Corner markers — always visible over the feed
          if (!_isLoading && !_hasError) ..._buildCornerMarkers(),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.97, 0.97));
  }

  Widget _buildCameraFeed() {
    final controller = CameraService.instance.controller!;
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(child: CameraPreview(controller)),

        // Landmark overlay
        if (_detectedHands.isNotEmpty)
          CustomPaint(
            painter: LandmarkPainter(
              hands: _detectedHands,
              imageSize: _imageSize,
            ),
          ),

        // No-hand warning overlay
        if (_showNoHandWarning)
          Positioned(
            top: AppSpacing.s4,
            left: AppSpacing.s4,
            right: AppSpacing.s4,
            child: _NoHandBanner(),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent500),
            strokeWidth: 2,
          ),
          SizedBox(height: AppSpacing.s4),
          Text('Starting camera...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off_rounded,
              color: AppColors.error400,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              _errorMessage,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s4),
            TextButton.icon(
              onPressed: _initCamera,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.accent500,
                size: 18,
              ),
              label: Text(
                'Try Again',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accent500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    const size = 24.0;
    const thickness = 3.0;
    const offset = 12.0;
    const color = AppColors.accent400;

    return [
      // Top-left
      const Positioned(
        top: offset,
        left: offset,
        child: _CornerMarker(
          size: size,
          thickness: thickness,
          color: color,
          alignment: Alignment.topLeft,
        ),
      ),
      // Top-right
      const Positioned(
        top: offset,
        right: offset,
        child: _CornerMarker(
          size: size,
          thickness: thickness,
          color: color,
          alignment: Alignment.topRight,
        ),
      ),
      // Bottom-left
      const Positioned(
        bottom: offset,
        left: offset,
        child: _CornerMarker(
          size: size,
          thickness: thickness,
          color: color,
          alignment: Alignment.bottomLeft,
        ),
      ),
      // Bottom-right
      const Positioned(
        bottom: offset,
        right: offset,
        child: _CornerMarker(
          size: size,
          thickness: thickness,
          color: color,
          alignment: Alignment.bottomRight,
        ),
      ),
    ];
  }

  // ── Translation output (glass card) ───────────────────────────
  Widget _buildTranslationOutput() {
    final prediction = _prediction;
    final hasHand = _detectedHands.isNotEmpty;
    final isLowConf =
        hasHand &&
        _lastRawConfidence > 0 &&
        _lastRawConfidence < 0.70 &&
        prediction == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s3,
        AppSpacing.s4,
        0,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlBorder,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s4),
            decoration: BoxDecoration(
              color: isLowConf
                  ? AppColors.warning500.withValues(alpha: 0.08)
                  : prediction != null
                  ? AppColors.accent500.withValues(alpha: 0.12)
                  : AppColors.white.withValues(alpha: 0.08),
              borderRadius: AppRadius.xlBorder,
              border: Border.all(
                color: isLowConf
                    ? AppColors.warning500.withValues(alpha: 0.3)
                    : prediction != null
                    ? AppColors.accent500.withValues(alpha: 0.3)
                    : AppColors.white.withValues(alpha: 0.1),
              ),
            ),
            child: isLowConf
                ? _buildLowConfHint()
                : prediction != null
                ? _buildPredictionContent(prediction)
                : _buildEmptyHint(),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15);
  }

  Widget _buildLowConfHint() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.warning500.withValues(alpha: 0.1),
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: AppColors.warning500.withValues(alpha: 0.3),
            ),
          ),
          child: const Icon(
            Icons.help_outline_rounded,
            color: AppColors.warning400,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign unclear',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.warning300,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hold still and face your palm toward the camera',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.warning400.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              // Low confidence bar
              ClipRRect(
                borderRadius: AppRadius.fullBorder,
                child: LinearProgressIndicator(
                  value: _lastRawConfidence,
                  backgroundColor: AppColors.primary400.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(
                    AppColors.warning400,
                  ),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionContent(PredictionResult prediction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Main prediction ──────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Big letter
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppGradients.accent,
                borderRadius: AppRadius.lgBorder,
                boxShadow: AppShadows.glowCyan,
              ),
              child: Center(
                child: Text(
                  prediction.label.toUpperCase(),
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Confidence bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: AppRadius.fullBorder,
                          child: LinearProgressIndicator(
                            value: prediction.confidence,
                            backgroundColor: AppColors.primary400.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: AlwaysStoppedAnimation(
                              _confidenceColor(prediction.confidence),
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Text(
                        '${(prediction.confidence * 100).toStringAsFixed(1)}%',
                        style: AppTextStyles.mono.copyWith(
                          color: _confidenceColor(prediction.confidence),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  // Top 3 alternatives
                  Row(
                    children: prediction.top5
                        .skip(1)
                        .take(3)
                        .map(
                          (c) => Container(
                            margin: const EdgeInsets.only(right: AppSpacing.s1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.07),
                              borderRadius: AppRadius.fullBorder,
                            ),
                            child: Text(
                              '${c.label.toUpperCase()} ${(c.confidence * 100).toInt()}%',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white.withValues(alpha: 0.5),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Sentence builder ─────────────────────────────────────
        if (_builtSentence.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s3),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s3,
              vertical: AppSpacing.s2,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.05),
              borderRadius: AppRadius.mdBorder,
            ),
            child: Text(
              _builtSentence,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                height: 1.5,
              ),
            ),
          ),
        ],

        // ── Action buttons ───────────────────────────────────────
        const SizedBox(height: AppSpacing.s3),
        Row(
          children: [
            _GlassButton(
              icon: Icons.add_rounded,
              label: 'Add letter',
              onTap: () {
                final letter = prediction.label.toUpperCase();
                setState(() {
                  _builtSentence += letter;
                  _detectedSigns.add(letter);
                  _sessionStart ??= DateTime.now();
                });
                TtsService.instance.speakLetter(letter);
              },
            ),
            const SizedBox(width: AppSpacing.s2),
            _GlassButton(
              icon: Icons.space_bar_rounded,
              label: 'Space',
              onTap: () => setState(() => _builtSentence += ' '),
            ),
            const SizedBox(width: AppSpacing.s2),
            _GlassButton(
              icon: Icons.backspace_outlined,
              label: 'Delete',
              onTap: () {
                if (_builtSentence.isNotEmpty) {
                  setState(
                    () => _builtSentence = _builtSentence.substring(
                      0,
                      _builtSentence.length - 1,
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: AppSpacing.s2),
            _GlassButton(
              icon: Icons.record_voice_over_rounded,
              label: 'Speak',
              onTap: () {
                if (_builtSentence.isNotEmpty) {
                  TtsService.instance.speakSentence(_builtSentence);
                }
              },
            ),
            const SizedBox(width: AppSpacing.s2),
            _GlassButton(
              icon: Icons.save_rounded,
              label: 'Save',
              onTap: () => _saveTranslation(prediction.confidence),
            ),
            const SizedBox(width: AppSpacing.s2),
            _GlassButton(
              icon: Icons.clear_rounded,
              label: 'Clear',
              onTap: () {
                TtsService.instance.stop();
                setState(() {
                  _builtSentence = '';
                  _detectedSigns.clear();
                  _sessionStart = null;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyHint() {
    return Row(
      children: [
        const Icon(
          Icons.front_hand_rounded,
          color: AppColors.accent300,
          size: 22,
        ),
        const SizedBox(width: AppSpacing.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Show a sign to begin',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Position your hand inside the frame',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 0.90) return AppColors.success400;
    if (confidence >= 0.75) return AppColors.accent400;
    return AppColors.warning400;
  }

  // ── Bottom controls ────────────────────────────────────────────
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s4,
        AppSpacing.s4,
        AppSpacing.s4,
        AppSpacing.s3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RoundIconButton(
            icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            size: 40,
            background: AppColors.white.withValues(alpha: 0.1),
            iconColor: AppColors.white,
            onTap: _toggleMute,
          ),
          const SizedBox(width: AppSpacing.s8),
          _StopFab(onTap: _stopTranslation),
          const SizedBox(width: AppSpacing.s8),
          _RoundIconButton(
            icon: Icons.flip_camera_ios_rounded,
            size: 40,
            background: AppColors.white.withValues(alpha: 0.1),
            iconColor: AppColors.white,
            onTap: _switchCamera,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }
}

// ── Reusable bits ────────────────────────────────────────────────

class _NoHandBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.lgBorder,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s3,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: AppColors.warning500.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.front_hand_rounded,
                color: AppColors.warning400,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.s2),
              Text(
                'No hand detected — show your hand',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.warning300,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s2,
          vertical: AppSpacing.s2,
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.08),
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.white, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 9,
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconTapTarget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconTapTarget({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s2),
        child: Icon(
          icon,
          color: AppColors.white.withValues(alpha: 0.7),
          size: 20,
        ),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  final bool active;
  const _PulsingDot({required this.active});

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.success500 : AppColors.primary300,
      ),
    );

    if (!active) return dot;

    return dot
        .animate(onPlay: (c) => c.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.6, 1.6),
          duration: 800.ms,
          curve: Curves.easeOut,
        )
        .fadeOut(duration: 800.ms);
  }
}

class _CornerMarker extends StatelessWidget {
  final double size;
  final double thickness;
  final Color color;
  final Alignment alignment;

  const _CornerMarker({
    required this.size,
    required this.thickness,
    required this.color,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    Border border;
    BorderRadius radius;

    switch (alignment) {
      case Alignment.topLeft:
        border = Border(
          left: BorderSide(color: color, width: thickness),
          top: BorderSide(color: color, width: thickness),
        );
        radius = const BorderRadius.only(topLeft: Radius.circular(6));
        break;
      case Alignment.topRight:
        border = Border(
          right: BorderSide(color: color, width: thickness),
          top: BorderSide(color: color, width: thickness),
        );
        radius = const BorderRadius.only(topRight: Radius.circular(6));
        break;
      case Alignment.bottomLeft:
        border = Border(
          left: BorderSide(color: color, width: thickness),
          bottom: BorderSide(color: color, width: thickness),
        );
        radius = const BorderRadius.only(bottomLeft: Radius.circular(6));
        break;
      default:
        border = Border(
          right: BorderSide(color: color, width: thickness),
          bottom: BorderSide(color: color, width: thickness),
        );
        radius = const BorderRadius.only(bottomRight: Radius.circular(6));
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(border: border, borderRadius: radius),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.size,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}

class _StopFab extends StatefulWidget {
  final VoidCallback onTap;
  const _StopFab({required this.onTap});

  @override
  State<_StopFab> createState() => _StopFabState();
}

class _StopFabState extends State<_StopFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppGradients.accent,
            shape: BoxShape.circle,
            boxShadow: AppShadows.glowCyan,
          ),
          child: const Center(
            child: Icon(Icons.stop_rounded, color: AppColors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
