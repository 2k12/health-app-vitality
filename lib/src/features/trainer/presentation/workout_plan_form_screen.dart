import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../workout/domain/workout_plan.dart';
import '../../workout/domain/exercise.dart';
import '../../workout/data/exercise_repository.dart';
import '../data/trainer_repository.dart';
import '../../../core/utils/app_notifications.dart';
import '../../../core/theme/app_colors.dart';

class WorkoutPlanFormScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? userName;

  const WorkoutPlanFormScreen({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  ConsumerState<WorkoutPlanFormScreen> createState() =>
      _WorkoutPlanFormScreenState();
}

class _WorkoutPlanFormScreenState extends ConsumerState<WorkoutPlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, List<WorkoutExercise>> _dailyRoutines = {1: []};
  int _selectedDay = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load existing plan if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingPlan();
    });
  }

  Future<void> _loadExistingPlan() async {
    setState(() => _isLoading = true);
    try {
      final plan = await ref
          .read(trainerRepositoryProvider)
          .getUserWorkoutPlan(widget.userId);

      if (plan != null && plan.dailyRoutines.isNotEmpty) {
        setState(() {
          _dailyRoutines.clear();
          _dailyRoutines.addAll(plan.dailyRoutines);
          _selectedDay = _dailyRoutines.keys.first;
        });
      }
    } catch (e) {
      // It's fine if no plan exists yet
      debugPrint('No existing plan found or error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addDay() {
    setState(() {
      final nextDay = _dailyRoutines.keys.length + 1;
      _dailyRoutines[nextDay] = [];
      _selectedDay = nextDay;
    });
  }

  void _removeDay(int day) {
    if (_dailyRoutines.length <= 1) return;
    setState(() {
      _dailyRoutines.remove(day);
      // Re-index remaining days to be sequential
      final sortedKeys = _dailyRoutines.keys.toList()..sort();
      final Map<int, List<WorkoutExercise>> newRoutines = {};
      for (var i = 0; i < sortedKeys.length; i++) {
        newRoutines[i + 1] = _dailyRoutines[sortedKeys[i]]!;
      }
      _dailyRoutines.clear();
      _dailyRoutines.addAll(newRoutines);
      if (_selectedDay > _dailyRoutines.length) {
        _selectedDay = _dailyRoutines.length;
      }
    });
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _dailyRoutines[_selectedDay]!.add(WorkoutExercise(
        name: exercise.name,
        sets: 0,
        reps: 0,
        notes: null,
      ));
    });
  }

  void _removeExercise(int day, int index) {
    setState(() {
      _dailyRoutines[day]!.removeAt(index);
    });
  }

  Future<void> _showExercisePicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceSheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('SELECCIONAR EJERCICIO',
                style: TextStyle(
                    color: AppColors.highlight,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final exercisesAsync = ref.watch(allExercisesProvider);
                  return exercisesAsync.when(
                    data: (exercises) {
                      // Group by muscle group
                      final groups = <String, List<Exercise>>{};
                      for (var ex in exercises) {
                        groups.putIfAbsent(ex.muscleGroup, () => []).add(ex);
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final muscle = groups.keys.elementAt(index);
                          final muscleExercises = groups[muscle]!;

                          return ExpansionTile(
                            title: Text(muscle.toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            children: muscleExercises
                                .map((ex) => ListTile(
                                      title: Text(ex.name,
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      subtitle: Text(ex.bodyPart,
                                          style: const TextStyle(
                                              color: Colors.white24,
                                              fontSize: 10)),
                                      onTap: () {
                                        _addExercise(ex);
                                        Navigator.pop(context);
                                      },
                                    ))
                                .toList(),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    bool hasExercises = _dailyRoutines.values.any((list) => list.isNotEmpty);
    if (!hasExercises) {
      AppNotifications.showError(
          context, 'Agrega al menos un ejercicio en algún día');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Map structures correctly for the backend
      final Map<String, dynamic> routinesMap = {};
      _dailyRoutines.forEach((key, value) {
        routinesMap[key.toString()] = value.map((e) => e.toMap()).toList();
      });

      await ref.read(trainerRepositoryProvider).upsertWorkoutPlan(
            widget.userId,
            routinesMap,
          );
      if (mounted) {
        AppNotifications.showSuccess(context, 'Plan guardado correctamente');
        context.pop();
        ref.invalidate(userWorkoutPlanProvider(widget.userId));
      }
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(context, 'Error al guardar el plan: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundVeryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Rutina: ${widget.userName ?? "Usuario"}'),
        actions: [
          if (_isLoading)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ))
          else
            IconButton(
              icon: const Icon(Icons.save, color: AppColors.highlight),
              onPressed: _savePlan,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.highlight.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            // Day Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  ..._dailyRoutines.keys.map((day) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('DÍA $day'),
                          selected: _selectedDay == day,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedDay = day);
                          },
                          selectedColor: AppColors.highlight,
                          labelStyle: TextStyle(
                            color: _selectedDay == day
                                ? Colors.black
                                : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: Colors.white.withOpacity(0.05),
                        ),
                      )),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.highlight),
                    onPressed: _addDay,
                  ),
                  if (_dailyRoutines.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.redAccent),
                      onPressed: () => _removeDay(_selectedDay),
                    ),
                ],
              ),
            ),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildSectionHeader('EJERCICIOS DÍA $_selectedDay'),
                    const SizedBox(height: 16),
                    if (_dailyRoutines[_selectedDay]!.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'Sin ejercicios para este día',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ...List.generate(_dailyRoutines[_selectedDay]!.length,
                        (index) {
                      final exercise = _dailyRoutines[_selectedDay]![index];
                      return _ExerciseFormItem(
                        key: ValueKey(
                            'day_$_selectedDay\_ex_${exercise.name}_$index'),
                        index: index,
                        exercise: exercise,
                        onRemove: () => _removeExercise(_selectedDay, index),
                        onChanged: (updated) =>
                            _dailyRoutines[_selectedDay]![index] = updated,
                      );
                    }),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _showExercisePicker,
                      icon: const Icon(Icons.add, color: AppColors.highlight),
                      label: const Text('Agregar a la Lista',
                          style: TextStyle(color: AppColors.highlight)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.highlight),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.highlight,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
            child: Divider(color: AppColors.highlight, thickness: 0.5)),
      ],
    );
  }
}

class _ExerciseFormItem extends StatefulWidget {
  final int index;
  final WorkoutExercise exercise;
  final VoidCallback onRemove;
  final Function(WorkoutExercise) onChanged;

  const _ExerciseFormItem({
    super.key,
    required this.index,
    required this.exercise,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_ExerciseFormItem> createState() => _ExerciseFormItemState();
}

class _ExerciseFormItemState extends State<_ExerciseFormItem> {
  late final TextEditingController _setsController;
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(
        text: widget.exercise.sets == 0 ? '' : widget.exercise.sets.toString());
    _repsController = TextEditingController(
        text: widget.exercise.reps == 0 ? '' : widget.exercise.reps.toString());
    _weightController = TextEditingController(
        text: widget.exercise.weight == null || widget.exercise.weight == 0
            ? ''
            : widget.exercise.weight!.toString());
    _notesController = TextEditingController(text: widget.exercise.notes);
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateExercise() {
    widget.onChanged(WorkoutExercise(
      name: widget.exercise.name,
      sets: int.tryParse(_setsController.text) ?? 0,
      reps: int.tryParse(_repsController.text) ?? 0,
      weight: double.tryParse(_weightController.text),
      notes: _notesController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.highlight.withOpacity(0.2),
                child: Text('${widget.index + 1}',
                    style: const TextStyle(
                        color: AppColors.highlight, fontSize: 10)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.exercise.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 20),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          const Divider(color: Colors.white10),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  label: 'Series',
                  controller: _setsController,
                  onChanged: (_) => _updateExercise(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildNumberField(
                  label: 'Reps',
                  controller: _repsController,
                  onChanged: (_) => _updateExercise(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildNumberField(
                  label: 'Peso (kg)',
                  controller: _weightController,
                  onChanged: (_) => _updateExercise(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Notas adicionales (ej: 2 min descanso)',
              hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: (val) => _updateExercise(),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(color: Colors.white38, fontSize: 9)),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
