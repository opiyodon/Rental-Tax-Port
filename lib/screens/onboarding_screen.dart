import 'package:flutter/material.dart';
import 'package:rental_tax_port/screens/auth/login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Smart Rental Management",
      "description":
          "Take control of your rental properties with our intelligent management system. Track income, expenses, and profits in real-time.",
      "svg": '''
<svg viewBox="0 0 200 200">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4CAF50;stop-opacity:0.8" />
      <stop offset="100%" style="stop-color:#81C784;stop-opacity:0.9" />
    </linearGradient>
  </defs>
  <rect x="40" y="40" width="120" height="120" rx="8" fill="url(#grad1)"/>
  <rect x="50" y="50" width="100" height="80" rx="4" fill="white" opacity="0.9"/>
  <rect x="60" y="70" width="80" height="8" rx="2" fill="#4CAF50"/>
  <rect x="60" y="90" width="60" height="8" rx="2" fill="#4CAF50"/>
  <circle cx="60" cy="120" r="15" fill="#4CAF50"/>
  <path d="M55 120l5 5l10-10" stroke="white" stroke-width="2" fill="none"/>
</svg>''',
    },
    {
      "title": "Automated Tax Calculations",
      "description":
          "Never worry about tax calculations again. Our system automatically computes your rental income taxes and generates reports.",
      "svg": '''
<svg viewBox="0 0 200 200">
  <defs>
    <linearGradient id="grad2" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF9800;stop-opacity:0.8" />
      <stop offset="100%" style="stop-color:#FFB74D;stop-opacity:0.9" />
    </linearGradient>
  </defs>
  <rect x="40" y="40" width="120" height="120" rx="8" fill="url(#grad2)"/>
  <path d="M60 80h80M60 100h60M60 120h40" stroke="white" stroke-width="4" stroke-linecap="round"/>
  <circle cx="150" cy="150" r="30" fill="white"/>
  <path d="M150 135v30M135 150h30" stroke="#FF9800" stroke-width="4" stroke-linecap="round"/>
</svg>''',
    },
    {
      "title": "Complete Property Oversight",
      "description":
          "Monitor tenant details, lease agreements, and maintenance schedules all in one place. Stay organized and efficient.",
      "svg": '''
<svg viewBox="0 0 200 200">
  <defs>
    <linearGradient id="grad3" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4CAF50;stop-opacity:0.8" />
      <stop offset="100%" style="stop-color:#FF9800;stop-opacity:0.6" />
    </linearGradient>
  </defs>
  <path d="M100 40l60 40v80H40V80l60-40z" fill="url(#grad3)"/>
  <rect x="70" y="100" width="60" height="60" fill="white" opacity="0.9"/>
  <rect x="85" y="120" width="30" height="40" fill="#4CAF50"/>
  <circle cx="100" cy="70" r="15" fill="white"/>
</svg>''',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (value) {
                        setState(() {
                          _currentPage = value;
                          _fadeController.reset();
                          _slideController.reset();
                          _fadeController.forward();
                          _slideController.forward();
                        });
                      },
                      itemCount: _onboardingData.length,
                      itemBuilder: (context, index) => OnboardingContent(
                        title: _onboardingData[index]["title"]!,
                        description: _onboardingData[index]["description"]!,
                        svgContent: _onboardingData[index]["svg"]!,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _onboardingData.length,
                              (index) => buildDot(index: index),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 32),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentPage ==
                                    _onboardingData.length - 1) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.white,
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                elevation: 8,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _currentPage == _onboardingData.length - 1
                                    ? "Get Started"
                                    : "Next",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_currentPage == index ? 1 : 0.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title, description, svgContent;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.description,
    required this.svgContent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: SvgPicture.string(
                        svgContent,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      const Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                        letterSpacing: 0.2,
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
