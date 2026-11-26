import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class DriversTab extends ConsumerStatefulWidget {
  const DriversTab({super.key});
  @override
  ConsumerState<DriversTab> createState() => _DriversTabState();
}

class _DriversTabState extends ConsumerState<DriversTab> {
  List _drivers = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ref.read(supabaseProvider)
        .from('drivers')
        .select('*, profiles(full_name, phone, is_active)')
        .order('created_at', ascending: false);
    if (mounted) setState(() { _drivers = data as List; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: _drivers.isEmpty
          ? const Center(child: Text("Haydovchilar yo'q"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _drivers.length,
              itemBuilder: (c, i) {
                final d = _drivers[i];
                final online = d['is_online'] == true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: online ? AppColors.success.withOpacity(0.1) : Colors.grey.shade100,
                      child: Icon(Icons.person_rounded, color: online ? AppColors.success : AppColors.textSecondary),
                    ),
                    title: Text(d['profiles']?['full_name'] ?? d['profiles']?['phone'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      "${d['vehicle_model']} · ${d['vehicle_plate']}\nReyting: ${d['rating']} · ${d['total_deliveries']} yetkazuv",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: online ? AppColors.success.withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(online ? 'Online' : 'Offline',
                          style: TextStyle(
                              color: online ? AppColors.success : AppColors.textSecondary,
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
