# PDF Core Module

Module xử lý tạo, xem và chia sẻ PDF theo chuẩn Clean Architecture.  
Hỗ trợ: Tiếng Việt (Unicode), Ảnh, Link/QR, Table, View đẹp (Syncfusion).

---

## 1. Dependencies (pubspec.yaml)

Copy các dòng sau vào `dependencies` của dự án mới:

```yaml
dependencies:
  # Core PDF Engine
  pdf: ^3.10.0
  printing: ^5.11.0       # Hỗ trợ in ấn & Share
  path_provider: ^2.1.2   # Để lưu file tạm
  http: ^1.2.0            # Để tải ảnh từ mạng vào PDF

  # UI Viewer (Optional - Nếu dùng view đẹp)
  syncfusion_flutter_pdfviewer: ^24.1.41
  share_plus: ^10.0.0

  # Utils
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  injectable: ^2.3.2      # Nếu dùng DI
  get_it: ^7.6.0
```

---

## 2. Setup Assets (Quan trọng)

1. Tạo thư mục `assets/fonts/` trong dự án.

2. Tải font Roboto (Regular, Bold, Italic) bỏ vào đó.

3. Khai báo trong `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/fonts/Roboto-Regular.ttf
    - assets/fonts/Roboto-Bold.ttf
    - assets/fonts/Roboto-Italic.ttf
```

**Lưu ý:** Kiểm tra lại đường dẫn trong file `infrastructure/pdf_font_helper.dart` nếu tên file khác.

---

## 3. Cấu hình DI

### Cách 1: Sử dụng Injectable (Khuyến nghị)

Nếu dự án dùng injectable, hãy thêm vào `RegisterModule` (thường ở `core/di/register_module.dart`):

```dart
@module
abstract class RegisterModule {
  // Đăng ký Singleton cho PdfFontHelper
  @singleton
  PdfFontHelper get pdfFontHelper => PdfFontHelper.instance;
}
```

Trong `main.dart`, kích hoạt tải font chạy ngầm (Fire & Forget):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  // Kích hoạt load font ngay lập tức (không await)
  getIt<PdfFontHelper>().init(); 

  runApp(const MyApp());
}
```

### Cách 2: Chỉ dùng GetIt (Không dùng Injectable)

**Bước 1:** Xóa các annotation Injectable trong file `pdf_service_impl.dart`:

```dart
// XÓA dòng này
// @LazySingleton(as: IPdfService)

// XÓA import này
// import 'package:injectable/injectable.dart';

class PdfServiceImpl implements IPdfService {
  // ... code như cũ
}
```

**Bước 2:** Đăng ký thủ công trong `main.dart`:

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Đăng ký services
  getIt.registerLazySingleton<IPdfService>(() => PdfServiceImpl());
  getIt.registerSingleton<PdfFontHelper>(PdfFontHelper.instance);
  
  // Kích hoạt load font
  getIt<PdfFontHelper>().init();

  runApp(const MyApp());
}
```

### Cách 3: Không dùng DI (Đơn giản nhất)

**Bước 1:** Xóa các annotation Injectable trong file `pdf_service_impl.dart` (như Cách 2).

**Bước 2:** Tạo instance trực tiếp khi cần:

```dart
// Trong Widget hoặc Controller
final pdfService = PdfServiceImpl();

// Load font một lần khi app khởi động
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Kích hoạt load font
  PdfFontHelper.instance.init();

  runApp(const MyApp());
}
```

---

## 4. Cách sử dụng

### 4.1. Tạo PDF Service

```dart
// CÁCH 1: Dùng DI (Injectable hoặc GetIt)
final IPdfService pdfService = getIt<IPdfService>();

// CÁCH 2: Không dùng DI
final pdfService = PdfServiceImpl();

// Chuẩn bị ảnh (nếu có)
final avatar = await PdfImageHelper.loadNetworkImage('https://...');

// Gọi hàm generate
final result = await pdfService.generatePdf(
  fileName: 'my_document',
  config: const PdfConfigModel(isPortrait: true),
  builder: (config) => MyTemplate.generate( // Gọi Template của bạn
    config: config,
    data: myData,
    image: avatar,
  ),
);
```

### 4.2. Xử lý kết quả

```dart
switch (result) {
  case PdfSuccess(:final file):
    // Mở viewer hoặc share
    break;
  case PdfFailure(:final message):
    // Hiện lỗi
    break;
}
```

---

## 5. Lưu ý quan trọng (Troubleshooting)

### Lỗi: RenderBox was not laid out khi Back từ màn hình View

Đây là lỗi xung đột giữa Syncfusion PDF Viewer và Animation chuyển trang của Flutter.

**Giải pháp:** Dùng cơ chế "Safe Back" - Ẩn PDF đi trước khi `Navigator.pop()`.

```dart
// Code mẫu trong Widget chứa SfPdfViewer
void _onSafeBack() {
  setState(() => _isShowPdf = false); // Ẩn PDF thay bằng SizedBox
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (mounted) Navigator.of(context).pop(); // Sau đó mới pop
  });
}

// Bọc Scaffold bằng PopScope để chặn nút Back vật lý
return PopScope(
  canPop: false,
  onPopInvoked: (didPop) {
    if (didPop) return;
    _onSafeBack();
  },
  child: Scaffold(...),
);
```

### Lỗi: Font hiển thị ô vuông

**Nguyên nhân:** Font chưa load xong hoặc sai đường dẫn assets.

**Giải pháp:** `PdfFontHelper` đã có cơ chế Backup tải từ mạng, nhưng hãy đảm bảo file assets local là chính xác để app chạy nhanh nhất.

---

## License