import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reqres_in/src/features/user/models/user_model.dart';
import 'package:reqres_in/src/features/user/presentation/bloc/user_cubit.dart';
import 'package:reqres_in/src/features/user/presentation/bloc/user_state.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  @override
  void initState() {
    super.initState();
    // Gọi fetchUser() ngay khi màn hình được khởi tạo
    context.read<UserCubit>().fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin Chi Tiết')),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          // Dùng switch expression (Dart 3)
          return switch (state) {
            // Case 1: Đang tải
            UserLoading() ||
            UserInitial() => const Center(child: CircularProgressIndicator()),

            // Case 2: Tải thất bại
            UserFailure(message: final msg) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Lỗi: $msg',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Case 3: Tải thành công
            UserSuccess(user: final user) => _buildSuccessView(context, user),
          };
        },
      ),
    );
  }

  // Tách view thành công ra cho gọn
  Widget _buildSuccessView(BuildContext context, User user) {
    // Dùng ListView để có thể cuộn
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildHeader(context, user), // Header (Ảnh, Tên)
        const SizedBox(height: 16),
        _buildPersonalInfo(context, user), // Thông tin cá nhân
        _buildAddressInfo(context, user.address), // Thông tin địa chỉ
        _buildCompanyInfo(context, user.company), // Thông tin công ty
        _buildBankInfo(context, user.bank), // Thông tin ngân hàng
        _buildCryptoInfo(context, user.crypto), // Thông tin crypto
        _buildSystemInfo(context, user), // Thông tin hệ thống
      ],
    );
  }

  // --- Các Widget con ---

  Widget _buildHeader(BuildContext context, User user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundImage: NetworkImage(user.image)),
            const SizedBox(height: 16),
            Text(
              '${user.firstName} ${user.lastName} (${user.maidenName})',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              '@${user.username} - Role: ${user.role}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context, User user) {
    return Card(
      child: ExpansionTile(
        title: const Text('Thông tin cá nhân'),
        leading: const Icon(Icons.person),
        initiallyExpanded: true, // Mở sẵn
        children: [
          _InfoTile(title: 'Email', value: user.email),
          _InfoTile(title: 'Điện thoại', value: user.phone),
          _InfoTile(title: 'Giới tính', value: user.gender),
          _InfoTile(title: 'Ngày sinh', value: user.birthDate),
          _InfoTile(title: 'Tuổi', value: user.age.toString()),
          _InfoTile(title: 'Nhóm máu', value: user.bloodGroup),
          _InfoTile(title: 'Chiều cao', value: '${user.height} cm'),
          _InfoTile(title: 'Cân nặng', value: '${user.weight} kg'),
          _InfoTile(title: 'Màu mắt', value: user.eyeColor),
          _InfoTile(
            title: 'Tóc',
            value: '${user.hair.color}, ${user.hair.type}',
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfo(BuildContext context, Address address) {
    return Card(
      child: ExpansionTile(
        title: const Text('Địa chỉ'),
        leading: const Icon(Icons.home),
        children: [
          _InfoTile(title: 'Địa chỉ', value: address.address),
          _InfoTile(title: 'Thành phố', value: address.city),
          _InfoTile(
            title: 'Tiểu bang',
            value: '${address.state} (${address.stateCode})',
          ),
          _InfoTile(title: 'Mã bưu điện', value: address.postalCode),
          _InfoTile(title: 'Quốc gia', value: address.country),
          _InfoTile(
            title: 'Toạ độ',
            value:
                'Lat: ${address.coordinates.lat}, Lng: ${address.coordinates.lng}',
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(BuildContext context, Company company) {
    return Card(
      child: ExpansionTile(
        title: const Text('Công ty'),
        leading: const Icon(Icons.business),
        children: [
          _InfoTile(title: 'Tên công ty', value: company.name),
          _InfoTile(title: 'Chức vụ', value: company.title),
          _InfoTile(title: 'Phòng ban', value: company.department),
          _InfoTile(
            title: 'Địa chỉ CTY',
            value: '${company.address.address}, ${company.address.city}',
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfo(BuildContext context, Bank bank) {
    return Card(
      child: ExpansionTile(
        title: const Text('Ngân hàng'),
        leading: const Icon(Icons.account_balance),
        children: [
          _InfoTile(title: 'Loại thẻ', value: bank.cardType),
          _InfoTile(title: 'Số thẻ', value: bank.cardNumber),
          _InfoTile(title: 'Hết hạn', value: bank.cardExpire),
          _InfoTile(title: 'Tiền tệ', value: bank.currency),
          _InfoTile(title: 'IBAN', value: bank.iban),
        ],
      ),
    );
  }

  Widget _buildCryptoInfo(BuildContext context, Crypto crypto) {
    return Card(
      child: ExpansionTile(
        title: const Text('Crypto'),
        leading: const Icon(Icons.currency_bitcoin),
        children: [
          _InfoTile(title: 'Coin', value: crypto.coin),
          _InfoTile(title: 'Ví', value: crypto.wallet),
          _InfoTile(title: 'Mạng lưới', value: crypto.network),
        ],
      ),
    );
  }

  Widget _buildSystemInfo(BuildContext context, User user) {
    return Card(
      child: ExpansionTile(
        title: const Text('Thông tin hệ thống'),
        leading: const Icon(Icons.computer),
        children: [
          _InfoTile(title: 'Địa chỉ IP', value: user.ip),
          _InfoTile(title: 'MAC Address', value: user.macAddress),
          _InfoTile(title: 'SSN', value: user.ssn),
          _InfoTile(title: 'EIN', value: user.ein),
          _InfoTile(
            title: 'User Agent',
            value: user.userAgent,
            isMultiline: true,
          ),
        ],
      ),
    );
  }
}

// Widget tái sử dụng để hiển thị thông tin
class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final bool isMultiline;

  const _InfoTile({
    required this.title,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        value,
        maxLines: isMultiline ? 5 : 2,
        overflow: TextOverflow.ellipsis,
      ),
      dense: true,
    );
  }
}
