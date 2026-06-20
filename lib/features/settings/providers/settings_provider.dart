import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/tts_service.dart';

// ── Keys ───────────────────────────────────────────────────────────
const _kThemeMode = 'settings_theme_mode'; // 0=dark 1=light 2=system
const _kLanguage = 'settings_language'; // en / fr / ar
const _kTtsSpeed = 'settings_tts_speed'; // 0.1–0.9
const _kTtsPitch = 'settings_tts_pitch'; // 0.5–2.0
const _kTtsEnabled = 'settings_tts_enabled';
const _kHaptic = 'settings_haptic';
const _kConfThreshold = 'settings_conf_threshold'; // 0.50–0.95
const _kFrontCamera = 'settings_front_camera';
const _kShowLandmarks = 'settings_show_landmarks';

// ── State ──────────────────────────────────────────────────────────
class SettingsState {
  final int themeMode; // 0=dark 1=light 2=system
  final String language; // en / fr / ar
  final double ttsSpeed;
  final double ttsPitch;
  final bool ttsEnabled;
  final bool hapticEnabled;
  final double confThreshold;
  final bool useFrontCamera;
  final bool showLandmarks;
  final bool isLoading;

  const SettingsState({
    this.themeMode = 0,
    this.language = 'en',
    this.ttsSpeed = 0.5,
    this.ttsPitch = 1.0,
    this.ttsEnabled = true,
    this.hapticEnabled = true,
    this.confThreshold = 0.70,
    this.useFrontCamera = true,
    this.showLandmarks = true,
    this.isLoading = true,
  });

  SettingsState copyWith({
    int? themeMode,
    String? language,
    double? ttsSpeed,
    double? ttsPitch,
    bool? ttsEnabled,
    bool? hapticEnabled,
    double? confThreshold,
    bool? useFrontCamera,
    bool? showLandmarks,
    bool? isLoading,
  }) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    ttsSpeed: ttsSpeed ?? this.ttsSpeed,
    ttsPitch: ttsPitch ?? this.ttsPitch,
    ttsEnabled: ttsEnabled ?? this.ttsEnabled,
    hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    confThreshold: confThreshold ?? this.confThreshold,
    useFrontCamera: useFrontCamera ?? this.useFrontCamera,
    showLandmarks: showLandmarks ?? this.showLandmarks,
    isLoading: isLoading ?? this.isLoading,
  );
}

// ── Notifier ───────────────────────────────────────────────────────
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      themeMode: prefs.getInt(_kThemeMode) ?? 0,
      language: prefs.getString(_kLanguage) ?? 'en',
      ttsSpeed: prefs.getDouble(_kTtsSpeed) ?? 0.5,
      ttsPitch: prefs.getDouble(_kTtsPitch) ?? 1.0,
      ttsEnabled: prefs.getBool(_kTtsEnabled) ?? true,
      hapticEnabled: prefs.getBool(_kHaptic) ?? true,
      confThreshold: prefs.getDouble(_kConfThreshold) ?? 0.70,
      useFrontCamera: prefs.getBool(_kFrontCamera) ?? true,
      showLandmarks: prefs.getBool(_kShowLandmarks) ?? true,
      isLoading: false,
    );

    // Sync TTS service with loaded settings
    await TtsService.instance.initialize();
    await TtsService.instance.setRate(state.ttsSpeed);
    await TtsService.instance.setPitch(state.ttsPitch);
    TtsService.instance.setEnabled(state.ttsEnabled);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeMode, state.themeMode);
    await prefs.setString(_kLanguage, state.language);
    await prefs.setDouble(_kTtsSpeed, state.ttsSpeed);
    await prefs.setDouble(_kTtsPitch, state.ttsPitch);
    await prefs.setBool(_kTtsEnabled, state.ttsEnabled);
    await prefs.setBool(_kHaptic, state.hapticEnabled);
    await prefs.setDouble(_kConfThreshold, state.confThreshold);
    await prefs.setBool(_kFrontCamera, state.useFrontCamera);
    await prefs.setBool(_kShowLandmarks, state.showLandmarks);
  }

  // ── Setters ────────────────────────────────────────────────────
  Future<void> setThemeMode(int mode) async {
    state = state.copyWith(themeMode: mode);
    await _save();
  }

  Future<void> setLanguage(String lang) async {
    state = state.copyWith(language: lang);
    await _save();
  }

  Future<void> setTtsSpeed(double speed) async {
    state = state.copyWith(ttsSpeed: speed);
    await TtsService.instance.setRate(speed);
    await _save();
  }

  Future<void> setTtsPitch(double pitch) async {
    state = state.copyWith(ttsPitch: pitch);
    await TtsService.instance.setPitch(pitch);
    await _save();
  }

  Future<void> setTtsEnabled(bool enabled) async {
    state = state.copyWith(ttsEnabled: enabled);
    TtsService.instance.setEnabled(enabled);
    await _save();
  }

  Future<void> setHaptic(bool enabled) async {
    state = state.copyWith(hapticEnabled: enabled);
    await _save();
  }

  Future<void> setConfThreshold(double threshold) async {
    state = state.copyWith(confThreshold: threshold);
    await _save();
  }

  Future<void> setFrontCamera(bool front) async {
    state = state.copyWith(useFrontCamera: front);
    await _save();
  }

  Future<void> setShowLandmarks(bool show) async {
    state = state.copyWith(showLandmarks: show);
    await _save();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (_) => SettingsNotifier(),
);

// Theme mode as a derived provider for MaterialApp
final themeModeProvider = Provider<int>((ref) {
  return ref.watch(settingsProvider).themeMode;
});
