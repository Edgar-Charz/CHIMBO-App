import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The phone's clock. A provider, so tests can move time by hand.
final phoneClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The server's time, worked out from the phone's: the state is how far the phone's clock is
/// behind the server (`server − phone`). Learned once per app start from the first API answer's
/// HTTP `Date` header, so countdowns stay right on a phone whose clock is wrong.
class ServerClock extends Notifier<Duration> {
  bool _isSynced = false;

  @override
  Duration build() => Duration.zero;

  DateTime now() => ref.read(phoneClockProvider)().add(state);

  /// Remembers the gap to [serverTime]; only the first call counts (one sync per app start).
  void sync(DateTime serverTime) {
    if (_isSynced) {
      return;
    }
    _isSynced = true;
    state = serverTime.difference(ref.read(phoneClockProvider)());
  }
}

final serverClockProvider = NotifierProvider<ServerClock, Duration>(
  ServerClock.new,
);
