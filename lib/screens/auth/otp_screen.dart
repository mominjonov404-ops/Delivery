import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _otp = '';
  bool _loading = false;

  Future<void> _verify() async {
    if (_otp.length != 6) return;
    setState(() => _loading = true);
    try {
      final res = await ref.read(authServiceProvider).verifyOtp(widget.phone, _otp);
      if (res.session != null && mounted) {
        // Check if admin
        final supabase = ref.read(supabaseProvider);
        final profile = await supabase.from('profiles').select('role').eq('id', res.user!.id).single();
        if (mounted) {
          if (profile['role'] == 'admin') {
            context.go('/admin');
          } else {
            context.go('/home');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Kod noto\'g\'ri. Qayta urinib ko\'ring.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 56, height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('SMS kod', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('${widget.phone} raqamiga kod yuborildi',
                  style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              Center(
                child: Pinput(
                  length: 6,
                  defaultPinTheme: defaultTheme,
                  focusedPinTheme: defaultTheme.copyDecorationWith(
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  onCompleted: (val) { _otp = val; _verify(); },
                  onChanged: (val) => _otp = val,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Tasdiqlash'),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await ref.read(authServiceProvider).sendOtp(widget.phone);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kod qayta yuborildi')));
                  },
                  child: const Text('Kodni qayta yuborish', style: TextStyle(color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
