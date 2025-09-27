// lib/models/address_model.dart
class AddressModel {
  final String id;
  final String addressType;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.addressType,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.isDefault = false,
  });

  /// Factory to create from JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      addressType: json['address_type'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'] ?? '',
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address_type': addressType,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }

  /// ✅ copyWith for updating fields
  AddressModel copyWith({
    String? id,
    String? addressType,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      addressType: addressType ?? this.addressType,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
