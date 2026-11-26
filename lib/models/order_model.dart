class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String pickupAddress;
  final String deliveryAddress;
  final double price;
  final double deliveryFee;
  final double totalPrice;
  final int? estimatedMinutes;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.price,
    required this.deliveryFee,
    required this.totalPrice,
    required this.estimatedMinutes,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double numberValue(Object? value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      pickupAddress: json['pickup_address']?.toString() ?? '',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      price: numberValue(json['price']),
      deliveryFee: numberValue(json['delivery_fee']),
      totalPrice: numberValue(json['total_price']),
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get statusLabel => switch (status) {
        'pending' => 'Kutilmoqda',
        'accepted' => 'Qabul qilindi',
        'picked_up' => 'Olib ketildi',
        'on_the_way' => 'Yo‘lda',
        'delivered' => 'Yetkazildi',
        'cancelled' => 'Bekor qilindi',
        _ => status,
      };

  int get statusStep => switch (status) {
        'pending' => 0,
        'accepted' => 1,
        'picked_up' => 2,
        'on_the_way' => 3,
        'delivered' => 4,
        _ => 0,
      };
}
