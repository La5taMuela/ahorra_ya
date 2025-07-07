import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/savings_provider.dart';

class EnhancedProjectionsWidget extends StatelessWidget {
  final bool isPreview;

  const EnhancedProjectionsWidget({super.key, this.isPreview = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        if (user == null) return const SizedBox.shrink();

        final ahorroMensualNeto = provider.ahorroMensualNeto;
        final formatter = NumberFormat.currency(
            locale: 'es_CL', symbol: '\$', decimalDigits: 0);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tus Proyecciones de Ahorro',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descubre el potencial de tus ahorros a través del tiempo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),

              // Mostrar siempre las proyecciones, incluso con ahorro negativo
              if (!isPreview) ...[
                SizedBox(
                  height: 250,
                  child: _buildProjectionChart(provider),
                ),
                const SizedBox(height: 20),
              ],

              _buildProjectionCards(provider, formatter),

              if (!isPreview) ...[
                const SizedBox(height: 16),
                _buildAdviceCard(provider, formatter),
                const SizedBox(height: 16),
                _buildDetailedAnalysis(provider, formatter),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectionChart(SavingsProvider provider) {
    final user = provider.user!;
    final tieneModeloAvanzado = provider.tieneModeloCuadratico();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  tieneModeloAvanzado ? Icons.auto_awesome : Icons.trending_up,
                  color: const Color(0xFF2E7D32),
                ),
                const SizedBox(width: 8),
                Text(
                  tieneModeloAvanzado
                      ? 'Proyección Inteligente de Ahorros'
                      : 'Proyección de Ahorros',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            if (tieneModeloAvanzado)
              Text(
                'Proyección con crecimiento gradual activada',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 6,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${value.toInt()}m',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              NumberFormat.compact().format(value),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        37,
                        (index) => FlSpot(
                          index.toDouble(),
                          provider.proyectarAhorro(index),
                        ),
                      ),
                      isCurved: tieneModeloAvanzado,
                      color: const Color(0xFF2E7D32),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionCards(
      SavingsProvider provider, NumberFormat formatter) {
    final projections = [
      {'months': 3, 'label': '3 meses', 'description': 'Corto plazo'},
      {'months': 6, 'label': '6 meses', 'description': 'Fondo emergencia'},
      {'months': 12, 'label': '1 año', 'description': 'Meta anual'},
      {'months': 24, 'label': '2 años', 'description': 'Proyecto importante'},
      {'months': 36, 'label': '3 años', 'description': 'Gran inversión'},
      {'months': 60, 'label': '5 años', 'description': 'Largo plazo'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: isPreview ? 2 : projections.length,
          itemBuilder: (context, index) {
            final projection = projections[index];
            final months = projection['months'] as int;
            final label = projection['label'] as String;
            final description = projection['description'] as String;
            final amount = provider.proyectarAhorro(months);
            final isNegative = amount < 0;

            return Card(
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isNegative ? Colors.red[50] : Colors.green[50],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isNegative ? Icons.trending_down : _getTimeIcon(months),
                        color:
                            isNegative ? Colors.red : const Color(0xFF2E7D32),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              isNegative ? Colors.red : const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          formatter.format(amount.abs()),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isNegative
                                ? Colors.red
                                : const Color(0xFF2E7D32),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          isNegative ? 'Déficit' : description,
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                isNegative ? Colors.red[600] : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdviceCard(SavingsProvider provider, NumberFormat formatter) {
    final user = provider.user!;
    final ahorroMensual = provider.ahorroMensualNeto;
    final porcentajeAhorro =
        user.sueldo > 0 ? (ahorroMensual / user.sueldo) * 100 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ahorroMensual >= 0
                      ? (porcentajeAhorro >= 15
                          ? Icons.celebration
                          : Icons.lightbulb_outline)
                      : Icons.warning,
                  color: ahorroMensual >= 0
                      ? (porcentajeAhorro >= 15 ? Colors.green : Colors.orange)
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  ahorroMensual >= 0
                      ? (porcentajeAhorro >= 15
                          ? '¡Felicitaciones!'
                          : 'Consejos para Mejorar')
                      : '¡Atención Necesaria!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ahorroMensual >= 0
                        ? (porcentajeAhorro >= 15
                            ? Colors.green
                            : Colors.orange)
                        : Colors.red,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getAdviceMessage(
                  porcentajeAhorro.toDouble(), ahorroMensual, user.metaAhorro),
              style: const TextStyle(fontSize: 14),
            ),
            if (ahorroMensual < 0 || porcentajeAhorro < 15) ...[
              const SizedBox(height: 12),
              _buildImprovementTips(ahorroMensual < 0),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementTips(bool isNegative) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNegative ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNegative ? 'Acciones urgentes:' : 'Ideas para ahorrar más:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (isNegative) ...[
            const Text('• Revisa TODOS tus gastos inmediatamente',
                style: TextStyle(fontSize: 12)),
            const Text('• Elimina gastos no esenciales',
                style: TextStyle(fontSize: 12)),
            const Text('• Busca ingresos adicionales urgentemente',
                style: TextStyle(fontSize: 12)),
            const Text('• Considera cambios drásticos en tu estilo de vida',
                style: TextStyle(fontSize: 12)),
          ] else ...[
            const Text('• Revisa tus gastos en comida y entretenimiento',
                style: TextStyle(fontSize: 12)),
            const Text('• Busca ofertas antes de comprar',
                style: TextStyle(fontSize: 12)),
            const Text('• Considera ingresos extra los fines de semana',
                style: TextStyle(fontSize: 12)),
            const Text('• Usa transporte público cuando sea posible',
                style: TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis(
      SavingsProvider provider, NumberFormat formatter) {
    final user = provider.user!;
    final ahorroMensual = provider.ahorroMensualNeto;
    final gastosVariables = provider.gastosVariablesDelMes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Análisis Detallado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalysisRow('Ingresos mensuales:',
                formatter.format(user.sueldo), Colors.green),
            _buildAnalysisRow('Gastos fijos:',
                formatter.format(user.gastosFijos), Colors.red),
            _buildAnalysisRow('Gastos variables actuales:',
                formatter.format(gastosVariables), Colors.orange),
            const Divider(),
            _buildAnalysisRow(
              'Balance mensual:',
              formatter.format(ahorroMensual),
              ahorroMensual >= 0 ? Colors.green : Colors.red,
              isTotal: true,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos clave:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      '• Porcentaje de ahorro: ${((ahorroMensual / user.sueldo) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12)),
                  Text(
                      '• Gastos totales: ${formatter.format(user.gastosFijos + gastosVariables)}',
                      style: const TextStyle(fontSize: 12)),
                  Text(
                      '• Tiempo para meta: ${ahorroMensual > 0 ? "${(user.metaAhorro / ahorroMensual).ceil()} meses" : "No alcanzable"}',
                      style: const TextStyle(fontSize: 12)),
                  if (ahorroMensual > 0)
                    Text(
                        '• Ahorro anual proyectado: ${formatter.format(ahorroMensual * 12)}',
                        style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    const SizedBox(height: 12);

    if (provider.tieneModeloCuadratico())
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple[700], size: 16),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Proyecciones inteligentes activadas - Considera crecimiento gradual',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildAnalysisRow(String label, String value, Color color,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getAdviceMessage(
      double porcentajeAhorro, double ahorroMensual, double metaAhorro) {
    if (ahorroMensual < 0) {
      return 'Estás gastando más de lo que ganas. Es crítico que tomes medidas inmediatas para reducir gastos o aumentar ingresos.';
    }

    final mesesParaMeta = (metaAhorro / ahorroMensual).ceil();

    if (porcentajeAhorro >= 20) {
      return 'Eres un experto en ahorros. Con tu ritmo actual, alcanzarás tu meta en $mesesParaMeta meses. ¡Sigue así!';
    } else if (porcentajeAhorro >= 15) {
      return 'Muy buen trabajo. Estás ahorrando un ${porcentajeAhorro.toStringAsFixed(1)}% de tus ingresos. Alcanzarás tu meta en $mesesParaMeta meses.';
    } else if (porcentajeAhorro >= 10) {
      return 'Vas por buen camino, pero puedes mejorar. Con pequeños ajustes podrías ahorrar más y alcanzar tu meta más rápido.';
    } else {
      return 'Hay mucho espacio para mejorar. Enfócate en reducir gastos variables para acelerar tu progreso hacia la meta.';
    }
  }

  IconData _getTimeIcon(int months) {
    if (months <= 6) return Icons.speed;
    if (months <= 12) return Icons.calendar_view_month;
    if (months <= 36) return Icons.calendar_view_week;
    return Icons.calendar_view_day;
  }

  Widget _buildAdvancedMathAnalysis(
      SavingsProvider provider, NumberFormat formatter) {
    final user = provider.user!;
    final tiempoExtremo = provider.getTiempoExtremoAhorro();
    final concavidad = provider.getConcavidadAhorro();
    final tasaCambioMes1 = provider.getTasaCambioAhorro(1.0);
    final tasaCambioMes12 = provider.getTasaCambioAhorro(12.0);
    final tendenciaMes1 = provider.getTendenciaAhorro(1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Análisis Matemático Avanzado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Función Cuadrática: A(t) = ${user.ahorroCoefA.toStringAsFixed(4)}t² + ${user.ahorroCoefB.toStringAsFixed(2)}t + ${user.ahorroCoefC.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMathRow('Derivada (A\'(t) = 2at + b):',
                      'Tasa de cambio instantánea'),
                  _buildMathRow('• Mes 1:',
                      '${formatter.format(tasaCambioMes1)}/mes ($tendenciaMes1)'),
                  _buildMathRow('• Mes 12:',
                      '${formatter.format(tasaCambioMes12)}/mes (${provider.getTendenciaAhorro(12.0)})'),
                  const SizedBox(height: 8),
                  _buildMathRow('Segunda derivada (A\'\'(t) = 2a):',
                      concavidad.toStringAsFixed(4)),
                  _buildMathRow(
                      'Concavidad:',
                      concavidad > 0
                          ? 'Hacia arriba (aceleración positiva)'
                          : concavidad < 0
                              ? 'Hacia abajo (desaceleración)'
                              : 'Lineal'),
                  const SizedBox(height: 8),
                  if (!tiempoExtremo.isNaN) ...[
                    _buildMathRow('Punto extremo:',
                        '${tiempoExtremo.toStringAsFixed(2)} meses'),
                    _buildMathRow('Tipo de extremo:',
                        concavidad > 0 ? 'Mínimo' : 'Máximo'),
                    _buildMathRow(
                        'Valor en extremo:',
                        formatter.format(
                            provider.proyectarAhorro(tiempoExtremo.round()))),
                  ] else ...[
                    _buildMathRow('Punto extremo:',
                        'No definido (función lineal o sin extremo en dominio positivo)'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
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
                    'Interpretación Práctica:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (user.ahorroCoefA > 0) ...[
                    const Text('• Tu ahorro se acelera con el tiempo',
                        style: TextStyle(fontSize: 13)),
                    const Text('• Cada mes ahorras más que el anterior',
                        style: TextStyle(fontSize: 13)),
                    const Text('• Ideal para metas a largo plazo',
                        style: TextStyle(fontSize: 13)),
                  ] else if (user.ahorroCoefA < 0) ...[
                    const Text('• Tu ahorro se desacelera con el tiempo',
                        style: TextStyle(fontSize: 13)),
                    const Text('• Cada mes ahorras menos que el anterior',
                        style: TextStyle(fontSize: 13)),
                    const Text('• Considera revisar tu estrategia',
                        style: TextStyle(fontSize: 13)),
                  ] else ...[
                    const Text('• Tu ahorro es constante (modelo lineal)',
                        style: TextStyle(fontSize: 13)),
                    const Text('• Ahorras la misma cantidad cada mes',
                        style: TextStyle(fontSize: 13)),
                  ],
                  if (tasaCambioMes1 > 0) ...[
                    Text(
                        '• Actualmente tu ahorro está creciendo a ${formatter.format(tasaCambioMes1)} por mes',
                        style: const TextStyle(fontSize: 13)),
                  ] else if (tasaCambioMes1 < 0) ...[
                    Text(
                        '• Actualmente tu ahorro está decreciendo a ${formatter.format(tasaCambioMes1.abs())} por mes',
                        style: const TextStyle(fontSize: 13)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMathRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
