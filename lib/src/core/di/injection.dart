// lib/src/core/di/injection.dart
import 'package:get_it/get_it.dart';

import 'package:injectable/injectable.dart';
import 'injection.config.dart'; // File này sẽ được tự động sinh ra

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => await getIt.init();
