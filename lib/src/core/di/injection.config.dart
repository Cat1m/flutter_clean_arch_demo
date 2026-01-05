// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_client.dart' as _i190;
import '../../features/auth/presentation/bloc/login_cubit.dart' as _i281;
import '../../features/auth/repository/auth_repository.dart' as _i871;
import '../../features/auth/repository/auth_repository_impl.dart' as _i932;
import '../../features/quote/cubit/quote_cubit.dart' as _i422;
import '../../features/quote/repositories/quote_repository.dart' as _i48;
import '../../features/quote/repositories/quote_repository_impl.dart' as _i922;
import '../../features/user/data/datasources/user_client.dart' as _i840;
import '../../features/user/presentation/bloc/user_cubit.dart' as _i434;
import '../../features/user/repository/user_repository.dart' as _i480;
import '../../features/user/repository/user_repository_impl.dart' as _i57;
import '../auth/interceptors/auth_interceptor.dart' as _i164;
import '../auth/interceptors/token_interceptor.dart' as _i823;
import '../auth/service/auth_event_service.dart' as _i671;
import '../navigation/router_module.dart' as _i358;
import '../../shared/data/remote/api_service.dart' as _i921;
import '../network/dio_client.dart' as _i667;
import '../network/file_upload_service.dart' as _i307;
import '../network/logger_interceptor.dart' as _i51;
import '../service/network_service.dart' as _i724;
import '../storage/secure_storage_service.dart' as _i666;
import '../storage/settings_service.dart' as _i112;
import '../theme/theme_manager/theme_cubit.dart' as _i381;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final routerModule = _$RouterModule();
    gh.lazySingleton<_i671.AuthEventService>(() => _i671.AuthEventService());
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i583.GoRouter>(() => routerModule.router);
    gh.lazySingleton<_i51.LoggerInterceptor>(() => _i51.LoggerInterceptor());
    gh.lazySingleton<_i724.NetworkService>(() => _i724.NetworkService());
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.SecureStorageService(),
    );
    gh.lazySingleton<_i112.SettingsService>(
      () => _i112.SettingsService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i164.AuthInterceptor>(
      () => _i164.AuthInterceptor(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i381.ThemeCubit>(
      () => _i381.ThemeCubit(gh<_i112.SettingsService>()),
    );
    gh.lazySingleton<_i823.TokenInterceptor>(
      () => _i823.TokenInterceptor(
        gh<_i666.SecureStorageService>(),
        gh<_i671.AuthEventService>(),
      ),
    );
    gh.lazySingleton<_i667.DioClient>(
      () => registerModule.dioClient(
        gh<_i164.AuthInterceptor>(),
        gh<_i823.TokenInterceptor>(),
        gh<_i51.LoggerInterceptor>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(gh<_i667.DioClient>()),
    );
    gh.lazySingleton<_i921.ApiService>(
      () => registerModule.apiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i190.AuthClient>(
      () => registerModule.authClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i840.UserClient>(
      () => registerModule.userClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i307.FileUploadService>(
      () => _i307.FileUploadService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i48.QuoteRepository>(
      () => _i922.QuoteRepositoryImpl(gh<_i921.ApiService>()),
    );
    gh.factory<_i422.QuoteCubit>(
      () => _i422.QuoteCubit(gh<_i48.QuoteRepository>()),
    );
    gh.lazySingleton<_i871.AuthRepository>(
      () => _i932.AuthRepositoryImpl(
        gh<_i921.ApiService>(),
        gh<_i666.SecureStorageService>(),
        gh<_i112.SettingsService>(),
      ),
    );
    gh.lazySingleton<_i480.UserRepository>(
      () => _i57.UserRepositoryImpl(gh<_i921.ApiService>()),
    );
    gh.singleton<_i281.LoginCubit>(
      () => _i281.LoginCubit(
        gh<_i871.AuthRepository>(),
        gh<_i671.AuthEventService>(),
      ),
    );
    gh.factory<_i434.UserCubit>(
      () => _i434.UserCubit(gh<_i480.UserRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$RouterModule extends _i358.RouterModule {}
