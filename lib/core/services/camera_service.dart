import 'package:camera/camera.dart';

class CameraService {
  CameraService._();
  static final CameraService instance = CameraService._();

  List<CameraDescription> _cameras = [];
  CameraController? _controller;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize({bool useFrontCamera = true}) async {
    _cameras = await availableCameras();

    if (_cameras.isEmpty) {
      throw CameraException(
        'No cameras found',
        'No cameras available on this device',
      );
    }

    final camera = _cameras.firstWhere(
      (c) => useFrontCamera
          ? c.lensDirection == CameraLensDirection.front
          : c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    final currentDirection = _controller?.description.lensDirection;
    final newDirection = currentDirection == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    await dispose();
    await initialize(useFrontCamera: newDirection == CameraLensDirection.front);
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
