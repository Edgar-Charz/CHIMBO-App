import 'package:chimbo/core/network/network_providers.dart';
import 'package:chimbo/core/storage/preferences_provider.dart';
import 'package:chimbo/features/app_images/data/api_app_images_repository.dart';
import 'package:chimbo/features/app_images/data/app_images_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appImagesRepositoryProvider = Provider<AppImagesRepository>(
  (ref) => ApiAppImagesRepository(
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
  ),
);
