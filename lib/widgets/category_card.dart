import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final colorHex = (category['color'] as String).replaceFirst('#', '');
    final color = Color(int.parse('FF$colorHex', radix: 16));

    return GestureDetector(
      onTap: () => context.go('/home'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(category['icon'] ?? '📦', style: const TextStyle(fontSize: 28)),
          const Spacer(),
          Text(category['name_uz'] ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color.withOpacity(0.9))),
        ]),
      ),
    );
  }
}
