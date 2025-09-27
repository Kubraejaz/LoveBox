import 'address_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password; // ✅ added password
  final String token;
  final List<AddressModel> addresses; // ✅ list of addresses

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.token,
    this.addresses = const [],
  });

  /// Getter for default address
  AddressModel? get defaultAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }

  /// Parse JSON from API
  factory UserModel.fromJson(Map<String, dynamic> json, {String token = ''}) {
    List<AddressModel> addresses = [];
    if (json['addresses'] is List) {
      addresses =
          (json['addresses'] as List)
              .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
              .toList();
    }

    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '', // parse password if available
      token: token.isNotEmpty ? token : (json['token'] ?? ''),
      addresses: addresses,
    );
  }

  /// Convert model to JSON for storage or API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password, // include password
      'token': token,
      'addresses': addresses.map((a) => a.toJson()).toList(),
    };
  }

  /// CopyWith method to create updated copies
  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    String? token,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password, // include password
      token: token ?? this.token,
      addresses: addresses ?? this.addresses,
    );
  }
}
