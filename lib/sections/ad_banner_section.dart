import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/color.dart'; // ✅ import your AppColors

class AdBannerSection extends StatefulWidget {
  const AdBannerSection({super.key});

  @override
  State<AdBannerSection> createState() => _AdBannerSectionState();
}

class _AdBannerSectionState extends State<AdBannerSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  final List<String> _ads = [
    "https://static.wixstatic.com/media/3ad585_cf06f8adcbc6439e9282864495596c9d~mv2.jpg/v1/fill/w_620,h_376,al_c/3ad585_cf06f8adcbc6439e9282864495596c9d~mv2.jpg",
    "https://diyjoy.com/wp-content/uploads/2020/10/DIY-Christmas-Gift-Bag-1024x537.jpg",
    "https://smileycookie.com/cdn/shop/collections/valentines-day-cookies-gifts-448805_1350x534.webp?v=1744831648",
    "https://www.shutterstock.com/image-photo/vase-beautiful-rose-flowers-engagement-600w-2553244971.jpg",
    "https://www.sugar.org/wp-content/uploads/Birthday-Cake-1.png",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-g1r-FJdSLj1tutWzRtnDpiQAjsCzgZSG4Q&s",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ9aHAu2z-TRW0OdAJjptgz1Mv8BOx1zAzsoA&s",
    "https://thumbs.dreamstime.com/b/elegant-gold-watch-presented-gift-box-festive-decorations-shiny-rests-cushioned-display-inside-warm-blurred-395336071.jpg",
    "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=1200&q=80",
    "https://www.shutterstock.com/image-photo/set-colorful-realistic-mat-helium-600nw-2370477249.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _ads.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Slider
          PageView.builder(
            controller: _pageController,
            itemCount: _ads.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    _ads[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              );
            },
          ),

          // Animated Dots Indicator
          Positioned(
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _ads.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index
                            ? AppColors
                                .primary // ✅ using your primary color
                            : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
