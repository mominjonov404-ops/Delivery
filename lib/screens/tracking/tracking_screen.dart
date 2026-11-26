import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/order_service.dart';
import '../../utils/app_theme.dart';

class TrackingScreen extends ConsumerWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orderId == 'none') {
      return Scaffold(
        appBar: AppBar(title: const Text('Kuzatish')),
        body: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.location_searching_rounded, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Faol buyurtma yo\'q', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          ]),
        ),
      );
    }

    final orderAsync = ref.watch(orderServiceProvider);
    return FutureBuilder(
      future: orderAsync.getOrder(orderId),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final order = snap.data;
        if (order == null) return const Scaffold(body: Center(child: Text('Buyurtma topilmadi')));

        return Scaffold(
          appBar: AppBar(title: Text(order.orderNumber)),
          body: Column(children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.map_outlined, size: 48, color: Colors.white38),
                    SizedBox(height: 12),
                    Text('Xarita bu yerda\n(Google Maps API key kerak)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ]),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(order.statusLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  if (order.estimatedMinutes != null)
                    Text('${order.estimatedMinutes} daqiqa qoldi', style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 16),
                _InfoRow(icon: Icons.radio_button_checked_rounded, label: 'Olish joyi', value: order.pickupAddress, color: AppColors.primary),
                const SizedBox(height: 10),
                _InfoRow(icon: Icons.location_on_rounded, label: 'Yetkazish joyi', value: order.deliveryAddress, color: AppColors.error),
                const SizedBox(height: 16),
                Row(children: [
                  const Text('Jami:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const Spacer(),
                  Text('${order.totalPrice.toStringAsFixed(0)} so\'m', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary)),
                ]),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: color, size: 18),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    ])),
  ]);
}
