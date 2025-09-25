import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../constants/color.dart';

class BannerDetailScreen extends StatelessWidget {
  final BannerModel banner;

  const BannerDetailScreen({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Softer off-white background
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 2,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          banner.title ?? 'Banner Detail',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Banner Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                banner.fullImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 240,
                errorBuilder:
                    (_, __, ___) => Image.asset(
                      'assets/images/banner_placeholder.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 240,
                    ),
              ),
            ),
            const SizedBox(height: 15), // ⬇️ slightly less space
            // 🏷 Banner Name — smaller & softer
            Text(
              banner.title ?? 'Untitled',
              style: const TextStyle(
                fontSize: 23, // ⬇️ reduced size
                fontWeight: FontWeight.w700,
                color: Colors.black87, // softer black
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 5), // ⬇️ less gap before description
            // 📝 Description
            if (banner.description != null && banner.description!.isNotEmpty)
              Text(
                banner.description!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

            const SizedBox(height: 20), // ⬇️ slightly less than before
            // ℹ️ Card-style Info Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoTile('ID', banner.id.toString()),
                  if (banner.link != null && banner.link!.isNotEmpty)
                    _infoTile('Link', banner.link!),
                  if (banner.startDate != null)
                    _infoTile('Start Date', banner.startDate.toString()),
                  if (banner.endDate != null)
                    _infoTile('End Date', banner.endDate.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Info Tile
  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
