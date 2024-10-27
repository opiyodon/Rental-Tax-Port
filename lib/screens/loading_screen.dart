import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingScreen extends StatefulWidget {
  final String message;

  const LoadingScreen({
    super.key,
    required this.message,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();

    // Rotating animation for the outer circle
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Pulse animation for the inner circle
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animated dots
    _dotControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 200)),
        vsync: this,
      )..repeat(reverse: true),
    );

    _dotAnimations = _dotControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Start all animations
    for (var controller in _dotControllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    for (var controller in _dotControllers) {
      controller.dispose();
    }
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom animated loader
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating outer circle
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 4,
                              ),
                              gradient: SweepGradient(
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Pulsing inner circle
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Message text
                Text(
                  widget.message,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                // Animated dots
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _dotAnimations[index],
                      builder: (context, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              0.2 + (_dotAnimations[index].value * 0.8),
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
