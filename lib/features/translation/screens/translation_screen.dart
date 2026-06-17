import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/camera_service.dart';

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
      setState(() => _isLoading = false);
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

  Future<void> _switchCamera() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    _isFrontCamera = !_isFrontCamera;
    await CameraService.instance.switchCamera();
    setState(() => _isLoading = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = CameraService.instance.controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      CameraService.instance.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CameraService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera preview ──────────────────────────────────────
          if (_isLoading)
            _buildLoading()
          else if (_hasError)
            _buildError()
          else
            _buildCameraPreview(),

          // ── Top overlay ──────────────────────────────────────────
          if (!_isLoading && !_hasError) _buildTopBar(),

          // ── Bottom overlay ────────────────────────────────────────
          if (!_isLoading && !_hasError) _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      color: AppColors.background,
      child: const Center(
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
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error500.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error500.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.videocam_off_rounded,
                  color: AppColors.error400,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.s5),
              Text('Camera access needed', style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppSpacing.s2),
              Text(
                _errorMessage,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s6),
              ElevatedButton.icon(
                onPressed: _initCamera,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = CameraService.instance.controller!;

    return ClipRRect(
      child: Transform.scale(
        scale: 1.0,
        child: Center(child: CameraPreview(controller)),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CircleButton(
              icon: Icons.close_rounded,
              onTap: () => Navigator.maybePop(context),
            ),

            // Status pill
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: AppRadius.fullBorder,
                border: Border.all(color: AppColors.accent500.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success500,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.4, 1.4),
                        duration: 800.ms,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.4, 1.4),
                        end: const Offset(1, 1),
                        duration: 800.ms,
                      ),
                  const SizedBox(width: AppSpacing.s2),
                  Text(
                    'Live',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),

            _CircleButton(
              icon: Icons.flip_camera_ios_rounded,
              onTap: _switchCamera,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2);
  }

  Widget _buildBottomPanel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.s4),
          padding: const EdgeInsets.all(AppSpacing.s5),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.92),
            borderRadius: AppRadius.xl2Border,
            border: Border.all(color: AppColors.accent500.withOpacity(0.2)),
            boxShadow: AppShadows.lg,
          ),
          child: Column(
            children: [
              // Prediction display placeholder
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.accent500.withOpacity(0.1),
                      borderRadius: AppRadius.lgBorder,
                      border: Border.all(
                        color: AppColors.accent500.withOpacity(0.25),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '—',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: AppColors.accent500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Show a sign to begin',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.s1),
                        Text(
                          'Position your hand in frame',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),

              // Action row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.abc_rounded, size: 18),
                      label: const Text('Alphabet'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s3,
                        ),
                        side: BorderSide(
                          color: AppColors.primary400.withOpacity(0.4),
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.lgBorder,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.translate_rounded, size: 18),
                      label: const Text('Words'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s3,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.lgBorder,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }
}

// ── Circle button ─────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: AppColors.white, size: 20),
      ),
    );
  }
}
