class AddressModel {
  final String id;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.isDefault = false,
  });

  /// ✅ Safely parse any backend format:
  ///    - bool
  ///    - int (0/1)
  ///    - string ("true"/"false")
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawDefault = json['is_default'];

    bool parsedDefault;
    if (rawDefault is bool) {
      parsedDefault = rawDefault;
    } else if (rawDefault is int) {
      parsedDefault = rawDefault == 1;
    } else if (rawDefault is String) {
      parsedDefault = rawDefault.toLowerCase() == 'true' || rawDefault == '1';
    } else {
      parsedDefault = false;
    }

    return AddressModel(
      id: (json['id'] ?? '').toString(),
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      isDefault: parsedDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }

  /// Optional helper for easy updates
  AddressModel copyWith({
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
