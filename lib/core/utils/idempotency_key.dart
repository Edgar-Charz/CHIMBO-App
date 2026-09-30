import 'dart:math';

/// A random 32-character hex key for the `Idempotency-Key` header: the server runs a request
/// only once per key, so a retried "Thibitisha Oda" never creates a second order.
String newIdempotencyKey({Random? random}) {
  final source = random ?? Random.secure();
  return [
    for (var i = 0; i < 16; i++)
      source.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}
