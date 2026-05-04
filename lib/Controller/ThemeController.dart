import 'package:chatting/Config/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum DesignStyle { glassmorphism, neomorphism }

class ThemeController extends GetxController {
  Rx<ThemeMode> themeMode = ThemeMode.dark.obs;
  Rx<DesignStyle> designStyle = DesignStyle.glassmorphism.obs;

  bool get isDark => themeMode.value == ThemeMode.dark;
  bool get isGlass => designStyle.value == DesignStyle.glassmorphism;

  void toggleTheme() {
    themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(themeMode.value);
  }

  void toggleDesignStyle() {
    designStyle.value = isGlass ? DesignStyle.neomorphism : DesignStyle.glassmorphism;
  }

  // Engine Variables
  Color get bg => isDark ? dBackgroundColor : lBackgroundColor;
  Color get surface => isDark ? dSurfaceColor : lSurfaceColor;
  Color get text => isDark ? dTextColor : lTextColor;
  Color get subText => isDark ? dSubTextColor : lSubTextColor;
  Color get orb1 => isDark ? dOrbColor1 : lOrbColor1;
  Color get orb2 => isDark ? dOrbColor2 : lOrbColor2;
  Color get primary => isDark ? dOrbColor1 : lPrimaryColor;
}