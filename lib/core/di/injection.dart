import 'package:get_it/get_it.dart';
import 'package:base_flutter/core/config/flavor_config.dart';

final getIt = GetIt.instance;

Future<void> configureInjection() async {
  // Register FlavorConfig as a singleton
  // This allows accessing environment values via DI: getIt<FlavorConfig>()
  if (FlavorConfig.isInitialized) {
    getIt.registerSingleton<FlavorConfig>(FlavorConfig.instance);
  }

  // Add other registrations here
  // Example: getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
}
