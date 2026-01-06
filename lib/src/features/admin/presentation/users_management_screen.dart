import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_notifications.dart';
import '../../auth/domain/app_user.dart';
import '../data/admin_repository.dart';
import 'admin_user_history_screen.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final trainersAsync = ref.watch(allTrainersProvider);

    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 11, 139, 17).withOpacity(0.6),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color.fromARGB(255, 11, 139, 17).withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddUserDialog(context, ref),
          label: const Text(
            'NUEVO USUARIO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
          icon: const Icon(Icons.person_add, color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 11, 139, 17),
          elevation: 0,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      body: usersAsync.when(
        data: (users) {
          // Filter out admins if strictly managing public
          final filteredUsers =
              users.where((u) => u.role != UserRole.admin).toList();

          if (filteredUsers.isEmpty) {
            return const Center(child: Text('No hay usuarios'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final hasTrainer = user.assignedTrainerId != null;
              final isTrainer = user.role == UserRole.trainer;

              return Card(
                color: Theme.of(context).cardTheme.color?.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: user.isActive
                            ? (isTrainer
                                ? Colors.purpleAccent.withOpacity(0.3)
                                : Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.3))
                            : Colors.red.withOpacity(0.3),
                        width: 1)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: isTrainer
                        ? Colors.purpleAccent.withOpacity(0.2)
                        : Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: isTrainer
                          ? Colors.purpleAccent
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  subtitle: Text(
                      '${user.email}\n${user.role.name.toUpperCase()}',
                      style: const TextStyle(
                          fontSize: 12, height: 1.5, color: Colors.white70)),
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: user.isActive,
                      activeColor: Colors.greenAccent,
                      onChanged: (val) =>
                          _toggleStatus(context, ref, user.uid, val),
                    ),
                  ),
                  children: [
                    Container(
                      color: Colors.black12,
                      child: Column(
                        children: [
                          if (!isTrainer)
                            ListTile(
                              leading: const Icon(Icons.fitness_center_outlined,
                                  size: 20),
                              title: Builder(
                                builder: (context) {
                                  final trainers = trainersAsync.value ?? [];
                                  String trainerName = "Ninguno";
                                  if (hasTrainer) {
                                    final trainer = trainers.firstWhere(
                                      (t) => t.uid == user.assignedTrainerId,
                                      orElse: () => AppUser(
                                        uid: '',
                                        email: '',
                                        name:
                                            'Desconocido (${user.assignedTrainerId})',
                                        role: UserRole.trainer,
                                      ),
                                    );
                                    trainerName = trainer.name;
                                  }
                                  return Text('Entrenador: $trainerName',
                                      style: const TextStyle(fontSize: 14));
                                },
                              ),
                              trailing: TextButton.icon(
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Asignar'),
                                onPressed: () => _showAssignTrainerDialog(
                                    context,
                                    ref,
                                    user,
                                    trainersAsync.value ?? []),
                              ),
                            ),
                          ListTile(
                            leading: const Icon(Icons.timeline, size: 20),
                            title: const Text('Ver Historial',
                                style: TextStyle(fontSize: 14)),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 14),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AdminUserHistoryScreen(
                                    userId: user.uid,
                                    userName: user.name,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (user.role == UserRole.user)
                            ListTile(
                              leading: const Icon(Icons.bolt,
                                  size: 20, color: Colors.yellowAccent),
                              title: const Text('Generar Dieta Automática',
                                  style: TextStyle(fontSize: 14)),
                              onTap: () =>
                                  _generateDiet(context, ref, user.uid),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 50 * index))
                  .slideY(begin: 0.1, end: 0);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _toggleStatus(
      BuildContext context, WidgetRef ref, String uid, bool isActive) async {
    try {
      await ref.read(adminRepositoryProvider).toggleUserStatus(uid, isActive);
      ref.invalidate(allUsersProvider);
      if (context.mounted) {
        AppNotifications.showSuccess(context, 'Usuario actualizado');
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(context, 'Error: $e');
      }
    }
  }

  void _generateDiet(BuildContext context, WidgetRef ref, String uid) async {
    try {
      await ref.read(adminRepositoryProvider).generateDietPlanForUser(uid);
      if (context.mounted) {
        AppNotifications.showSuccess(context, 'Dieta generada exitosamente');
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(context, 'Error al generar dieta: $e');
      }
    }
  }

  void _showAssignTrainerDialog(BuildContext context, WidgetRef ref,
      AppUser user, List<AppUser> trainers) {
    String? selectedTrainerId = user.assignedTrainerId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Asignar Entrenador a ${user.name}'),
          content: DropdownButton<String>(
            value: selectedTrainerId,
            hint: const Text('Seleccionar Entrenador'),
            isExpanded: true,
            items: [
              const DropdownMenuItem(
                  value: null, child: Text("Sin Entrenador")),
              ...trainers.map(
                  (t) => DropdownMenuItem(value: t.uid, child: Text(t.name))),
            ],
            onChanged: (val) => setState(() => selectedTrainerId = val),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(adminRepositoryProvider)
                      .assignTrainer(user.uid, selectedTrainerId);
                  ref.invalidate(
                      allUsersProvider); // Refresh list to show new assignment
                  if (context.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'USUARIO';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Nuevo Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: const [
                    DropdownMenuItem(value: 'USUARIO', child: Text('Usuario')),
                    DropdownMenuItem(
                        value: 'ENTRENADOR', child: Text('Entrenador')),
                    DropdownMenuItem(
                        value: 'ADMINISTRADOR', child: Text('Administrador')),
                  ],
                  onChanged: (val) => setState(() => selectedRole = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (nameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    AppNotifications.showError(
                        context, 'Por favor completa todos los campos');
                    return;
                  }

                  await ref.read(adminRepositoryProvider).createUser(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text,
                        role: selectedRole,
                      );

                  ref.invalidate(allUsersProvider);
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    AppNotifications.showSuccess(
                        context, 'Usuario creado exitosamente');
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppNotifications.showError(context, 'Error: $e');
                  }
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }
}
