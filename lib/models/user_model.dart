import 'address_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;
  final List<AddressModel> addresses;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.addresses = const [],
  });

  /// ✅ Returns the default address if one is marked,
  /// otherwise the first address, or null if none exist.
  AddressModel? get defaultAddress {
    if (addresses.isEmpty) return null;
    try {
      return addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
    } catch (_) {
      return addresses.first;
    }
  }

  /// ✅ Build from JSON, tolerating null/absent fields
  factory UserModel.fromJson(Map<String, dynamic> json, {String token = ''}) {
    // Defensive parsing for the addresses list
    final List<AddressModel> parsedAddresses = (json['addresses'] is List)
        ? (json['addresses'] as List)
            .whereType<Map<String, dynamic>>()
            .map((a) => AddressModel.fromJson(a))
            .toList()
        : [];

    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      token: token.isNotEmpty ? token : (json['token']?.toString() ?? ''),
      addresses: parsedAddresses,
    );
  }

  /// ✅ Convert to JSON (useful for updates)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'addresses': addresses.map((a) => a.toJson()).toList(),
    };
  }

  /// ✅ Create a copy with selective overrides
  UserModel copyWith({
    String? name,
    String? email,
    String? token,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      addresses: addresses ?? this.addresses,
    );
  }
}
