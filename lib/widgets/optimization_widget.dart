import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/savings_provider.dart';

class OptimizationWidget extends StatelessWidget {
  const OptimizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        if (user == null) return const SizedBox.shrink();

        final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);
        final ahorroMensual = provider.ahorroMensualNeto;
        final gastosVariables = provider.gastosVariablesDelMes;
        final porcentajeAhorro = user.sueldo > 0 ? (ahorroMensual / user.sueldo) * 100 : 0;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Optimiza tus Finanzas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descubre cómo mejorar tu situación financiera',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              _buildCurrentStatusCard(ahorroMensual, porcentajeAhorro.toDouble(), formatter),
              const SizedBox(height: 16),

              _buildOptimizationCards(provider, formatter),
              const SizedBox(height: 16),

              _buildRecommendationsCard(porcentajeAhorro.toDouble(), gastosVariables, formatter),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentStatusCard(double ahorroMensual, double porcentajeAhorro, NumberFormat formatter) {
    final isGood = porcentajeAhorro >= 15;
    final isOk = porcentajeAhorro >= 10;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              isGood ? Colors.green : (isOk ? Colors.orange : Colors.red),
              isGood ? Colors.green[300]! : (isOk ? Colors.orange[300]! : Colors.red[300]!),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                isGood ? Icons.sentiment_very_satisfied : (isOk ? Icons.sentiment_neutral : Icons.sentiment_dissatisfied),
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _getStatusTitle(porcentajeAhorro),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ahorras ${formatter.format(ahorroMensual)} mensual (${porcentajeAhorro.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getStatusMessage(porcentajeAhorro),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizationCards(SavingsProvider provider, NumberFormat formatter) {
    final user = provider.user!;
    final ahorroActual = provider.ahorroMensualNeto;

    // Escenarios de optimización
    final scenarios = [
      {
        'title': 'Reducir Gastos 10%',
        'description': 'Ahorra en gastos variables',
        'icon': Icons.trending_down,
        'color': Colors.blue,
        'savings': (provider.gastosVariablesDelMes * 0.1).toDouble(),
        'newTotal': (ahorroActual + (provider.gastosVariablesDelMes * 0.1)).toDouble(),
      },
      {
        'title': 'Reducir Gastos 20%',
        'description': 'Optimización más agresiva',
        'icon': Icons.trending_down,
        'color': Colors.green,
        'savings': (provider.gastosVariablesDelMes * 0.2).toDouble(),
        'newTotal': (ahorroActual + (provider.gastosVariablesDelMes * 0.2)).toDouble(),
      },
      {
        'title': 'Ingresos Extra 15%',
        'description': 'Trabajos de fin de semana',
        'icon': Icons.trending_up,
        'color': Colors.purple,
        'savings': (user.sueldo * 0.15).toDouble(),
        'newTotal': (ahorroActual + (user.sueldo * 0.15)).toDouble(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escenarios de Mejora',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        ...scenarios.map((scenario) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (scenario['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      scenario['icon'] as IconData,
                      color: scenario['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          scenario['description'] as String,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nuevo ahorro: ${formatter.format(scenario['newTotal'] as double)}',
                          style: TextStyle(
                            color: scenario['color'] as Color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${formatter.format(scenario['savings'] as double)}',
                    style: TextStyle(
                      color: scenario['color'] as Color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildRecommendationsCard(double porcentajeAhorro, double gastosVariables, NumberFormat formatter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Recomendaciones Personalizadas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._getPersonalizedRecommendations(porcentajeAhorro, gastosVariables, formatter),
          ],
        ),
      ),
    );
  }

  List<Widget> _getPersonalizedRecommendations(double porcentajeAhorro, double gastosVariables, NumberFormat formatter) {
    List<Widget> recommendations = [];

    if (porcentajeAhorro < 5) {
      recommendations.addAll([
        _buildRecommendationItem(
          Icons.warning,
          'Situación Crítica',
          'Necesitas reducir gastos urgentemente. Revisa cada gasto del mes.',
          Colors.red,
        ),
        _buildRecommendationItem(
          Icons.restaurant,
          'Comida',
          'Cocina más en casa. Puedes ahorrar hasta \$50.000 mensual.',
          Colors.orange,
        ),
      ]);
    } else if (porcentajeAhorro < 10) {
      recommendations.addAll([
        _buildRecommendationItem(
          Icons.trending_up,
          'Vas Mejorando',
          'Estás en el camino correcto. Pequeños ajustes te ayudarán mucho.',
          Colors.orange,
        ),
        _buildRecommendationItem(
          Icons.local_taxi,
          'Transporte',
          'Usa transporte público o camina más. Ahorra en combustible.',
          Colors.blue,
        ),
      ]);
    } else if (porcentajeAhorro < 15) {
      recommendations.addAll([
        _buildRecommendationItem(
          Icons.thumb_up,
          'Buen Trabajo',
          'Tienes buenos hábitos. Optimiza para llegar al 15-20%.',
          Colors.green,
        ),
        _buildRecommendationItem(
          Icons.shopping_cart,
          'Compras Inteligentes',
          'Compara precios y busca ofertas antes de comprar.',
          Colors.purple,
        ),
      ]);
    } else {
      recommendations.addAll([
        _buildRecommendationItem(
          Icons.star,
          '¡Excelente!',
          'Eres un experto en ahorros. Considera invertir tu dinero.',
          Colors.green,
        ),
        _buildRecommendationItem(
          Icons.account_balance,
          'Inversiones',
          'Con tu disciplina, podrías considerar inversiones a largo plazo.',
          Colors.indigo,
        ),
      ]);
    }

    return recommendations;
  }

  Widget _buildRecommendationItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusTitle(double porcentajeAhorro) {
    if (porcentajeAhorro >= 20) return '¡Eres un Campeón!';
    if (porcentajeAhorro >= 15) return '¡Muy Bien!';
    if (porcentajeAhorro >= 10) return 'Buen Trabajo';
    if (porcentajeAhorro >= 5) return 'Puedes Mejorar';
    return 'Necesitas Ayuda';
  }

  String _getStatusMessage(double porcentajeAhorro) {
    if (porcentajeAhorro >= 20) return 'Tienes excelentes hábitos financieros';
    if (porcentajeAhorro >= 15) return 'Estás en el rango ideal de ahorro';
    if (porcentajeAhorro >= 10) return 'Vas por buen camino, sigue así';
    if (porcentajeAhorro >= 5) return 'Con pequeños cambios puedes mejorar mucho';
    return 'Es momento de tomar acción inmediata';
  }
}
