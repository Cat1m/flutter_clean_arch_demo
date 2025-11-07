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
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/presentation/bloc/login_cubit.dart' as _i281;
import '../../features/user/presentation/bloc/user_cubit.dart' as _i434;
import '../../features/user/repository/user_repository.dart' as _i480;
import '../../features/user/repository/user_repository_impl.dart' as _i57;
import '../network/api_service.dart' as _i921;
import '../storage/secure_storage_service.dart' as _i666;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i666.SecureStorageService>(
      () => registerModule.storageService,
    );
    gh.lazySingleton<_i921.ApiService>(
      () => registerModule.getApiService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i480.UserRepository>(
      () => _i57.UserRepositoryImpl(gh<_i921.ApiService>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i921.ApiService>(),
        gh<_i666.SecureStorageService>(),
      ),
    );
    gh.factory<_i281.LoginCubit>(
      () => _i281.LoginCubit(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i434.UserCubit>(
      () => _i434.UserCubit(gh<_i480.UserRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
