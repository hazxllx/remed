import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

class OnboardingScreen extends StatefulWidget {
  final String? username;
  const OnboardingScreen({super.key, this.username});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'assets/ob_bg1.png',
      'title': 'Welcome to Remed',
      'subtitle': 'Your personal medicine assistant.',
      'layout': 'stacked',
      'bg': const LinearGradient(
        colors: [Color(0xFFFFF4F4), Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    },
    {
      'image': 'assets/ob_bg2.png',
      'title': 'Quick Setup',
      'subtitle': 'Add your meds and times.\nWe’ll do the reminding.',
      'layout': 'leftImage',
      'bg': const LinearGradient(
        colors: [Colors.white, Color(0xFFFFF0F0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'image': 'assets/ob_bg3.png',
      'title': 'Stay on Track',
      'subtitle': 'Healthy habits, made easy.',
      'layout': 'imageBottom',
      'bg': const LinearGradient(
        colors: [Color(0xFFFFF0F0), Colors.white],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
    },
  ];

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingShown', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(username: widget.username ?? 'User'),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Widget _buildPage(Map<String, dynamic> page, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final layout = page['layout'] ?? 'stacked';
    final bg = page['bg'];

    Widget image = Image.asset(page['image'], width: 250);
    Widget title = Text(
      page['title'],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.redAccent,
      ),
    );
    Widget subtitle = Text(
      page['subtitle'],
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    );

    Widget content;
    switch (layout) {
      case 'leftImage':
        content = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: image),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 12), subtitle],
              ),
            ),
          ],
        );
        break;

      case 'imageBottom':
        content = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            title,
            const SizedBox(height: 16),
            subtitle,
            const SizedBox(height: 30),
            image,
          ],
        );
        break;

      case 'stacked':
      default:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            image,
            const SizedBox(height: 30),
            title,
            const SizedBox(height: 16),
            subtitle,
          ],
        );
        break;
    }

    return Container(
      width: size.width,
      decoration: BoxDecoration(
        gradient: bg is LinearGradient ? bg : null,
        color: bg is Color ? bg : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              Expanded(
                child: Center(child: content),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == i ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? Colors.redAccent
                          : Colors.redAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // ✅ White text here
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], context);
            },
          ),
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
