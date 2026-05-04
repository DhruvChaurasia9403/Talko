import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/ThemeController.dart';

class AmbientBackground extends StatefulWidget {
  final Widget child;
  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    // A slow, organic breathing cycle (4 seconds in, 4 seconds out)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true); // Continuously loops back and forth

    // Scales the orb between 95% and 115% for a subtle, natural expansion
    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() => Stack(
        children: [
          // Base Canvas
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            color: themeController.bg,
          ),

          // Orb 1 (Top Left - Spreads wide, static)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutQuart,
            top: -size.height * 0.2,
            left: -size.width * 0.5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: size.width * 1,
              height: size.width * 1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeController.orb2.withAlpha(themeController.isGlass ? 70 : 20),
              ),
            ),
          ),

          // Orb 2 (Bottom Right - Deep glow WITH BREATHING EFFECT)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutQuart,
            bottom: -size.height * 0.2,
            right: -size.width * 0.4,
            child: ScaleTransition(
              scale: _breathingAnimation, // <--- The breathing engine is applied here
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: themeController.orb1.withAlpha(themeController.isGlass ? 80 : 30),
                ),
              ),
            ),
          ),

          // Massive Diffusion Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 120.0, sigmaY: 120.0),
            child: Container(color: Colors.transparent),
          ),

          // Content
          widget.child,
        ],
      )),
    );
  }
}