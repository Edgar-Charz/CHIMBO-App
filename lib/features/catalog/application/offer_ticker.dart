import 'package:chimbo/core/time/server_clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One shared tick per second, giving the server's time, for every offer countdown on screen
/// (no timer per card). `autoDispose`: once no countdown listens (no offer on screen) Riverpod
/// cancels the stream, so nothing ticks in the background.
final offerTickerProvider = StreamProvider.autoDispose<DateTime>((ref) {
  final clock = ref.watch(serverClockProvider.notifier);
  return Stream.periodic(const Duration(seconds: 1), (_) => clock.now());
});
