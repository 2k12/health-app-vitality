import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/data/auth_repository.dart';
import '../../trainer/data/trainer_repository.dart';
import '../presentation/user_profile_screen.dart';
import 'package:go_router/go_router.dart';

class TrainerDashboardScreen extends ConsumerStatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  ConsumerState<TrainerDashboardScreen> createState() =>
      _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState
    extends ConsumerState<TrainerDashboardScreen> {
  int _selectedIndex = 0;

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                color: const Color.fromARGB(255, 66, 6, 181).withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 66, 6, 181).withOpacity(0.2),
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
                color: const Color.fromARGB(255, 139, 11, 11).withOpacity(0.05),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 139, 11, 11).withOpacity(0.1),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // 4. Content Content
          SafeArea(
            child: Row(
              children: [
                _buildNavRail(context),
                const VerticalDivider(
                    thickness: 1, width: 1, color: Colors.white10),
                Expanded(
                  child: Column(
                    children: [
                      // Custom AppBar-like header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.logout,
                                  color: Colors.redAccent),
                              onPressed: () {
                                ref
                                    .read(authRepositoryProvider.notifier)
                                    .signOut();
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRail(BuildContext context) {
    return NavigationRail(
      backgroundColor: Colors.transparent,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
      selectedLabelTextStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.4)),
      unselectedLabelTextStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Resumen'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: Text('Atletas'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Perfil'),
        ),
      ],
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return _TrainerHomeTab(onNavigate: _navigateTo);
      case 1:
        return const _AssignedUsersTab();
      case 2:
        return const UserProfileScreen(useScaffold: false);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TrainerHomeTab extends ConsumerWidget {
  final Function(int) onNavigate;
  const _TrainerHomeTab({required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(assignedUsersProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_rounded,
                  size: 100, color: Colors.orangeAccent)
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .then()
              .shimmer(duration: 1200.ms, color: Colors.white),
          const SizedBox(height: 32),
          Text('CENTRO DE ENTRENAMIENTO',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.white))
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.1),
          const SizedBox(height: 16),
          usersAsync
              .when(
                data: (users) => Text(
                    'Gestionando a ${users.length} atletas activos',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        letterSpacing: 1.2)),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              )
              .animate()
              .fadeIn(delay: 500.ms),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SummaryCard(
                icon: Icons.people,
                label: 'Mis Atletas',
                value: 'Ver Lista',
                color: Colors.orangeAccent,
                onTap: () => onNavigate(1),
              ),
            ],
          ).animate().fadeIn(delay: 700.ms).scale(),
        ],
      ),
    );
  }
}

class _AssignedUsersTab extends ConsumerWidget {
  const _AssignedUsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(assignedUsersProvider);

    return usersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(
            child: Text('No tienes atletas asignados.',
                style: TextStyle(color: Colors.white70)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserCard(user: user);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Error: $err',
            style: const TextStyle(color: Colors.redAccent)),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: Colors.orangeAccent.withOpacity(0.2),
          child: const Icon(Icons.person, color: Colors.orangeAccent, size: 20),
        ),
        title: Text(user.name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(user.email,
            style: TextStyle(color: Colors.white.withOpacity(0.6))),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        onTap: () => context.push('/trainer/client/${user.uid}'),
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
        child: Container(
          width: 160,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5)),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 12),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
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
