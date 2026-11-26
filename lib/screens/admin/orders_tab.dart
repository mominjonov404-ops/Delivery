import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class OrdersTab extends ConsumerStatefulWidget {
  const OrdersTab({super.key});
  @override
  ConsumerState<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<OrdersTab> {
  List _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final sb = ref.read(supabaseProvider);
    final data = await sb.from('orders')
        .select('*, profiles!customer_id(full_name, phone)')
        .order('created_at', ascending: false);
    if (mounted) setState(() { _orders = data as List; _loading = false; });
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'pending': return AppColors.amber;
      case 'accepted': case 'picked_up': return AppColors.primary;
      case 'on_the_way': return const Color(0xFF8B5CF6);
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String _statusLabel(String? s) {
    switch (s) {
      case 'pending': return 'Kutilmoqda';
      case 'accepted': return 'Qabul';
      case 'picked_up': return "Yig'ildi";
      case 'on_the_way': return "Yo'lda";
      case 'delivered': return 'Yetkazildi';
      case 'cancelled': return 'Bekor';
      default: return s ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: _orders.isEmpty
          ? const Center(child: Text("Buyurtmalar yo'q"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _orders.length,
              itemBuilder: (c, i) {
                final o = _orders[i];
                final statusColor = _statusColor(o['status']);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    title: Text(o['order_number'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(o['profiles']?['full_name'] ?? o['profiles']?['phone'] ?? '', style: const TextStyle(fontSize: 12)),
                      Text(DateFormat('d MMM HH:mm').format(DateTime.parse(o['created_at'])),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ]),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(_statusLabel(o['status']),
                            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 2),
                      Text("${(o['total_price'] ?? 0).toStringAsFixed(0)} so'm",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                    onTap: () async {
                      await showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        builder: (_) => _OrderDetailSheet(order: o, supabase: ref.read(supabaseProvider)),
                      );
                      _load();
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final Map order;
  final SupabaseClient supabase;
  const _OrderDetailSheet({required this.order, required this.supabase});

  Future<void> _updateStatus(BuildContext ctx, String newStatus) async {
    await supabase.from('orders').update({'status': newStatus}).eq('id', order['id']);
    if (ctx.mounted) Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    final statuses = ['pending', 'accepted', 'picked_up', 'on_the_way', 'delivered', 'cancelled'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(order['order_number'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('📍 ${order['pickup_address']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text('🏁 ${order['delivery_address']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        const Text("Holatni o'zgartirish:", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: statuses.map((s) => ActionChip(
          label: Text(s, style: const TextStyle(fontSize: 12)),
          backgroundColor: order['status'] == s ? AppColors.primary : null,
          labelStyle: TextStyle(color: order['status'] == s ? Colors.white : null),
          onPressed: () => _updateStatus(context, s),
        )).toList()),
      ]),
    );
  }
}
