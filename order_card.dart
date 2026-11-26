import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../utils/app_theme.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  const OrderCard({super.key, required this.order, required this.onTap});

  Color get _statusColor {
    switch (order.status) {
      case 'on_the_way': return AppColors.primary;
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(order.statusLabel, style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Expanded(child: Text(order.deliveryAddress, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          _ProgressBar(step: order.statusStep),
        ]),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int step;
  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(4, (i) {
      final done = i < step;
      final active = i == step;
      return Expanded(child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.success : active ? AppColors.primary : Colors.grey.shade200,
            boxShadow: active ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6, spreadRadius: 1)] : null,
          ),
        ),
        if (i < 3) Expanded(child: Container(height: 2, color: done ? AppColors.success : Colors.grey.shade200)),
      ]));
    }));
  }
}
