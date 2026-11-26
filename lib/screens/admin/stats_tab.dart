import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class StatsTab extends ConsumerStatefulWidget {
  const StatsTab({super.key});
  @override
  ConsumerState<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<StatsTab> {
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final sb = ref.read(supabaseProvider);
    final all = await sb.from('orders').select('id');
    final delivered = await sb.from('orders').select('id').eq('status', 'delivered');
    final pending = await sb.from('orders').select('id').eq('status', 'pending');
    final customers = await sb.from('profiles').select('id').eq('role', 'customer');
    final online = await sb.from('drivers').select('id').eq('is_online', true);
    if (mounted) {
      setState(() {
        _stats = {
          'all': (all as List).length,
          'delivered': (delivered as List).length,
          'pending': (pending as List).length,
          'customers': (customers as List).length,
          'online': (online as List).length,
        };
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Statistika', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
            children: [
              _StatCard(label: 'Jami buyurtma', value: '${_stats['all'] ?? 0}', icon: Icons.receipt_long_rounded, color: AppColors.primary),
              _StatCard(label: 'Yetkazildi', value: '${_stats['delivered'] ?? 0}', icon: Icons.check_circle_outline_rounded, color: AppColors.success),
              _StatCard(label: 'Kutilmoqda', value: '${_stats['pending'] ?? 0}', icon: Icons.hourglass_empty_rounded, color: AppColors.amber),
              _StatCard(label: 'Mijozlar', value: '${_stats['customers'] ?? 0}', icon: Icons.people_outline_rounded, color: const Color(0xFF8B5CF6)),
              _StatCard(label: 'Online haydovchi', value: '${_stats['online'] ?? 0}', icon: Icons.local_shipping_rounded, color: AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 24),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
  );
}
