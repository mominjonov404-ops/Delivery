import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class UsersTab extends ConsumerStatefulWidget {
  const UsersTab({super.key});
  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<UsersTab> {
  List _users = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ref.read(supabaseProvider)
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    if (mounted) setState(() { _users = data as List; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: _users.isEmpty
          ? const Center(child: Text("Foydalanuvchilar yo'q"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _users.length,
              itemBuilder: (c, i) {
                final u = _users[i];
                final roleColor = u['role'] == 'admin'
                    ? AppColors.error
                    : u['role'] == 'driver'
                        ? AppColors.primary
                        : AppColors.secondary;
                final initials = ((u['full_name'] ?? u['phone'] ?? '?') as String)
                    .substring(0, 1).toUpperCase();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(u['full_name'] ?? u['phone'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(u['phone'] ?? '',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(u['role'] ?? '',
                          style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
