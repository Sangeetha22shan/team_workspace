import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

/// ConnectivityBloc wraps connectivity_plus and exposes an easy-to-listen
/// bloc for the app. It emits ConnectedState/DisconnectedState and keeps
/// a simple stream subscription internally.
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity connectivity;
  late final StreamSubscription<dynamic> _sub;

  ConnectivityBloc({required this.connectivity}) : super(ConnectivityInitial()) {
    on<StartListeningEvent>(_onStartListening);
    on<_ConnectivityChangedEvent>(_onConnectivityChanged);

    // start listening immediately
    add(const StartListeningEvent());
  }

  Future<void> _onStartListening(StartListeningEvent event, Emitter<ConnectivityState> emit) async {
    _sub = connectivity.onConnectivityChanged.listen((result) {
      add(_ConnectivityChangedEvent(result));
    });

    // emit current status once
    final current = await connectivity.checkConnectivity();
    add(_ConnectivityChangedEvent(current));
  }

  void _onConnectivityChanged(_ConnectivityChangedEvent event, Emitter<ConnectivityState> emit) {
    // Normalize result which may be a single ConnectivityResult or a List
    final raw = event.result;
    ConnectivityResult? result;
    if (raw is ConnectivityResult) {
      result = raw;
    } else if (raw is List && raw.isNotEmpty && raw.first is ConnectivityResult) {
      result = raw.first as ConnectivityResult;
    }

    final connected = result != null && result != ConnectivityResult.none;
    if (connected) {
      emit(ConnectivityConnected());
    } else {
      emit(ConnectivityDisconnected());
    }
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}

