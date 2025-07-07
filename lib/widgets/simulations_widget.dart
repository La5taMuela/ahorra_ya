import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/savings_provider.dart';

class SimulationsWidget extends StatefulWidget {
  const SimulationsWidget({super.key});

  @override
  State<SimulationsWidget> createState() => _SimulationsWidgetState();
}

class _SimulationsWidgetState extends State<SimulationsWidget> {
  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();

  @override
  void dispose() {
    _incomeController.dispose();
    _expenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        if (user == null) return const SizedBox.shrink();

        final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simulaciones Financieras',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descubre cómo pequeños cambios pueden impactar tus ahorros',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              _buildCurrentSituationCard(provider, formatter),
              const SizedBox(height: 16),

              _buildIncomeSimulationCard(provider, formatter),
              const SizedBox(height: 16),

              _buildExpenseSimulationCard(provider, formatter),
              const SizedBox(height: 16),

              _buildQuickScenariosCard(provider, formatter),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentSituationCard(SavingsProvider provider, NumberFormat formatter) {
    final ahorroActual = provider.ahorroMensualNeto;
    final gastosVariables = provider.gastosVariablesDelMes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Tu Situación Actual',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ahorro mensual:', style: TextStyle(fontSize: 14)),
                Text(
                  formatter.format(ahorroActual),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: ahorroActual >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gastos variables este mes:', style: TextStyle(fontSize: 14)),
                Text(
                  formatter.format(gastosVariables),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeSimulationCard(SavingsProvider provider, NumberFormat formatter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Simular Aumento de Ingresos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Qué pasaría si aumentaras tus ingresos?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _incomeController,
              decoration: const InputDecoration(
                labelText: 'Porcentaje de aumento (%)',
                prefixIcon: Icon(Icons.percent),
                border: OutlineInputBorder(),
                helperText: 'Ej: 10 para un aumento del 10%',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _simulateIncomeChange(provider, formatter),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simular Aumento'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseSimulationCard(SavingsProvider provider, NumberFormat formatter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_down, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Simular Reducción de Gastos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Cuánto ahorrarías reduciendo tus gastos variables?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _expenseController,
              decoration: const InputDecoration(
                labelText: 'Porcentaje de reducción (%)',
                prefixIcon: Icon(Icons.percent),
                border: OutlineInputBorder(),
                helperText: 'Ej: 15 para reducir un 15%',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _simulateExpenseChange(provider, formatter),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simular Reducción'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickScenariosCard(SavingsProvider provider, NumberFormat formatter) {
    final scenarios = [
      {'label': 'Reducir gastos 10%', 'type': 'expense', 'value': -10.0, 'color': Colors.blue},
      {'label': 'Reducir gastos 20%', 'type': 'expense', 'value': -20.0, 'color': Colors.green},
      {'label': 'Aumentar ingresos 15%', 'type': 'income', 'value': 15.0, 'color': Colors.purple},
      {'label': 'Aumentar ingresos 25%', 'type': 'income', 'value': 25.0, 'color': Colors.orange},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flash_on, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Escenarios Rápidos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Toca cualquier escenario para ver el impacto inmediato:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: scenarios.map((scenario) {
                return ElevatedButton(
                  onPressed: () => _simulateQuickScenario(
                    provider,
                    formatter,
                    scenario['type'] as String,
                    scenario['value'] as double,
                    scenario['label'] as String,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (scenario['color'] as Color).withValues(alpha: 0.1),
                    foregroundColor: scenario['color'] as Color,
                    elevation: 0,
                  ),
                  child: Text(scenario['label'] as String),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateIncomeChange(SavingsProvider provider, NumberFormat formatter) {
    final percentage = double.tryParse(_incomeController.text);
    if (percentage == null || percentage <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un porcentaje válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nuevoAhorro = provider.simularCambioIngresos(percentage);
    final diferencia = nuevoAhorro - provider.ahorroMensualNeto;

    _showSimulationResult(
      'Aumento de Ingresos ${percentage.toStringAsFixed(1)}%',
      'Con este aumento de ingresos:',
      nuevoAhorro,
      diferencia,
      formatter,
      Colors.green,
      Icons.trending_up,
    );
  }

  void _simulateExpenseChange(SavingsProvider provider, NumberFormat formatter) {
    final percentage = double.tryParse(_expenseController.text);
    if (percentage == null || percentage <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un porcentaje válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nuevoAhorro = provider.simularCambioGastos(-percentage);
    final diferencia = nuevoAhorro - provider.ahorroMensualNeto;

    _showSimulationResult(
      'Reducción de Gastos ${percentage.toStringAsFixed(1)}%',
      'Reduciendo tus gastos variables:',
      nuevoAhorro,
      diferencia,
      formatter,
      Colors.blue,
      Icons.trending_down,
    );
  }

  void _simulateQuickScenario(SavingsProvider provider, NumberFormat formatter, String type, double value, String label) {
    double nuevoAhorro;
    if (type == 'income') {
      nuevoAhorro = provider.simularCambioIngresos(value);
    } else {
      nuevoAhorro = provider.simularCambioGastos(value);
    }

    final diferencia = nuevoAhorro - provider.ahorroMensualNeto;

    _showSimulationResult(
      label,
      type == 'income' ? 'Con este aumento de ingresos:' : 'Reduciendo tus gastos:',
      nuevoAhorro,
      diferencia,
      formatter,
      type == 'income' ? Colors.green : Colors.blue,
      type == 'income' ? Icons.trending_up : Icons.trending_down,
    );
  }

  void _showSimulationResult(String title, String subtitle, double nuevoAhorro, double diferencia, NumberFormat formatter, Color color, IconData icon) {
    final user = context.read<SavingsProvider>().user!;
    final mesesParaMeta = nuevoAhorro > 0 ? (user.metaAhorro / nuevoAhorro).ceil() : -1;
    final mesesActuales = context.read<SavingsProvider>().estimarTiempoParaMeta(user.metaAhorro);
    final diferenciaMeses = mesesActuales > 0 && mesesParaMeta > 0 ? mesesActuales - mesesParaMeta : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: color),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nuevo ahorro mensual:'),
                      Text(
                        formatter.format(nuevoAhorro),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Diferencia:'),
                      Text(
                        '${diferencia >= 0 ? '+' : ''}${formatter.format(diferencia)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: diferencia >= 0 ? Colors.green : Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (mesesParaMeta > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Impacto en tu meta:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('• Tiempo para alcanzar meta: $mesesParaMeta meses'),
                    if (diferenciaMeses > 0)
                      Text('• Te ahorrarías $diferenciaMeses meses', style: const TextStyle(color: Colors.green)),
                    Text('• Ahorro anual: ${formatter.format(nuevoAhorro * 12)}'),
                  ],
                ),
              ),
            ] else if (nuevoAhorro <= 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Con este escenario no podrías ahorrar. Necesitas ajustar más tus finanzas.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
