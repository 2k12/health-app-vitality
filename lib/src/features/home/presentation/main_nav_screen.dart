import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../users/presentation/user_dashboard_screen.dart';
import '../../users/presentation/user_profile_screen.dart';
import '../../workout/presentation/my_workout_plan_screen.dart';
import '../../diet/presentation/my_diet_screen.dart';
import '../../../../src/core/theme/app_colors.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({super.key});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  int _selectedIndex = 0;

  // Pages for each tab
  // 0: Dashboard (Hoy)
  // 1: Workout (Entrenar)
  // 2: Diet (Nutricion)
  // 3: Profile (Perfil)
  static const List<Widget> _pages = <Widget>[
    UserDashboardScreen(),
    MyWorkoutPlanScreen(),
    MyDietScreen(),
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Vitality Design: Clean, White/Dark Background, Simple BottomBar
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: backgroundColor,
        child: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            /// Home
            SalomonBottomBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              title: const Text("Hoy"),
              selectedColor: AppColors.primary,
            ),

            /// Workout
            SalomonBottomBarItem(
              icon: const Icon(Icons.fitness_center_outlined),
              activeIcon: const Icon(Icons.fitness_center_rounded),
              title: const Text("Entrenar"),
              selectedColor: AppColors.secondary,
            ),

            /// Diet
            SalomonBottomBarItem(
              icon: const Icon(Icons.restaurant_menu_outlined),
              activeIcon: const Icon(Icons.restaurant_menu_rounded),
              title: const Text("Nutrición"),
              selectedColor: AppColors.accent,
            ),

            /// Profile
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person_rounded),
              title: const Text("Perfil"),
              selectedColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
