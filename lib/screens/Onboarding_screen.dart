import 'package:flutter/material.dart';
import 'package:lovebox/screens/login_screen.dart';
import '../services/local_storage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'icon': Icons.card_giftcard,
      'title': 'LoveBox',
      'desc': 'Your favorite gifting app',
      'gradient': [Color(0xFFFF6B81), Color(0xFFFFC3A0)],
    },
    {
      'icon': Icons.favorite,
      'title': 'Share Love',
      'desc': 'Send gifts and love to friends',
      'gradient': [Color(0xFFFF6B81), Color(0xFFFFC3A0)],
    },
    {
      'icon': Icons.notifications,
      'title': 'Stay Updated',
      'desc': 'Never miss special moments',
      'gradient': [Color(0xFFFF6B81), Color(0xFFFFC3A0)],
    },
  ];

  Future<void> _completeOnboarding() async {
    await LocalStorage.setString('seenOnboarding', 'true');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final data = onboardingData[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: List<Color>.from(data['gradient']),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white24,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          data['icon'],
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        data['title'],
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['desc'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Bottom controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Prev Button
                ElevatedButton(
                  onPressed: _currentIndex > 0 ? _prevPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _currentIndex > 0 ? Colors.white : Colors.white24,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Prev'),
                ),

                // Dots Indicator in the middle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (dotIndex) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == dotIndex ? 12 : 8,
                      height: _currentIndex == dotIndex ? 12 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentIndex == dotIndex
                                ? Colors.white
                                : Colors.white38,
                      ),
                    ),
                  ),
                ),

                // Next / Get Started Button
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _currentIndex == onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
