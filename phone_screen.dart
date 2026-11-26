import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});
  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  String _fullPhone = '';
  bool _loading = false;

  Future<void> _send() async {
    if (_fullPhone.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).sendOtp(_fullPhone);
      if (mounted) context.push('/auth/otp', extra: _fullPhone);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xato: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 24),
              const Text('Xush kelibsiz!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Davom etish uchun telefon raqamingizni kiriting',
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              IntlPhoneField(
                decoration: const InputDecoration(labelText: 'Telefon raqam', counterText: ''),
                initialCountryCode: 'UZ',
                onChanged: (p) => _fullPhone = p.completeNumber,
                onSubmitted: (_) => _send(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _send,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Kodni yuborish'),
              ),
              const Spacer(flex: 3),
              Center(
                child: Text('Davom etish orqali Foydalanish shartlariga rozilik bildirasiz',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
