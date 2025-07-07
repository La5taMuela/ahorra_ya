import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/savings_provider.dart';

class SmartExpenseTracker extends StatelessWidget {
  const SmartExpenseTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        if (user == null) return const SizedBox.shrink();

        final currentMonth = DateTime.now();
        final monthlyExpenses = provider.getTotalExpensesForMonth(currentMonth);
        final ahorroMensualNeto = provider.ahorroMensualNeto;
        final presupuestoDisponible = provider.gastosVariablesDelMes > 0 ? provider.gastosVariablesDelMes : user.gastosVariables;
        final gastoRestante = presupuestoDisponible - monthlyExpenses;
        final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

        // Cálculos para alertas inteligentes
        final porcentajeGastado = monthlyExpenses / presupuestoDisponible;
        final diasDelMes = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
        final diaActual = currentMonth.day;
        final porcentajeMesTranscurrido = diaActual / diasDelMes;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Text(
                      'Control Inteligente de Gastos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Resumen del mes actual
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gastoRestante >= 0 ? Colors.green[50]! : Colors.red[50]!,
                        gastoRestante >= 0 ? Colors.green[100]! : Colors.red[100]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: gastoRestante >= 0 ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Presupuesto mensual:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            formatter.format(presupuestoDisponible),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gastado hasta hoy:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            formatter.format(monthlyExpenses),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: monthlyExpenses > presupuestoDisponible ? Colors.red : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            gastoRestante >= 0 ? 'Te queda disponible:' : 'Te has excedido por:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: gastoRestante >= 0 ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                          Text(
                            formatter.format(gastoRestante.abs()),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: gastoRestante >= 0 ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Barra de progreso visual
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Progreso del mes:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${(porcentajeGastado * 100).toStringAsFixed(1)}% gastado'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: porcentajeGastado.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        porcentajeGastado > 1.0 ? Colors.red :
                        porcentajeGastado > 0.8 ? Colors.orange :
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Alertas y consejos inteligentes
                _buildSmartAlert(porcentajeGastado, porcentajeMesTranscurrido, gastoRestante, diasDelMes - diaActual),

                const SizedBox(height: 16),

                // Impacto en el ahorro
                _buildSavingsImpact(ahorroMensualNeto, gastoRestante, formatter),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmartAlert(double porcentajeGastado, double porcentajeMesTranscurrido, double gastoRestante, int diasRestantes) {
    IconData icon;
    Color color;
    String titulo;
    String mensaje;

    if (gastoRestante < 0) {
      icon = Icons.warning;
      color = Colors.red;
      titulo = '⚠️ ¡Te has excedido!';
      mensaje = 'Has gastado más de tu presupuesto mensual. Considera reducir gastos para mantener tu meta de ahorro.';
    } else if (porcentajeGastado > porcentajeMesTranscurrido + 0.2) {
      icon = Icons.speed;
      color = Colors.orange;
      titulo = '🚨 Gastando muy rápido';
      mensaje = 'Estás gastando más rápido de lo esperado para este punto del mes. Modera el ritmo para llegar bien a fin de mes.';
    } else if (porcentajeGastado < porcentajeMesTranscurrido - 0.2) {
      icon = Icons.thumb_up;
      color = Colors.green;
      titulo = '✅ ¡Excelente control!';
      mensaje = 'Vas muy bien con tus gastos. Podrías incluso ahorrar más este mes.';
    } else {
      icon = Icons.trending_up;
      color = Colors.blue;
      titulo = '📊 Ritmo normal';
      mensaje = 'Tus gastos van a un ritmo normal para este punto del mes.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mensaje,
                  style: TextStyle(color: color),
                ),
                if (diasRestantes > 0 && gastoRestante > 0)
                  Text(
                    'Puedes gastar ${NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0).format(gastoRestante / diasRestantes)} por día los próximos $diasRestantes días.',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsImpact(double ahorroMensualNeto, double gastoRestante, NumberFormat formatter) {
    final ahorroRealEsperado = ahorroMensualNeto + gastoRestante;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.savings, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Impacto en tu Ahorro',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ahorro planificado:'),
              Text(
                formatter.format(ahorroMensualNeto),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ahorro real esperado:'),
              Text(
                formatter.format(ahorroRealEsperado),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ahorroRealEsperado > ahorroMensualNeto ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (ahorroRealEsperado != ahorroMensualNeto)
            Text(
              ahorroRealEsperado > ahorroMensualNeto
                  ? '🎉 ¡Podrías ahorrar ${formatter.format(ahorroRealEsperado - ahorroMensualNeto)} extra!'
                  : '⚠️ Ahorrarás ${formatter.format(ahorroMensualNeto - ahorroRealEsperado)} menos de lo planeado',
              style: TextStyle(
                color: ahorroRealEsperado > ahorroMensualNeto ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
