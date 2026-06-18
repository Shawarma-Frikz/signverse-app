import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:hand_detection/hand_detection.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

class HandLandmarkService {
  HandLandmarkService._();
  static final HandLandmarkService instance = HandLandmarkService._();

  HandDetector? _detector;
  bool _isDetecting = false;

  Future<void> initialize() async {
    _detector = await HandDetector.create(
      mode: HandMode.boxesAndLandmarks,
      detectorConf: 0.5,
      minLandmarkScore: 0.5,
      performanceConfig: PerformanceConfig.xnnpack(),
    );
  }

  /// Converts a YUV420 CameraImage into a BGR cv.Mat, rotated and mirrored
  /// to match what's actually shown in the preview widget.
  cv.Mat _cameraImageToMat(
    CameraImage image, {
    required int sensorOrientation,
    required bool isFrontCamera,
  }) {
    final width = image.width;
    final height = image.height;

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final yRowStride = image.planes[0].bytesPerRow;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final nv21 = Uint8List(
      width * height + 2 * ((width + 1) ~/ 2) * ((height + 1) ~/ 2),
    );

    int idx = 0;
    for (int y = 0; y < height; y++) {
      final rowStart = y * yRowStride;
      for (int x = 0; x < width; x++) {
        nv21[idx++] = yPlane[rowStart + x];
      }
    }
    for (int y = 0; y < height ~/ 2; y++) {
      for (int x = 0; x < width ~/ 2; x++) {
        final uvIndex = y * uvRowStride + x * uvPixelStride;
        nv21[idx++] = vPlane[uvIndex];
        nv21[idx++] = uPlane[uvIndex];
      }
    }

    final yuvMat = cv.Mat.fromList(
      height + height ~/ 2,
      width,
      cv.MatType.CV_8UC1,
      nv21,
    );
    cv.Mat bgrMat = cv.cvtColor(yuvMat, cv.COLOR_YUV2BGR_NV21);
    yuvMat.dispose();

    // ── Rotate to match the preview orientation ───────────────────
    // Most Android devices report sensorOrientation 90 (back) or 270 (front).
    cv.Mat rotated;
    switch (sensorOrientation) {
      case 90:
        rotated = cv.rotate(bgrMat, cv.ROTATE_90_CLOCKWISE);
        bgrMat.dispose();
        break;
      case 180:
        rotated = cv.rotate(bgrMat, cv.ROTATE_180);
        bgrMat.dispose();
        break;
      case 270:
        rotated = cv.rotate(bgrMat, cv.ROTATE_90_COUNTERCLOCKWISE);
        bgrMat.dispose();
        break;
      default:
        rotated = bgrMat;
    }

    // ── Mirror horizontally for the front camera ───────────────────
    // CameraPreview already mirrors the front feed visually; the raw
    // sensor frame is NOT mirrored, so we flip it here to match what
    // the user sees on screen — otherwise landmark X coords are inverted.
    if (isFrontCamera) {
      final flipped = cv.flip(rotated, 1);
      rotated.dispose();
      return flipped;
    }

    return rotated;
  }

  /// Returns detected hands + flat list of 63 floats (21 landmarks × x,y,z)
  Future<({List<Hand> hands, List<double>? flatLandmarks})?> detect(
    CameraImage image, {
    required int sensorOrientation,
    required bool isFrontCamera,
  }) async {
    if (_detector == null || _isDetecting) return null;
    _isDetecting = true;

    cv.Mat? mat;
    try {
      mat = _cameraImageToMat(
        image,
        sensorOrientation: sensorOrientation,
        isFrontCamera: isFrontCamera,
      );
      final hands = await _detector!.detectOnMat(mat);

      if (hands.isEmpty || !hands.first.hasLandmarks) {
        return (hands: hands, flatLandmarks: null);
      }

      final flat = <double>[];
      for (final lm in hands.first.landmarks) {
        flat.addAll([lm.x, lm.y, lm.z]);
      }

      return (hands: hands, flatLandmarks: flat);
    } catch (_) {
      // Swallow transient per-frame errors (e.g. mid-switch) — never
      // let a single bad frame crash the stream.
      return null;
    } finally {
      mat?.dispose();
      _isDetecting = false;
    }
  }

  /// Fully tears down and recreates the detector. Call this on every
  /// camera switch — reusing a detector across a torn-down/rebuilt
  /// camera stream is what causes landmarks to silently stop appearing.
  Future<void> reset() async {
    await dispose();
    await initialize();
  }

  Future<void> dispose() async {
    await _detector?.dispose();
    _detector = null;
  }
}
