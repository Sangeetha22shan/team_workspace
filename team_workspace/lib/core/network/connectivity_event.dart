part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent {
  const ConnectivityEvent();
}

class StartListeningEvent extends ConnectivityEvent {
  const StartListeningEvent();
}


class _ConnectivityChangedEvent extends ConnectivityEvent {
  final Object result;
  const _ConnectivityChangedEvent(this.result);
}

