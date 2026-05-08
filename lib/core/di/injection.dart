import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:base_flutter/core/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureInjection() async {
  getIt.init();
}
