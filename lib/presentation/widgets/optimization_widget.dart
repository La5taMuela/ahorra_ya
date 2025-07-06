import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/savings_provider.dart';
import '../screens/analysis_screen.dart';
import '../../utils/currency_formatter.dart';

class OptimizationWidget extends StatelessWidget {
  const OptimizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        if (provider.user == null) {
          return _buildNoUserState(context);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ARREGLADO EL OVERFLOW AQUÍ
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 Análisis Rápido',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToFullAnalysis(context),
                      icon: const Icon(Icons.analytics),
                      label: const Text('Ver Análisis Completo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildQuickStats(provider),
              const SizedBox(height: 24),
              _buildOptimizationCards(provider),
              const SizedBox(height: 24),
              _buildActionRecommendations(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoUserState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Configura tu perfil financiero',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Necesitamos tu información financiera para generar análisis y optimizaciones personalizadas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(SavingsProvider provider) {
    final user = provider.user!;
    final monthlyExpenses = provider.monthlyExpenses;
    final availableForSaving = user.monthlyIncome - user.fixedExpenses - monthlyExpenses;
    final savingsRate = user.monthlyIncome > 0 ? (availableForSaving / user.monthlyIncome) * 100 : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Tasa de Ahorro',
                '${savingsRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                savingsRate >= 20 ? Colors.green : savingsRate >= 10 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Disponible',
                CurrencyFormatter.formatCLPWithSymbol(availableForSaving),
                Icons.account_balance_wallet,
                availableForSaving >= 0 ? const Color(0xFF2E7D32) : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Gastos del Mes',
          CurrencyFormatter.formatCLPWithSymbol(monthlyExpenses),
          Icons.receipt_long,
          monthlyExpenses <= user.variableExpenses ? Colors.blue : Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationCards(SavingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💡 Optimizaciones Sugeridas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.savingsGoals.map((goal) => _buildGoalOptimization(goal, provider)),
        if (provider.savingsGoals.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Crea metas de ahorro para recibir optimizaciones personalizadas'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to goals
                    },
                    child: const Text('Crear Meta'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGoalOptimization(goal, SavingsProvider provider) {
    final optimalSavings = provider.calculateOptimalSavings(goal);
    final monthsToTarget = goal.targetDate.difference(DateTime.now()).inDays ~/ 30;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: _getCategoryColor(goal.category)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildOptimizationMetric(
                    'Ahorro Óptimo',
                    '${CurrencyFormatter.formatCLPWithSymbol(optimalSavings)}/mes',
                    Icons.savings,
                    const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOptimizationMetric(
                    'Tiempo Estimado',
                    monthsToTarget > 0 ? '$monthsToTarget meses' : 'Meta vencida',
                    Icons.schedule,
                    monthsToTarget > 0 ? Colors.blue : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecommendation(optimalSavings, goal, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(double optimalSavings, goal, SavingsProvider provider) {
    String recommendation;
    Color color;
    IconData icon;

    final user = provider.user!;
    final availableForSaving = user.monthlyIncome - user.fixedExpenses - provider.monthlyExpenses;

    if (optimalSavings <= 0 || optimalSavings > availableForSaving) {
      recommendation = 'Necesitas reducir gastos o aumentar ingresos para esta meta.';
      color = Colors.red;
      icon = Icons.warning;
    } else if (optimalSavings > availableForSaving * 0.8) {
      recommendation = 'Esta meta requiere la mayoría de tu dinero disponible. Considera extender el plazo.';
      color = Colors.orange;
      icon = Icons.info;
    } else {
      recommendation = '¡Meta alcanzable! Sigue el plan de ahorro optimizado.';
      color = Colors.green;
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRecommendations(SavingsProvider provider) {
    final recommendations = _generateRecommendations(provider);

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 Acciones Recomendadas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...recommendations.map((rec) => Card(
          child: ListTile(
            leading: Icon(rec['icon'], color: rec['color']),
            title: Text(rec['title']),
            subtitle: Text(rec['description']),
            trailing: rec['action'] != null
                ? TextButton(
              onPressed: rec['action'],
              child: const Text('Acción'),
            )
                : null,
          ),
        )),
      ],
    );
  }

  List<Map<String, dynamic>> _generateRecommendations(SavingsProvider provider) {
    final recommendations = <Map<String, dynamic>>[];
    final user = provider.user!;
    final monthlyExpenses = provider.monthlyExpenses;

    // Recomendación sobre presupuesto excedido
    if (monthlyExpenses > user.variableExpenses) {
      recommendations.add({
        'icon': Icons.warning,
        'color': Colors.red,
        'title': 'Presupuesto Excedido',
        'description': 'Has gastado más de lo planeado este mes',
        'action': null,
      });
    }

    // Recomendación sobre crear metas
    if (provider.savingsGoals.isEmpty) {
      recommendations.add({
        'icon': Icons.flag,
        'color': Colors.blue,
        'title': 'Crear Metas de Ahorro',
        'description': 'Define objetivos específicos para mantener la motivación',
        'action': null,
      });
    }

    // Recomendación sobre tasa de ahorro baja
    final savingsRate = user.monthlyIncome > 0
        ? ((user.monthlyIncome - user.fixedExpenses - monthlyExpenses) / user.monthlyIncome) * 100
        : 0;

    if (savingsRate < 10) {
      recommendations.add({
        'icon': Icons.trending_up,
        'color': Colors.orange,
        'title': 'Mejorar Tasa de Ahorro',
        'description': 'Tu tasa de ahorro es baja. Intenta reducir gastos variables',
        'action': null,
      });
    }

    return recommendations;
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

  void _navigateToFullAnalysis(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalysisScreen(),
      ),
    );
  }
}
