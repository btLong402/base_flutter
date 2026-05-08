// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:base_flutter/core/base/config/environment.dart' as _i230;
import 'package:base_flutter/core/base/context/app_context.dart' as _i697;
import 'package:base_flutter/core/base/network/cookies/app_cookie_manager.dart'
    as _i420;
import 'package:base_flutter/core/base/network/dio/dio_client.dart' as _i778;
import 'package:base_flutter/core/base/services/biometric_service.dart'
    as _i275;
import 'package:base_flutter/core/base/storage/secure_storage.dart' as _i851;
import 'package:base_flutter/core/base/storage/token_storage.dart' as _i628;
import 'package:base_flutter/core/base/storage/user_preferences.dart' as _i373;
import 'package:base_flutter/core/di/core_module.dart' as _i586;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_auth/local_auth.dart' as _i152;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    await gh.factoryAsync<_i420.AppCookieManager>(
      () => coreModule.cookieManager,
      preResolve: true,
    );
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i697.AppContext>(() => _i697.AppContext());
    gh.lazySingleton<_i230.AppEnvironment>(() => coreModule.environment);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => coreModule.secureStorage,
    );
    gh.lazySingleton<_i152.LocalAuthentication>(
      () => coreModule.localAuthentication,
    );
    gh.lazySingleton<_i628.TokenStorage>(
      () => coreModule.tokenStorage(gh<_i420.AppCookieManager>()),
    );
    gh.lazySingleton<_i275.BiometricService>(
      () => _i275.BiometricService(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i152.LocalAuthentication>(),
      ),
    );
    gh.lazySingleton<_i851.SecureStorage>(
      () => _i851.SecureStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i373.UserPreferences>(
      () => coreModule.userPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i778.DioClient>(
      () => coreModule.dioClient(
        gh<_i230.AppEnvironment>(),
        gh<_i420.AppCookieManager>(),
        gh<_i628.TokenStorage>(),
        gh<_i373.UserPreferences>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(() => coreModule.dio(gh<_i778.DioClient>()));
    return this;
  }
}

class _$CoreModule extends _i586.CoreModule {}
