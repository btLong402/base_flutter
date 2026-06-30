# Flutter Base Project (`base_flutter`)

Một dự án Flutter Base chuẩn hóa, hiệu năng cao và sẵn sàng cho môi trường Productive (Production-ready). Dự án được thiết kế theo các nguyên tắc **Clean Architecture**, tối ưu hóa hiệu năng, bảo mật và cung cấp một hệ sinh thái widget đáp ứng (Responsive) & thích ứng (Adaptive) thông minh.

Dự án này đóng vai trò làm khung xương (boilerplate/starter kit) giúp các dự án mới bỏ qua giai đoạn cấu hình nền tảng và tập trung ngay vào phát triển Business Logic với chất lượng code cao nhất.

---

## 🚀 Tính Năng Nổi Bật

### 📱 1. Hệ thống Responsive & Adaptive Layout thế hệ mới
- **`AppScaleBuilder`**: Tự động scale kích thước UI (`.w`, `.h`, `.sp`, `.r` qua ScreenUtil) dựa trên kích thước thiết kế gốc (Figma) cho cả Điện thoại (Phone) và Máy tính bảng (Tablet). Hỗ trợ đảo chiều kích thước thông minh khi xoay màn hình để tránh lỗi layout.
- **`BaseResponsivePage`**: Lớp cơ sở (Base Page) hỗ trợ xây dựng trang responsive cực kỳ nhanh chóng và an toàn.
  - Phân chia các điểm ngắt (breakpoints) chuẩn: **Watch** (<320dp), **Mobile** (<600dp), **Tablet** (<1024dp), **Desktop** (>=1024dp), **DesktopXl** (>=1440dp).
  - **Hỗ trợ xoay màn hình không boilerplate**: Sử dụng phương thức xây dựng mặc định (ví dụ: `buildMobile`) làm giao diện dọc (Portrait) và `buildMobileLandscape` làm giao diện ngang (Landscape). Bạn chỉ cần định nghĩa đúng 2 phương thức thay vì phải tạo thêm phương thức Portrait.
  - **Cơ chế Fallback thông minh**: Tự động thu nhỏ giao diện từ màn hình lớn xuống màn hình nhỏ hơn nếu các màn hình lớn không được triển khai (ví dụ: Desktop -> Tablet -> Mobile).
  - **Hook-safe**: Tương thích hoàn toàn với Flutter Hooks & Riverpod, ngăn ngừa việc khởi tạo lại hoặc lỗi vòng lặp Hook.

### 📐 2. Kiến Trúc Phát Triển Chuẩn Hóa (Clean Architecture)
Dự án được cấu trúc chặt chẽ theo mô hình **Clean Architecture** (Presentation -> Domain -> Data) kết hợp với **Riverpod Notifier**:
- **`BaseState<T>`**: Quản lý vòng đời trạng thái của UI (Initial, Loading, Success, Error) thông qua Class đóng gói dạng Freezed.
- **`BaseNotifier<S>`**: Lớp quản lý logic trình diễn (StateNotifier) tích hợp sẵn cơ chế chạy tác vụ bất tuần tự `runTask` giúp xử lý trạng thái tự động và map lỗi thành chuỗi tin nhắn thân thiện với người dùng.
- **`BaseRepository`**: Lớp cơ sở xử lý dữ liệu ở tầng Data, cung cấp hàm `execute` giúp tự động bắt các ngoại lệ (DioException, v.v.) và ánh xạ thành các đối tượng `Failure` định danh (ServerFailure, NetworkFailure...).
- **`UseCase<Type, Params>`**: Quy chuẩn hóa các tác vụ nghiệp vụ đơn lẻ ở tầng Domain, sử dụng mô hình lập trình hàm (Functional Programming) với kiểu trả về `Either<Failure, Type>` thông qua thư viện `Dartz`.

### 💾 3. Hệ Thống Lưu Trữ (Storage) & Cache
Phân chia phân vùng dữ liệu lưu trữ theo mức độ bảo mật:
- **`SecureStorage`**: Lưu trữ an toàn các thông tin nhạy cảm (JWT Token, Private Keys) thông qua `flutter_secure_storage` với thuật toán mã hóa AES.
- **`LocalStorage`**: Cache dữ liệu ứng dụng hiệu năng cao sử dụng `Hive` (Hive CE), tự động mã hóa box và lưu trữ các cấu hình chung không nhạy cảm.
- **`TokenStorage`**: Quản lý lưu trữ Access Token và Refresh Token, tích hợp cơ chế tự động làm mới token (Auto-Refresh) khi phát hiện lỗi 401 Unauthorized thông qua Dio Interceptor.
- **`UserPreferences`**: Lưu trữ tùy chọn người dùng như ngôn ngữ hiển thị (localization) hay chế độ sáng tối (theme).

### 🌐 4. Tầng Giao Tiếp Mạng (Network Layer)
- Sử dụng **Dio** làm HTTP client lõi, tích hợp tự động cấu hình Timeout, Header, Cookies.
- Thiết lập hệ thống Interceptors mạnh mẽ:
  - **AuthInterceptor**: Tự động chèn Bearer token vào các request yêu cầu xác thực và thực hiện Refresh Token đồng bộ (synchronized) để tránh trùng lặp cuộc gọi API khi token hết hạn.
  - **ConnectivityInterceptor**: Chặn các cuộc gọi mạng ngay lập tức nếu thiết bị mất kết nối internet, trả về lỗi ngoại tuyến thân thiện.
  - **DioCacheInterceptor**: Tự động cache các API dạng GET vào cơ sở dữ liệu Hive để hỗ trợ ngoại tuyến (Offline-first).
- **Retrofit**: Hỗ trợ tạo mã nguồn giao tiếp HTTP (Rest API Client) an toàn kiểu dữ liệu (Type-safe).

### 🛡️ 5. Các Dịch Vụ Nền Tảng (Base Services)
- **`PasskeyService`**: Đăng nhập không mật khẩu hiện đại thông qua công nghệ FIDO2 WebAuthn (Passkey) kết hợp sinh trắc học thiết bị (FaceID / Vân tay).
- **`FCMService`**: Quản lý đăng ký thiết bị nhận thông báo đẩy Firebase Cloud Messaging, xử lý sự kiện click mở app từ thông báo khi app đang chạy hoặc đã tắt.
- **`LocalNotiService`**: Cấu hình và hiển thị thông báo nội bộ (Local Notifications) trên thanh trạng thái với giao diện tùy chỉnh và hỗ trợ đính kèm payload.

### 🎨 6. Bộ Widget Tái Sử Dụng Phong Phú
Hệ thống UI Component chất lượng cao sẵn có tại `lib/core/base/widgets/`:
- **Input & Selection**: `AppTextField` chuẩn hóa hỗ trợ validation, `AppSearchBar` tích hợp debounce, `FormPickerTile` hỗ trợ chọn từ BottomSheet.
- **Lists & Scroll**: `InfiniteScroll` bọc ngoài ListView để phân trang tự động, `GenericShimmer` để làm Skeleton loading.
- **Navigation & Images**: `BottomNavBar` tùy chỉnh dạng nổi, `CustomImage` tự động fallback giữa Network, Asset, SVG và cache ngoại tuyến.
- **Feedback**: Hệ thống `ToastNotification` chuẩn Figma, màn hình `AppEmptyWidget` cho các trạng thái không có dữ liệu.

---

## 📁 Cấu Trúc Thư Mục Dự Án

Thực hiện theo mô hình **Feature-first Clean Architecture** kết hợp hệ thống Core chia sẻ:

```
lib/
├── core/
│   ├── base/               # Cấu hình môi trường (Dev/Staging/Prod), Base Services & Widgets
│   │   ├── app/            # Bootstrapping và khởi chạy App
│   │   ├── config/         # Environment variables & constants
│   │   ├── error/          # Định nghĩa Exceptions và Failures
│   │   ├── extensions/     # Các hàm mở rộng hữu dụng (String, BuildContext...)
│   │   ├── network/        # Cấu hình Dio, Interceptors, SSL Pinning, Sockets
│   │   ├── services/       # FCM, Local Notification, Passkey, v.v.
│   │   ├── storage/        # SecureStorage, LocalStorage (Hive)
│   │   ├── theme/          # Hệ thống Design Tokens (Colors, Typography, Dimensions)
│   │   └── widgets/        # Hệ thống widgets dùng chung (ResponsivePage, Shimmer, v.v.)
│   ├── gen/                # Tài nguyên được tự động sinh (Assets, Fonts, L10n)
│   └── l10n/               # Đa ngôn ngữ (i18n / Localization)
├── features/               # Các module chức năng của ứng dụng (Auth, Home, v.v.)
│   └── home/
│       ├── data/           # Models, Repositories, DataSources
│       ├── domain/         # Entities, UseCases
│       └── presentation/   # Pages, Widgets, Notifiers/ViewModels
└── main.dart
```

---

## 📐 Hướng Dẫn Lập Trình Theo Quy Chuẩn (Showcase)

Dưới đây là quy chuẩn phát triển một tính năng theo mô hình Clean Architecture được base hỗ trợ sẵn:

### 1. Định nghĩa thực thể (Domain Entity & UseCase)
```dart
// 1. Params cho UseCase
class ProductParams extends Params {
  final String productId;
  const ProductParams(this.productId);

  @override
  List<Object?> get props => [productId];
}

// 2. Định nghĩa UseCase giao tiếp tầng Domain
class GetProductDetailUseCase implements UseCase<Product, ProductParams> {
  final ProductRepository repository;
  GetProductDetailUseCase(this.repository);

  @override
  FutureResult<Product> call(ProductParams params) {
    return repository.getProductDetail(params.productId);
  }
}
```

### 2. Triển khai tầng Dữ Liệu (Data Repository & DataSource)
```dart
class ProductRepositoryImpl extends BaseRepository implements ProductRepository {
  final ProductRemoteDataSource remote;
  ProductRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Product>> getProductDetail(String id) {
    // Hàm `execute` trong BaseRepository tự động bắt DioException và trả về Failure
    return execute(() => remote.fetchProduct(id));
  }
}
```

### 3. Trạng thái & Notifier ở tầng Trình Diễn (Presentation State & Notifier)
```dart
// Định nghĩa State cho UI thừa kế từ BaseState
typedef ProductDetailState = BaseState<Product>;

class ProductDetailNotifier extends BaseNotifier<ProductDetailState> {
  final GetProductDetailUseCase getProductDetail;
  
  ProductDetailNotifier(this.getProductDetail) : super(const BaseState.initial());

  Future<void> fetchProduct(String id) async {
    // Hàm `runTask` quản lý toàn bộ vòng đời loading -> success/error
    await runTask<Product>(
      task: getProductDetail(ProductParams(id)),
      onLoading: () => state = const BaseState.loading(),
      onSuccess: (product) => state = BaseState.success(product),
      onError: (message) => state = BaseState.error(message),
    );
  }
}
```

### 4. Giao diện người dùng (UI Page)
```dart
class ProductDetailPage extends ConsumerWidget {
  final String productId;
  const ProductDetailPage(this.productId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe trạng thái
    final detailState = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
      body: detailState.when(
        initial: () => const Center(child: Text('Đang chuẩn bị...')),
        loading: () => const Center(child: CircularProgressIndicator()),
        success: (product) => ProductDetailWidget(product: product),
        error: (message) => Center(child: Text('Đã xảy ra lỗi: $message')),
      ),
    );
  }
}
```

---

## 🛠️ Hướng Dẫn Cài Đặt & Phát Triển

### 1. Quản lý phiên bản Flutter với FVM
Dự án sử dụng **FVM (Flutter Version Management)** để đồng bộ phiên bản SDK ổn định (`stable`).

Khởi chạy môi trường SDK qua FVM:
```bash
# Cài đặt Flutter SDK được cấu hình trong dự án
fvm install

# Chạy lệnh Flutter thông qua FVM
fvm flutter pub get
```

### 2. Các lệnh sinh code tự động (Code Generation)
Dự án tích hợp `build_runner` để tự động tạo mã nguồn cho Models (JSON), Retrofit API, Envied (Biến môi trường) và Freezed:

```bash
# Tạo mã nguồn một lần
fvm dart run build_runner build --delete-conflicting-outputs

# Lắng nghe thay đổi và tự động tạo mã nguồn liên tục
fvm dart run build_runner watch --delete-conflicting-outputs
```

### 3. Quy chuẩn viết code & Kiểm tra chất lượng (Lints & Format)
Trước khi commit mã nguồn lên Git, bạn bắt buộc phải định dạng và phân tích cú pháp để đảm bảo chất lượng code:

```bash
# Định dạng toàn bộ mã nguồn theo quy chuẩn Dart
fvm dart format .

# Phân tích cú pháp cảnh báo lỗi linter (bắt buộc sửa hết các cảnh báo)
fvm flutter analyze .

# Chạy toàn bộ Unit/Widget Tests
fvm flutter test
```

---

## 💡 Hướng dẫn sử dụng `BaseResponsivePage` mới

Khi phát triển trang mới, bạn kế thừa từ `BaseResponsivePage` thay vì `ConsumerWidget` thông thường. Hệ thống sẽ tự động cung cấp môi trường Responsive tối ưu:

```dart
import 'package:base_flutter/core/base/widgets/base_responsive_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyFeaturePage extends BaseResponsivePage {
  const MyFeaturePage({super.key});

  // 1. Giao diện mặc định dọc (Portrait) cho Mobile (Bắt buộc)
  @override
  Widget buildMobile(BuildContext context, WidgetRef ref, BoxConstraints constraints) {
    return const Center(
      child: Text('Mobile Portrait / Default View'),
    );
  }

  // 2. Giao diện xoay ngang (Landscape) cho Mobile (Không bắt buộc)
  @override
  Widget? buildMobileLandscape(BuildContext context, WidgetRef ref, BoxConstraints constraints) {
    return const Center(
      child: Text('Mobile Landscape View'),
    );
  }

  // 3. Giao diện cho Tablet (Không bắt buộc, tự động fallback về Mobile nếu null)
  @override
  Widget? buildTablet(BuildContext context, WidgetRef ref, BoxConstraints constraints) {
    return const Center(
      child: Text('Tablet View'),
    );
  }
}
```

---
*Chúc bạn có trải nghiệm lập trình Flutter tuyệt vời với bộ base này!*
