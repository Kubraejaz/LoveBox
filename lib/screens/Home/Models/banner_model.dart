import '../../../constants/network_storage.dart';   // ✅ Import your NetworkStorage

class BannerModel {
  final int id;
  final String? title;
  final String? description;
  final String? image;      // API may return null
  final String? link;
  final String? startDate;
  final String? endDate;

  BannerModel({
    required this.id,
    this.title,
    this.description,
    this.image,
    this.link,
    this.startDate,
    this.endDate,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'],
      description: json['description'],
      image: json['image'],
      link: json['link'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  /// ✅ Safely build the full URL using NetworkStorage.baseUrl
  String get fullImageUrl {
    if (image == null || image!.isEmpty) return '';
    return '${NetworkStorage.baseUrl}$image';
  }

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $title, description: $description, image: $image, link: $link, startDate: $startDate, endDate: $endDate)';
  }
}
