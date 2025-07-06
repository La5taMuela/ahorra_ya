import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/savings_provider.dart';
import '../../services/math_service.dart';
import '../../utils/currency_formatter.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _selectedPeriod = 0; // 0: Este mes, 1: Últimos 3 meses, 2: Últimos 6 meses

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Análisis Financiero'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, child) {
          if (provider.user == null) {
            return _buildNoDataState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeMessage(provider),
                const SizedBox(height: 24),
                _buildFinancialHealthScore(provider),
                const SizedBox(height: 24),
                _buildDetailedAnalysis(provider),
                const SizedBox(height: 24),
                _buildExpensesByCategory(provider),
                const SizedBox(height: 24),
                _buildSavingsProjection(provider),
                const SizedBox(height: 24),
                _buildPersonalizedTips(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Sin datos para analizar',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configura tu perfil financiero para ver análisis detallados',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage(SavingsProvider provider) {
    final savingsRate = _calculateSavingsRate(provider);

    String message;
    Color color;
    IconData icon;

    if (savingsRate >= 20) {
      message = "¡Excelente! Tienes una salud financiera muy buena. Sigues ahorrando de manera consistente.";
      color = Colors.green;
      icon = Icons.sentiment_very_satisfied;
    } else if (savingsRate >= 10) {
      message = "Vas por buen camino. Tu tasa de ahorro es saludable, pero puedes mejorar un poco más.";
      color = Colors.orange;
      icon = Icons.sentiment_satisfied;
    } else {
      message = "Es momento de revisar tus finanzas. Tu tasa de ahorro está por debajo de lo recomendado.";
      color = Colors.red;
      icon = Icons.sentiment_dissatisfied;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, tu análisis está listo 👋',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
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

  Widget _buildFinancialHealthScore(SavingsProvider provider) {
    final score = _calculateFinancialHealthScore(provider);
    final color = _getScoreColor(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '🏥 Salud Financiera',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'puntos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreDescription(score),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedAnalysis(SavingsProvider provider) {
    final user = provider.user!;
    final monthlyExpenses = provider.monthlyExpenses;
    final savingsRate = _calculateSavingsRate(provider);
    final availableForSaving = user.monthlyIncome - user.fixedExpenses - monthlyExpenses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Análisis Detallado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAnalysisItem(
              '💰 Ingresos Mensuales',
              CurrencyFormatter.formatCLP(user.monthlyIncome),
              'Este es tu sueldo líquido mensual. Es la base de tu presupuesto.',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildAnalysisItem(
              '🏠 Gastos Fijos',
              CurrencyFormatter.formatCLP(user.fixedExpenses),
              'Gastos que no puedes evitar como arriendo, servicios básicos, seguros. Representan ${((user.fixedExpenses / user.monthlyIncome) * 100).toStringAsFixed(1)}% de tus ingresos.',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildAnalysisItem(
              '🛒 Gastos Variables',
              CurrencyFormatter.formatCLP(monthlyExpenses),
              'Gastos que puedes controlar como comida, entretenimiento, compras. ${monthlyExpenses > user.variableExpenses ? "¡Has excedido tu presupuesto!" : "Dentro del presupuesto."}',
              monthlyExpenses > user.variableExpenses ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildAnalysisItem(
              '💎 Capacidad de Ahorro',
              CurrencyFormatter.formatCLP(availableForSaving),
              'Dinero que te queda después de todos los gastos. Tu tasa de ahorro es ${savingsRate.toStringAsFixed(1)}%. ${savingsRate >= 20 ? "¡Excelente!" : savingsRate >= 10 ? "Bueno, pero puedes mejorar." : "Necesitas ahorrar más."}',
              availableForSaving > 0 ? const Color(0xFF2E7D32) : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String value, String explanation, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesByCategory(SavingsProvider provider) {
    final expenses = provider.expenses;
    final categoryTotals = <String, double>{};

    for (final expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    if (categoryTotals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Sin gastos registrados',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Comienza a registrar tus gastos para ver este análisis',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    final totalExpenses = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🥧 ¿En qué gastas más dinero?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí puedes ver dónde va tu dinero. La categoría más grande es donde más gastas.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryTotals.entries.map((entry) {
                    final percentage = (entry.value / totalExpenses) * 100;
                    return PieChartSectionData(
                      color: _getCategoryColor(entry.key),
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...sortedCategories.take(3).map((entry) {
              final percentage = (entry.value / totalExpenses) * 100;
              return _buildCategoryInsight(
                entry.key,
                entry.value,
                percentage,
                _getCategoryColor(entry.key),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInsight(String category, double amount, double percentage, Color color) {
    String insight = '';
    if (percentage > 40) {
      insight = 'Esta categoría consume mucho de tu presupuesto. Considera revisar estos gastos.';
    } else if (percentage > 25) {
      insight = 'Una parte importante de tus gastos. Mantén un control sobre esta categoría.';
    } else {
      insight = 'Gastos controlados en esta categoría.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${CurrencyFormatter.formatCLP(amount)} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  insight,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsProjection(SavingsProvider provider) {
    if (provider.savingsGoals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.trending_up, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Crea metas para ver proyecciones',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Las proyecciones te muestran cómo crecerán tus ahorros en el tiempo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    final goal = provider.savingsGoals.first;
    final projections = provider.getProjections(goal);
    final optimalSavings = provider.calculateOptimalSavings(goal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📈 Proyección: ${goal.title}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Si ahorras \$${CurrencyFormatter.formatCLP(optimalSavings)} cada mes, así crecerán tus ahorros:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${NumberFormat.compact().format(value)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}m',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: projections.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: const Color(0xFF2E7D32),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 La línea muestra cómo crecerán tus ahorros mes a mes. El crecimiento es exponencial gracias al interés compuesto.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedTips(SavingsProvider provider) {
    final tips = _generatePersonalizedTips(provider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Consejos Personalizados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Basado en tu situación financiera, aquí tienes algunos consejos:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => _buildTipCard(tip)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tip['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tip['color'].withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tip['icon'], color: tip['color'], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: tip['color'],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['description'],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _calculateSavingsRate(SavingsProvider provider) {
    final user = provider.user!;
    final monthlyExpenses = provider.monthlyExpenses;
    final availableForSaving = user.monthlyIncome - user.fixedExpenses - monthlyExpenses;
    return user.monthlyIncome > 0 ? (availableForSaving / user.monthlyIncome) * 100 : 0;
  }

  double _calculateFinancialHealthScore(SavingsProvider provider) {
    final savingsRate = _calculateSavingsRate(provider);
    final user = provider.user!;
    final monthlyExpenses = provider.monthlyExpenses;

    double score = 0;

    // Tasa de ahorro (40 puntos máximo)
    if (savingsRate >= 20) score += 40;
    else if (savingsRate >= 15) score += 30;
    else if (savingsRate >= 10) score += 20;
    else if (savingsRate >= 5) score += 10;

    // Control de gastos (30 puntos máximo)
    if (monthlyExpenses <= user.variableExpenses * 0.8) score += 30;
    else if (monthlyExpenses <= user.variableExpenses) score += 20;
    else if (monthlyExpenses <= user.variableExpenses * 1.2) score += 10;

    // Metas de ahorro (20 puntos máximo)
    if (provider.savingsGoals.isNotEmpty) {
      score += 20;
    }

    // Diversificación de gastos (10 puntos máximo)
    final categories = provider.expenses.map((e) => e.category).toSet();
    if (categories.length >= 4) score += 10;
    else if (categories.length >= 2) score += 5;

    return score.clamp(0, 100);
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return 'Excelente salud financiera. ¡Sigue así!';
    if (score >= 60) return 'Buena salud financiera. Hay espacio para mejorar.';
    if (score >= 40) return 'Salud financiera regular. Necesitas hacer algunos ajustes.';
    return 'Salud financiera preocupante. Es hora de tomar acción.';
  }

  List<Map<String, dynamic>> _generatePersonalizedTips(SavingsProvider provider) {
    final tips = <Map<String, dynamic>>[];
    final user = provider.user!;
    final monthlyExpenses = provider.monthlyExpenses;
    final savingsRate = _calculateSavingsRate(provider);

    // Tip sobre tasa de ahorro
    if (savingsRate < 10) {
      tips.add({
        'icon': Icons.trending_up,
        'color': Colors.red,
        'title': 'Aumenta tu tasa de ahorro',
        'description': 'Tu tasa de ahorro es ${savingsRate.toStringAsFixed(1)}%. Los expertos recomiendan ahorrar al menos 10-20% de tus ingresos. Intenta reducir gastos no esenciales.',
      });
    } else if (savingsRate >= 20) {
      tips.add({
        'icon': Icons.star,
        'color': Colors.green,
        'title': '¡Excelente disciplina!',
        'description': 'Tu tasa de ahorro del ${savingsRate.toStringAsFixed(1)}% está por encima del promedio. Considera invertir parte de tus ahorros para hacerlos crecer más.',
      });
    }

    // Tip sobre presupuesto
    if (monthlyExpenses > user.variableExpenses) {
      tips.add({
        'icon': Icons.warning,
        'color': Colors.orange,
        'title': 'Controla tus gastos variables',
        'description': 'Has excedido tu presupuesto en \$${CurrencyFormatter.formatCLP((monthlyExpenses - user.variableExpenses))}. Revisa tus gastos recientes y identifica dónde puedes recortar.',
      });
    }

    // Tip sobre metas
    if (provider.savingsGoals.isEmpty) {
      tips.add({
        'icon': Icons.flag,
        'color': Colors.blue,
        'title': 'Define metas claras',
        'description': 'Tener metas específicas te ayuda a mantener la motivación. Crea al menos una meta de ahorro con fecha límite.',
      });
    }

    // Tip sobre diversificación de gastos
    final categories = provider.expenses.map((e) => e.category).toSet();
    if (categories.length < 3 && provider.expenses.isNotEmpty) {
      tips.add({
        'icon': Icons.pie_chart,
        'color': Colors.purple,
        'title': 'Diversifica tus categorías',
        'description': 'Registra gastos en diferentes categorías para tener un mejor control y análisis de tus finanzas.',
      });
    }

    // Tip sobre gastos fijos altos
    final fixedExpenseRatio = (user.fixedExpenses / user.monthlyIncome) * 100;
    if (fixedExpenseRatio > 50) {
      tips.add({
        'icon': Icons.home,
        'color': Colors.red,
        'title': 'Gastos fijos muy altos',
        'description': 'Tus gastos fijos representan ${fixedExpenseRatio.toStringAsFixed(1)}% de tus ingresos. Considera renegociar contratos o buscar alternativas más económicas.',
      });
    }

    return tips;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'alimentación':
        return Colors.orange;
      case 'transporte':
        return Colors.blue;
      case 'entretenimiento':
        return Colors.purple;
      case 'salud':
        return Colors.red;
      case 'educación':
        return Colors.green;
      case 'servicios':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
