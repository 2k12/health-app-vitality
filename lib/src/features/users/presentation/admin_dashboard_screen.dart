import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../../admin/presentation/food_management_screen.dart';
import '../../admin/presentation/users_management_screen.dart';
import '../../auth/data/auth_repository.dart';
import '../presentation/user_profile_screen.dart';

import '../../../../src/core/theme/app_colors.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBarColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true, // Allow background to flow behind nav bar if needed
      body: Stack(
        children: [
          // 1. Background Layer (Void Black)
          Container(color: const Color(0xFF050A14)),

          // 2. Ambient Glow (Top Right)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 6, 55, 181).withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 6, 55, 181).withOpacity(0.2),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          // 3. Ambient Glow (Bottom Left)
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 11, 139, 17).withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 11, 139, 17).withOpacity(0.1),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // 4. Content
          SafeArea(
            bottom: false, // Let content go behind nav bar potentially
            child: Column(
              children: [
                // Header with Logout
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        onPressed: () {
                          ref.read(authRepositoryProvider.notifier).signOut();
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                                    begin: const Offset(0.05, 0),
                                    end: Offset.zero)
                                .animate(animation),
                            child: child,
                          ));
                    },
                    child: _buildContent(_selectedIndex),
                  ),
                ),
                // Add bottom padding for Nav Bar
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: navBarColor,
        child: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: [
            /// Resumen
            SalomonBottomBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              title: const Text("Resumen"),
              selectedColor: AppColors.primary,
            ),

            /// Usuarios
            SalomonBottomBarItem(
              icon: const Icon(Icons.people_outline),
              activeIcon: const Icon(Icons.people),
              title: const Text("Usuarios"),
              selectedColor: AppColors.secondary,
            ),

            /// Alimentos
            SalomonBottomBarItem(
              icon: const Icon(Icons.restaurant_outlined),
              activeIcon: const Icon(Icons.restaurant),
              title: const Text("Alimentos"),
              selectedColor: AppColors.accent,
            ),

            /// Perfil
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              title: const Text("Perfil"),
              selectedColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return _AdminHomeTab(
            key: const ValueKey('home'), onNavigate: _navigateTo);
      case 1:
        return const UserManagementScreen(key: ValueKey('users'));
      case 2:
        return const FoodManagementScreen(key: ValueKey('foods'));
      case 3:
        return const UserProfileScreen(
          key: ValueKey('profile'),
          useScaffold: false,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _AdminHomeTab extends StatelessWidget {
  final Function(int) onNavigate;

  const _AdminHomeTab({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings,
                  size: 100,
                  color: Colors.cyanAccent) // Bright Cyan for contrast
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .then()
              .shimmer(
                  duration: 1200.ms, color: Colors.white), // Shimmer effect
          const SizedBox(height: 32),
          Text('BIENVENIDO ADMIN', // Changed to single keyword/concept
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.white))
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: 16),
          Text('Selecciona un módulo para gestionar la plataforma',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      letterSpacing: 1.2))
              .animate()
              .fadeIn(delay: 500.ms),

          const SizedBox(height: 48),

          // Clickable Summary Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SummaryCard(
                  icon: Icons.people,
                  label: 'Usuarios Activos',
                  value: 'Gestión', // Text indicates action
                  color: Colors.blueAccent,
                  onTap: () => onNavigate(1) // Go to Users tab
                  ),
              const SizedBox(width: 24),
              _SummaryCard(
                  icon: Icons.restaurant_menu,
                  label: 'Alimentos',
                  value: 'Catálogo', // Text indicates action
                  color: Colors.greenAccent,
                  onTap: () => onNavigate(2) // Go to Food tab
                  ),
            ],
          ).animate().fadeIn(delay: 700.ms).scale(),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        overlayColor: MaterialStateProperty.all(color.withOpacity(0.2)),
        child: Container(
          width: 160, // Fixed width for consistency
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: color.withOpacity(0.5), width: 1.5), // Thicker border
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2)
              ]),
          child: Column(
            children: [
              // Icon is WHITE as requested
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 12),
              // Text is WHITE as requested
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              // Subtitle is Dimmed White
              Text(label,
                  style: TextStyle(
                      fontSize: 12, color: Colors.white.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }
}
