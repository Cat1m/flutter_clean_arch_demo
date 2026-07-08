import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/crypto/pin_lock_service.dart';
import 'package:reqres_in/src/core/di/injection.dart';
import 'package:reqres_in/src/core/logging/app_logger.dart';
import 'package:reqres_in/src/features/user/presentation/widgets/pin_pad_dialog.dart';

const _maxWrongPinAttempts = 5;
const _tag = 'PinLockedWalletTile';

/// Ô hiển thị 1 giá trị nhạy cảm (giống số tài khoản), mặc định bị che.
/// Người dùng phải nhập đúng PIN 6 số để xem — khoá giải mã được derive
/// trực tiếp từ PIN đó (xem [PinLockService]), không lưu PIN ở đâu cả.
class PinLockedWalletTile extends StatefulWidget {
  const PinLockedWalletTile({required this.walletValue, super.key});

  final String walletValue;

  @override
  State<PinLockedWalletTile> createState() => _PinLockedWalletTileState();
}

class _PinLockedWalletTileState extends State<PinLockedWalletTile> {
  final _pinLockService = getIt<PinLockService>();

  String? _revealedValue;
  int _wrongAttempts = 0;

  bool get _isRevealed => _revealedValue != null;

  Future<void> _onEyeTap() async {
    if (_isRevealed) {
      AppLogger.debug('👁️ Ẩn lại giá trị', tag: _tag);
      setState(() => _revealedValue = null);
      return;
    }

    if (await _pinLockService.isPinSet) {
      AppLogger.debug('👁️ Bấm hiện — đã có PIN, mở luồng xác thực', tag: _tag);
      await _verifyAndReveal();
    } else {
      AppLogger.debug('👁️ Bấm hiện — chưa có PIN, mở luồng đặt PIN mới', tag: _tag);
      await _setupPinAndReveal();
    }
  }

  Future<void> _setupPinAndReveal() async {
    if (!mounted) return;
    final pin = await showPinPadDialog(context, title: 'Đặt mã PIN mới');
    if (pin == null || pin.length != 6) {
      AppLogger.debug('🚫 Huỷ đặt PIN', tag: _tag);
      return;
    }

    if (!mounted) return;
    final confirmPin = await showPinPadDialog(context, title: 'Nhập lại mã PIN');
    if (confirmPin != pin) {
      AppLogger.warning('⚠️ 2 mã PIN nhập không khớp', tag: _tag);
      if (mounted) _showMessage('2 mã PIN không khớp, thử lại.');
      return;
    }

    await _pinLockService.setPinAndProtect(pin, widget.walletValue);
    AppLogger.debug('👁️ Hiện giá trị vừa được bảo vệ', tag: _tag);
    if (mounted) setState(() => _revealedValue = widget.walletValue);
  }

  Future<void> _verifyAndReveal() async {
    if (!mounted) return;
    final pin = await showPinPadDialog(context, title: 'Nhập mã PIN để xem');
    if (pin == null) {
      AppLogger.debug('🚫 Huỷ nhập PIN', tag: _tag);
      return;
    }

    final revealed = await _pinLockService.verifyPinAndReveal(pin);
    if (revealed == null) {
      _wrongAttempts++;
      AppLogger.warning(
        '❌ Sai PIN — lần thử $_wrongAttempts/$_maxWrongPinAttempts',
        tag: _tag,
      );
      if (_wrongAttempts >= _maxWrongPinAttempts) {
        await _pinLockService.resetPin();
        _wrongAttempts = 0;
        if (mounted) _showMessage('Sai PIN quá nhiều lần, đã đặt lại mã PIN.');
      } else if (mounted) {
        _showMessage('Sai mã PIN.');
      }
      return;
    }

    AppLogger.debug('👁️ PIN đúng, hiện giá trị', tag: _tag);
    _wrongAttempts = 0;
    if (mounted) setState(() => _revealedValue = revealed);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Ví', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        _isRevealed ? _revealedValue! : '•' * 12,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(_isRevealed ? Icons.visibility_off : Icons.visibility),
        onPressed: _onEyeTap,
      ),
      dense: true,
    );
  }
}
