import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/savings_provider.dart';

class ProjectionsWidget extends StatelessWidget {
  final bool isPreview;

  const ProjectionsWidget({super.key, this.isPreview = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        if (user == null) return const SizedBox.shrink();

        final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proyecciones de Ahorro',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            if (!isPreview) ...[
              SizedBox(
                height: 300,
                child: _buildProjectionChart(provider),
              ),
              const SizedBox(height: 20),
            ],
            _buildProjectionCards(provider, formatter),
          ],
        );
      },
    );
  }

  Widget _buildProjectionChart(SavingsProvider provider) {
    final ahorroMensual = provider.ahorroMensualNeto;
    if (ahorroMensual <= 0) {
      return const Center(
        child: Text(
          'No es posible generar proyecciones con ahorro negativo',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    return Text('${value.toInt()}m');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  25,
                      (index) => FlSpot(
                    index.toDouble(),
                    provider.proyectarAhorro(index),
                  ),
                ),
                isCurved: false,
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
    );
  }

  Widget _buildProjectionCards(SavingsProvider provider, NumberFormat formatter) {
    final projections = [
      {'months': 6, 'label': '6 meses'},
      {'months': 12, 'label': '1 año'},
      {'months': 24, 'label': '2 años'},
      {'months': 36, 'label': '3 años'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isPreview ? 2 : 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: isPreview ? 2 : projections.length,
      itemBuilder: (context, index) {
        final projection = projections[index];
        final months = projection['months'] as int;
        final label = projection['label'] as String;
        final amount = provider.proyectarAhorro(months);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
