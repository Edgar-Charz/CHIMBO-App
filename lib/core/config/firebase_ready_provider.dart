import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase stays optional locally until this Android app is registered in the Firebase project.
final firebaseReadyProvider = Provider<bool>((ref) => false);
