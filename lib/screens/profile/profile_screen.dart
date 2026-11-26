import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: profileAsync.when(
        data: (profile) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(profile?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                Text(profile?.fullName ?? 'Foydalanuvchi', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                Text(profile?.phone ?? '', style: const TextStyle(color: AppColors.textSecondary)),
              ]),
            ),
            const SizedBox(height: 32),
            _Tile(icon: Icons.person_outline_rounded, label: 'Ma\'lumotlarni tahrirlash', onTap: () {}),
            _Tile(icon: Icons.notifications_none_rounded, label: 'Bildirishnomalar', onTap: () {}),
            _Tile(icon: Icons.help_outline_rounded, label: 'Yordam', onTap: () {}),
            _Tile(icon: Icons.policy_outlined, label: 'Foydalanish shartlari', onTap: () {}),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Chiqish', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
              onTap: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go('/auth/phone');
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: Colors.white,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _Tile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor: Colors.white,
    ),
  );
}
