import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/ThemeController.dart';

class PremiumSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isPressed;
  final double? width;
  final double? height;

  const PremiumSurface({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.isPressed = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    const duration = Duration(milliseconds: 500);

    return Obx(() {
      bool isDark = themeController.isDark;
      bool isGlass = themeController.isGlass;

      if (isGlass) {
        // --- PREMIUM GLASSMORPHISM ---
        return AnimatedContainer(
          duration: duration,
          margin: margin,
          width: width,
          height: height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 80 : 20),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ]
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0), // Deep blur
              child: AnimatedContainer(
                duration: duration,
                padding: padding,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(10) : Colors.white.withAlpha(80),
                  borderRadius: BorderRadius.circular(borderRadius),
                  // Directional light border (simulates glass edge reflection)
                  border: Border.all(
                    color: Colors.white.withAlpha(isDark ? 30 : 150),
                    width: 1.0,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withAlpha(isDark ? 25 : 120),
                      Colors.white.withAlpha(isDark ? 5 : 20),
                    ],
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      } else {
        // --- TRUE NEOMORPHISM ---
        // Neo strictly requires the container color to match the background
        Color baseColor = themeController.bg;
        Color lightShadow = isDark ? Colors.white.withAlpha(10) : Colors.white;
        Color darkShadow = isDark ? Colors.black.withAlpha(200) : const Color(0xFFA3B1C6).withAlpha(180);

        return AnimatedContainer(
          duration: duration,
          margin: margin,
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: isPressed
                ? [
              // Inset shadow effect could go here, for now, flat when pressed
            ]
                : [
              BoxShadow(color: darkShadow, offset: const Offset(8, 8), blurRadius: 16),
              BoxShadow(color: lightShadow, offset: const Offset(-8, -8), blurRadius: 16),
            ],
          ),
          child: child,
        );
      }
    });
  }
}