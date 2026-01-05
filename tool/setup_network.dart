// ignore_for_file: avoid_print

import 'dart:io';

/// Danh sách các package bắt buộc cho Module Network
const requiredDependencies = [
  'dio',
  'retrofit',
  'json_annotation',
  'equatable',
  'pretty_dio_logger',
  // Thêm injecttable nếu project dùng DI
  'injectable',
  'get_it',
];

/// Danh sách dev_dependencies bắt buộc
const requiredDevDependencies = [
  'retrofit_generator',
  'build_runner',
  'json_serializable',
  'injectable_generator',
];

void main() async {
  print('🌐 --- BẮT ĐẦU SETUP MODULE NETWORK ---');

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print(
      '❌ Lỗi: Không tìm thấy file pubspec.yaml. Hãy chạy script này ở thư mục gốc dự án.',
    );
    exit(1);
  }

  final String pubspecContent = await pubspecFile.readAsString();

  // 1. Kiểm tra và cài đặt Dependencies
  print('\n📦 Đang kiểm tra dependencies...');
  final List<String> missingDeps = [];
  for (var package in requiredDependencies) {
    if (!pubspecContent.contains('$package:')) {
      missingDeps.add(package);
    }
  }

  if (missingDeps.isEmpty) {
    print('✅ Các dependencies chính đã đầy đủ.');
  } else {
    print('⚠️ Thiếu: ${missingDeps.join(', ')}. Đang tự động cài đặt...');
    await _runPubAdd(missingDeps, isDev: false);
  }

  // 2. Kiểm tra và cài đặt Dev Dependencies
  print('\n🛠️ Đang kiểm tra dev_dependencies...');
  final List<String> missingDevDeps = [];
  for (var package in requiredDevDependencies) {
    if (!pubspecContent.contains('$package:')) {
      missingDevDeps.add(package);
    }
  }

  if (missingDevDeps.isEmpty) {
    print('✅ Các dev_dependencies đã đầy đủ.');
  } else {
    print('⚠️ Thiếu: ${missingDevDeps.join(', ')}. Đang tự động cài đặt...');
    await _runPubAdd(missingDevDeps, isDev: true);
  }

  print('\n🎉 --- MODULE NETWORK ĐÃ SẴN SÀNG! ---');
  print('👉 Bước tiếp theo: Chạy "dart run build_runner build" để sinh code.');
}

/// Hàm chạy lệnh flutter pub add
Future<void> _runPubAdd(List<String> packages, {required bool isDev}) async {
  if (packages.isEmpty) return;

  final args = ['pub', 'add'];
  if (isDev) args.add('--dev');
  args.addAll(packages);

  print('   Running: flutter ${args.join(' ')}');

  final result = await Process.run('flutter', args, runInShell: true);

  if (result.exitCode == 0) {
    print('   ✅ Cài đặt thành công.');
  } else {
    print('   ❌ Cài đặt thất bại:');
    print(result.stderr);
  }
}
