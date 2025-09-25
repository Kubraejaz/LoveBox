import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lovebox/constants/color.dart';
import 'package:lovebox/screens/banner_detail_screen.dart';
import '../models/banner_model.dart';
import '../services/banner_service.dart';

class BannerSection extends StatefulWidget {
  const BannerSection({super.key});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  late Future<List<BannerModel>> _bannerFuture;
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _bannerFuture = BannerService.fetchBanners().then((banners) {
      for (var b in banners) {
        debugPrint('🔗 Banner image URL: ${b.fullImageUrl}');
      }
      return banners;
    });
  }

  void _startAutoScroll(int itemCount) {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;
      _currentPage = (_currentPage + 1) % itemCount;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<BannerModel>>(
      future: _bannerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // ✅ Loader color changed to AppColors.primary (purple)
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary, // <-- purple loader
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 200,
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No banners found')),
          );
        }

        final banners = snapshot.data!;
        _startAutoScroll(banners.length);

        return SizedBox(
          height: 200,
          width: screenWidth,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BannerDetailScreen(banner: banner),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        banner.fullImageUrl,
                        fit: BoxFit.cover,
                        width: screenWidth,
                        errorBuilder:
                            (_, __, ___) => Image.asset(
                              'assets/images/banner_placeholder.png',
                              fit: BoxFit.cover,
                              width: screenWidth,
                            ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(banners.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: isActive ? 18 : 8,
                      decoration: BoxDecoration(
                        color:
                            isActive ? AppColors.primary : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
