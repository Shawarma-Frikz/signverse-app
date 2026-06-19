import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused }

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  TtsState state = TtsState.stopped;
  bool _initialized = false;

  // Settings
  double _volume = 1.0;
  double _pitch = 1.0;
  double _rate = 0.5;
  bool _enabled = true;

  bool get isEnabled => _enabled;
  bool get isPlaying => state == TtsState.playing;

  Future<void> initialize() async {
    if (_initialized) return;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(_rate);
    await _tts.setVolume(_volume);
    await _tts.setPitch(_pitch);

    // Android specific — use the highest quality engine available
    await _tts.setQueueMode(1);

    _tts.setStartHandler(() => state = TtsState.playing);
    _tts.setCompletionHandler(() => state = TtsState.stopped);
    _tts.setCancelHandler(() => state = TtsState.stopped);
    _tts.setErrorHandler((_) => state = TtsState.stopped);

    _initialized = true;
  }

  // ── Speak ──────────────────────────────────────────────────────
  Future<void> speak(String text) async {
    if (!_enabled || text.trim().isEmpty) return;
    await initialize();

    if (state == TtsState.playing) await stop();
    await _tts.speak(text.trim());
  }

  // ── Speak a single letter ──────────────────────────────────────
  Future<void> speakLetter(String letter) async {
    if (!_enabled) return;
    await speak(letter);
  }

  // ── Speak a full sentence ──────────────────────────────────────
  Future<void> speakSentence(String sentence) async {
    if (!_enabled || sentence.trim().isEmpty) return;
    await speak(sentence);
  }

  Future<void> stop() async {
    await _tts.stop();
    state = TtsState.stopped;
  }

  Future<void> pause() async {
    await _tts.pause();
    state = TtsState.paused;
  }

  // ── Settings ───────────────────────────────────────────────────
  void setEnabled(bool value) => _enabled = value;

  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.1, 1.0);
    await _tts.setSpeechRate(_rate);
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _tts.setPitch(_pitch);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _tts.setVolume(_volume);
  }

  Future<List<String>> getAvailableLanguages() async {
    final langs = await _tts.getLanguages;
    return (langs as List).map((e) => e.toString()).toList();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
