import 'package:lovebox/constants/network_storage.dart';

class BannerModel {
  final int id;
  final String title;
  final String image; // relative path from API
  final String link;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    required this.link,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      link: json['link'],
    );
  }

  /// Full URL for displaying the banner image.
  /// 👉 Use 10.0.2.2 if running on Android emulator,
  /// or your PC's LAN IP (e.g., 192.168.x.x) for a real device.
  String get fullImageUrl =>'${NetworkStorage.baseUrl}$image';
}
