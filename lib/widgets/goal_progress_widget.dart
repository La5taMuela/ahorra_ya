import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/savings_provider.dart';
import '../models/goal.dart';

class GoalProgressWidget extends StatelessWidget {
  const GoalProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        final goals = provider.goals;

        if (user == null || goals.isEmpty) {
          return const SizedBox.shrink();
        }

        final ahorroMensualNeto = provider.ahorroMensualNeto;
        final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Text(
                      'Progreso de Metas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Análisis de ahorro necesario para metas
                if (ahorroMensualNeto > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calculate, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Análisis de Capacidad de Ahorro',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Con tu ahorro mensual de ${formatter.format(ahorroMensualNeto)}, puedes:',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        ...goals.map((goal) => _buildGoalAnalysis(goal, ahorroMensualNeto, formatter)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Lista de metas con progreso detallado
                ...goals.map((goal) => _buildDetailedGoalCard(goal, ahorroMensualNeto, formatter)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalAnalysis(Goal goal, double ahorroMensualNeto, NumberFormat formatter) {
    final targetAmount = goal.targetAmount;
    final currentAmount = goal.currentAmount;
    final remaining = targetAmount - currentAmount;
    final monthsNeeded = remaining / ahorroMensualNeto;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(color: Colors.green, fontSize: 16)),
          Expanded(
            child: Text(
              '${goal.name}: ${monthsNeeded.ceil()} meses (${formatter.format(remaining)} restantes)',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedGoalCard(Goal goal, double ahorroMensualNeto, NumberFormat formatter) {
    final targetAmount = goal.targetAmount;
    final currentAmount = goal.currentAmount;
    final remaining = targetAmount - currentAmount;
    final progress = currentAmount / targetAmount;
    final monthsNeeded = ahorroMensualNeto > 0 ? remaining / ahorroMensualNeto : -1;

    // Calcular porcentaje del ahorro mensual necesario para esta meta
    final porcentajeAhorroNecesario = ahorroMensualNeto > 0 ? (remaining / monthsNeeded) / ahorroMensualNeto * 100 : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
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

            // Información detallada
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahorrado: ${formatter.format(currentAmount)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Meta: ${formatter.format(targetAmount)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Faltan: ${formatter.format(remaining)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      monthsNeeded > 0 ? '${monthsNeeded.ceil()} meses' : 'Meta no alcanzable',
                      style: TextStyle(
                        fontSize: 14,
                        color: monthsNeeded > 0 ? Colors.grey[600] : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Análisis matemático detallado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.functions, color: Colors.blue, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Análisis Matemático',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (monthsNeeded > 0) ...[
                    Text(
                      '• Necesitas ahorrar ${formatter.format(remaining / monthsNeeded)} mensualmente',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      '• Esto representa el ${porcentajeAhorroNecesario.toStringAsFixed(1)}% de tu ahorro mensual',
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (monthsNeeded <= 12)
                      const Text(
                        '• ¡Puedes lograr esta meta en menos de un año!',
                        style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w500),
                      )
                    else
                      Text(
                        '• Esta es una meta a largo plazo (${(monthsNeeded / 12).toStringAsFixed(1)} años)',
                        style: const TextStyle(fontSize: 13, color: Colors.orange),
                      ),
                  ] else ...[
                    const Text(
                      '• Con tu ahorro actual, esta meta no es alcanzable',
                      style: TextStyle(fontSize: 13, color: Colors.red),
                    ),
                    const Text(
                      '• Considera aumentar ingresos o reducir gastos',
                      style: TextStyle(fontSize: 13, color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
