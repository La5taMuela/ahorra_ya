import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../providers/savings_provider.dart';

class GoalsWidget extends StatefulWidget {
  const GoalsWidget({super.key});

  @override
  State<GoalsWidget> createState() => _GoalsWidgetState();
}

class _GoalsWidgetState extends State<GoalsWidget> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final goals = provider.goals;
        final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis Metas de Ahorro',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 16),

              // Formulario para nueva meta
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.add_circle, color: Color(0xFF2E7D32)),
                          SizedBox(width: 8),
                          Text(
                            'Crear Nueva Meta',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la meta',
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                          helperText: 'Ej: Vacaciones, Auto nuevo, Casa',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _targetController,
                        decoration: const InputDecoration(
                          labelText: 'Monto objetivo',
                          prefixIcon: Icon(Icons.savings),
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addGoal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Crear Meta'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Lista de metas
              if (goals.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.flag, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes metas creadas',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crea tu primera meta para comenzar a ahorrar con propósito',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...goals.map((goal) => _buildGoalCard(goal, provider, formatter)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalCard(Goal goal, SavingsProvider provider, NumberFormat formatter) {
    final progress = goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;
    final remaining = goal.targetAmount - goal.currentAmount;
    final ahorroMensual = provider.ahorroMensualNeto;
    final monthsToComplete = ahorroMensual > 0 ? (remaining / ahorroMensual).ceil() : -1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar progreso'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editGoalProgress(goal, provider);
                    } else if (value == 'delete') {
                      _deleteGoal(goal.id, provider);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Barra de progreso
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 12),

            // Información de progreso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso: ${(progress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Ahorrado: ${formatter.format(goal.currentAmount)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Meta: ${formatter.format(goal.targetAmount)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Faltan: ${formatter.format(remaining)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Plan de ahorro detallado
            _buildSavingsPlan(remaining, ahorroMensual, formatter),

            const SizedBox(height: 12),

            // Información de tiempo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      monthsToComplete > 0
                          ? 'Con tu ahorro actual, alcanzarás esta meta en $monthsToComplete meses'
                          : 'Necesitas ahorrar más para alcanzar esta meta',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsPlan(double remaining, double ahorroMensual, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Plan de Ahorro Sugerido',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (ahorroMensual > 0) ...[
            _buildPlanRow('Mensual:', formatter.format(remaining / (remaining / ahorroMensual).ceil()), Icons.calendar_month),
            _buildPlanRow('Semanal:', formatter.format((remaining / (remaining / ahorroMensual).ceil()) / 4), Icons.date_range),
            _buildPlanRow('Diario:', formatter.format((remaining / (remaining / ahorroMensual).ceil()) / 30), Icons.calendar_today),
          ] else ...[
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Primero necesitas tener un ahorro mensual positivo',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanRow(String period, String amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            period,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  void _addGoal() {
    if (_nameController.text.isEmpty || _targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final targetAmount = double.tryParse(_targetController.text);
    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un monto válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      targetAmount: targetAmount,
      currentAmount: 0.0,
      createdAt: DateTime.now(),
    );

    context.read<SavingsProvider>().addGoal(goal);

    _nameController.clear();
    _targetController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Meta creada exitosamente!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editGoalProgress(Goal goal, SavingsProvider provider) {
    final controller = TextEditingController(text: goal.currentAmount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar progreso: ${goal.name}'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Monto ahorrado',
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount >= 0) {
                provider.updateGoalProgress(goal.id, amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progreso actualizado'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteGoal(String goalId, SavingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Meta'),
        content: const Text('¿Estás seguro de que quieres eliminar esta meta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.removeGoal(goalId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meta eliminada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
