import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline, unknown }

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final _controller = StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get stream => _controller.stream;
  ConnectivityStatus _current = ConnectivityStatus.unknown;
  ConnectivityStatus get current => _current;
  bool get isOnline => _current == ConnectivityStatus.online;

  StreamSubscription? _subscription;

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _current = _mapResult(result);

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _current = _mapResult(result);
      _controller.add(_current);
    });
  }

  ConnectivityStatus _mapResult(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectivityStatus.offline;
    if (results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

// ── Riverpod provider ──────────────────────────────────────────────
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
      return ConnectivityNotifier();
    });

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier() : super(ConnectivityStatus.unknown) {
    _init();
  }

  StreamSubscription? _sub;

  Future<void> _init() async {
    final svc = ConnectivityService.instance;
    await svc.initialize();
    state = svc.current;
    _sub = svc.stream.listen((s) => state = s);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
