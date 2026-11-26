import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import 'auth_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService(ref.watch(supabaseProvider)));

final activeOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final svc = ref.watch(orderServiceProvider);
  return svc.watchActiveOrders();
});

final orderHistoryProvider = FutureProvider<List<OrderModel>>((ref) async {
  final svc = ref.watch(orderServiceProvider);
  return svc.getOrderHistory();
});

class OrderService {
  final SupabaseClient _client;
  OrderService(this._client);

  Stream<List<OrderModel>> watchActiveOrders() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('customer_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows
            .where((r) => !['delivered', 'cancelled'].contains(r['status']))
            .map((r) => OrderModel.fromJson(r))
            .toList());
  }

  Future<List<OrderModel>> getOrderHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final data = await _client
        .from('orders')
        .select()
        .eq('customer_id', userId)
        .inFilter('status', ['delivered', 'cancelled'])
        .order('created_at', ascending: false);
    return data.map((r) => OrderModel.fromJson(r)).toList();
  }

  Future<OrderModel> createOrder({
    required String categoryId,
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String deliveryAddress,
    required double deliveryLat,
    required double deliveryLng,
    String? description,
    double price = 0,
  }) async {
    final userId = _client.auth.currentUser?.id;
    final data = await _client.from('orders').insert({
      'customer_id': userId,
      'category_id': categoryId,
      'pickup_address': pickupAddress,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'delivery_address': deliveryAddress,
      'delivery_lat': deliveryLat,
      'delivery_lng': deliveryLng,
      'description': description,
      'price': price,
    }).select().single();
    return OrderModel.fromJson(data);
  }

  Future<void> cancelOrder(String orderId) async {
    await _client.from('orders').update({
      'status': 'cancelled',
      'cancelled_reason': 'Mijoz tomonidan bekor qilindi',
    }).eq('id', orderId).eq('status', 'pending');
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final data = await _client.from('orders').select().eq('id', orderId).maybeSingle();
    return data == null ? null : OrderModel.fromJson(data);
  }
}
