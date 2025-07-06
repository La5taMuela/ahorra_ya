import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/savings_provider.dart';
import '../screens/goals_management_screen.dart';
import '../../core/currency/currency_widgets.dart';
import '../../core/currency/currency_service.dart';

class GoalsListWidget extends StatelessWidget {
  final bool isPreview;

  const GoalsListWidget({super.key, this.isPreview = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final goals = isPreview
            ? provider.savingsGoals.take(3).toList()
            : provider.savingsGoals;

        if (goals.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes metas de ahorro',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primera meta para comenzar',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToGoalsManagement(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Meta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPreview ? '🎯 Metas de Ahorro' : 'Todas las Metas',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isPreview)
                  ElevatedButton.icon(
                    onPressed: () => _navigateToGoalsManagement(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva Meta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...goals.map((goal) => _buildGoalCard(context, goal, provider)),
            if (isPreview && provider.savingsGoals.length > 3)
              TextButton(
                onPressed: () => _navigateToGoalsManagement(context),
                child: const Text('Ver todas las metas'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGoalCard(BuildContext context, goal, SavingsProvider provider) {
    final optimalSavings = provider.calculateOptimalSavings(goal);

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
                    goal.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(goal.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        goal.category,
                        style: TextStyle(
                          color: _getCategoryColor(goal.category),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) => _handleGoalAction(context, value, goal, provider),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              goal.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progreso',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${CurrencyService.formatWithSymbol(goal.currentAmount)} / ${CurrencyService.formatWithSymbol(goal.targetAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Ahorro Óptimo',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${CurrencyService.formatWithSymbol(optimalSavings)}/mes',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: goal.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getCategoryColor(goal.category),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${goal.progressPercentage.toStringAsFixed(1)}% completado',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            // BOTÓN AGREGAR DINERO EN LA CARD
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddMoneyDialog(context, goal, provider),
                icon: const Icon(Icons.add_circle, size: 18),
                label: const Text('Agregar Dinero'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'emergencia':
        return Colors.red;
      case 'viaje':
        return Colors.blue;
      case 'casa':
        return Colors.orange;
      case 'educación':
        return Colors.purple;
      case 'auto':
        return Colors.indigo;
      default:
        return const Color(0xFF2E7D32);
    }
  }

  void _handleGoalAction(BuildContext context, String action, goal, SavingsProvider provider) {
    switch (action) {
      case 'edit':
        _navigateToEditGoal(context, goal);
        break;
      case 'delete':
        _showDeleteConfirmation(context, goal, provider);
        break;
    }
  }

  void _navigateToGoalsManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GoalsManagementScreen(),
      ),
    );
  }

  void _navigateToEditGoal(BuildContext context, goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalsManagementScreen(editGoal: goal),
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context, goal, SavingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _AddMoneyDialog(goal: goal),
    );
  }

  void _showDeleteConfirmation(BuildContext context, goal, SavingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ Eliminar Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres eliminar la meta "${goal.title}"?'),
            const SizedBox(height: 8),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await provider.deleteSavingsGoal(goal.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Meta eliminada exitosamente'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// Dialog para agregar dinero
class _AddMoneyDialog extends StatefulWidget {
  final goal;

  const _AddMoneyDialog({required this.goal});

  @override
  State<_AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<_AddMoneyDialog> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('💰 Agregar Dinero'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meta: ${widget.goal.title}'),
          CurrencyDisplay(
            amount: widget.goal.currentAmount,
            label: 'Actual',
            fontSize: 14,
          ),
          const SizedBox(height: 8),
          CurrencyDisplay(
            amount: widget.goal.targetAmount,
            label: 'Objetivo',
            fontSize: 14,
          ),
          const SizedBox(height: 16),
          CurrencyTextFormField(
            controller: _amountController,
            labelText: 'Monto a agregar',
            hintText: '50.000',
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addMoney,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : const Text('Agregar'),
        ),
      ],
    );
  }

  Future<void> _addMoney() async {
    final amount = CurrencyService.parse(_amountController.text);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Ingresa un monto válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedGoal = widget.goal.copyWith(
        currentAmount: widget.goal.currentAmount + amount,
      );

      await context.read<SavingsProvider>().updateSavingsGoal(updatedGoal);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Se agregaron ${CurrencyService.formatWithSymbol(amount)}'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
