class ProfileModel {
  final String id;
  final String phone;
  final String? fullName;
  final String? avatarUrl;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  const ProfileModel({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.avatarUrl,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      role: json['role']?.toString() ?? 'customer',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  String get initials {
    final value = fullName?.trim() ?? '';
    if (value.isEmpty) return phone.isNotEmpty ? phone.substring(0, 1) : '?';
    final parts = value.split(RegExp(r'\s+'));
    return parts.take(2).map((part) => part.isEmpty ? '' : part.substring(0, 1).toUpperCase()).join();
  }
}
