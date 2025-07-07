import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/savings_provider.dart';

class ExpensesTrackerWidget extends StatelessWidget {
  const ExpensesTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final expenses = provider.expenses;
        final currentMonth = DateTime.now();
        final monthlyTotal = provider.getTotalExpensesForMonth(currentMonth);
        final categoryTotals = provider.getExpensesByCategory(currentMonth);
        final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Control de Gastos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 16),

              // Resumen del mes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 8),
                          Text(
                            'Resumen de ${DateFormat('MMMM yyyy', 'es_ES').format(currentMonth)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total gastado:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            formatter.format(monthlyTotal),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Gastos por categoría
              if (categoryTotals.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.pie_chart, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Gastos por Categoría',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...categoryTotals.entries.map((entry) {
                          final percentage = monthlyTotal > 0 ? (entry.value / monthlyTotal) * 100 : 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key),
                                    Text(
                                      '${formatter.format(entry.value)} (${percentage.toStringAsFixed(1)}%)',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Lista de gastos recientes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Gastos Recientes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (expenses.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No hay gastos registrados',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...expenses.take(10).map((expense) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor(expense.category),
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(expense.description),
                            subtitle: Text(
                              '${expense.category} • ${DateFormat('dd/MM/yyyy').format(expense.date)}',
                            ),
                            trailing: Text(
                              formatter.format(expense.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onLongPress: () => _showDeleteDialog(context, provider, expense.id),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Comida': return Colors.orange;
      case 'Transporte': return Colors.blue;
      case 'Entretenimiento': return Colors.purple;
      case 'Ropa': return Colors.pink;
      case 'Salud': return Colors.red;
      case 'Educación': return Colors.green;
      case 'Servicios': return Colors.brown;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Comida': return Icons.restaurant;
      case 'Transporte': return Icons.directions_car;
      case 'Entretenimiento': return Icons.movie;
      case 'Ropa': return Icons.shopping_bag;
      case 'Salud': return Icons.local_hospital;
      case 'Educación': return Icons.school;
      case 'Servicios': return Icons.build;
      default: return Icons.shopping_cart;
    }
  }

  void _showDeleteDialog(BuildContext context, SavingsProvider provider, String expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto'),
        content: const Text('¿Estás seguro de que quieres eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.removeExpense(expenseId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gasto eliminado'),
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
