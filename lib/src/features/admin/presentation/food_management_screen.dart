import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../diet/domain/diet_models.dart';
import '../data/admin_repository.dart';
import '../../../core/utils/app_notifications.dart';

class FoodManagementScreen extends ConsumerWidget {
  const FoodManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodsAsync = ref.watch(allFoodsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFoodDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: foodsAsync.when(
        data: (foods) {
          if (foods.isEmpty) {
            return const Center(child: Text('No hay alimentos registrados'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return Card(
                color: Theme.of(context).cardTheme.color?.withOpacity(0.8),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Icon(Icons.restaurant,
                        color: Theme.of(context).primaryColor),
                  ),
                  title: Text(
                    food.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                  subtitle: Text(
                    '${food.category} • ${food.calories} kcal\nP: ${food.protein}g  C: ${food.carbs}g  G: ${food.fat}g',
                    style: const TextStyle(height: 1.5, fontSize: 13),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () =>
                              _showFoodDialog(context, ref, food: food)),
                      IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () => _deleteFood(context, ref, food.id)),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 50 * index))
                  .slideX();
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _deleteFood(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Confirmar eliminar'),
              content: const Text('¿Estás seguro?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar')),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Eliminar')),
              ],
            ));
    if (confirm == true) {
      try {
        await ref.read(adminRepositoryProvider).deleteFood(id);
        await ref.read(adminRepositoryProvider).deleteFood(id);
        ref.invalidate(allFoodsProvider);
        if (context.mounted) {
          AppNotifications.showSuccess(
              context, 'Alimento eliminado exitosamente');
        }
      } catch (e) {
        if (context.mounted) {
          AppNotifications.showError(context, 'Error al eliminar: $e');
        }
      }
    }
  }

  void _showFoodDialog(BuildContext context, WidgetRef ref, {FoodItem? food}) {
    final isEditing = food != null;
    final nameCtrl = TextEditingController(text: food?.name ?? '');
    final categoryCtrl =
        TextEditingController(text: food?.category ?? 'PROTEINA');
    final calCtrl =
        TextEditingController(text: food?.calories.toString() ?? '');
    final protCtrl =
        TextEditingController(text: food?.protein.toString() ?? '');
    final carbCtrl = TextEditingController(text: food?.carbs.toString() ?? '');
    final fatCtrl = TextEditingController(text: food?.fat.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Editar Alimento' : 'Nuevo Alimento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  controller: nameCtrl),
              TextField(
                  decoration: const InputDecoration(
                      labelText:
                          'Categoría (PROTEINA, CARBOHIDRATO, GRASA, VEGETAL)'),
                  controller: categoryCtrl),
              TextField(
                  decoration: const InputDecoration(labelText: 'Calorías'),
                  controller: calCtrl,
                  keyboardType: TextInputType.number),
              TextField(
                  decoration: const InputDecoration(labelText: 'Proteína (g)'),
                  controller: protCtrl,
                  keyboardType: TextInputType.number),
              TextField(
                  decoration:
                      const InputDecoration(labelText: 'Carbohidratos (g)'),
                  controller: carbCtrl,
                  keyboardType: TextInputType.number),
              TextField(
                  decoration: const InputDecoration(labelText: 'Grasas (g)'),
                  controller: fatCtrl,
                  keyboardType: TextInputType.number),
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
                final data = {
                  'name': nameCtrl.text,
                  'category': categoryCtrl.text,
                  'calories': int.tryParse(calCtrl.text) ?? 0,
                  'protein': double.tryParse(protCtrl.text) ?? 0,
                  'carbs': double.tryParse(carbCtrl.text) ?? 0,
                  'fat': double.tryParse(fatCtrl.text) ?? 0,
                };

                if (isEditing) {
                  // food is not null here because isEditing is true
                  await ref
                      .read(adminRepositoryProvider)
                      .updateFood(food.id, data);
                } else {
                  await ref.read(adminRepositoryProvider).createFood(data);
                }
                // Use invalidate to force refresh without waiting for result if not needed
                ref.invalidate(allFoodsProvider);
                if (context.mounted) Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
