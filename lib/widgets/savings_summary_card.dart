import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/savings_provider.dart';

class SavingsSummaryCard extends StatelessWidget {
  const SavingsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        if (user == null) return const SizedBox.shrink();

        final formatter = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);
        final ahorroMensualNeto = provider.ahorroMensualNeto;
        final gastosVariablesDelMes = provider.gastosVariablesDelMes;
        final porcentajeAhorro = user.sueldo > 0 ? (ahorroMensualNeto / user.sueldo) * 100 : 0;

        return Card(
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ahorroMensualNeto >= 0 ? const Color(0xFF2E7D32) : Colors.red[700]!,
                  ahorroMensualNeto >= 0 ? const Color(0xFF388E3C) : Colors.red[500]!,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        ahorroMensualNeto >= 0 ? Icons.account_balance_wallet : Icons.warning,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¡Hola ${user.nombre}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildSummaryRow(
                    ahorroMensualNeto >= 0 ? 'Tu ahorro este mes' : 'Déficit este mes',
                    formatter.format(ahorroMensualNeto.abs()),
                    ahorroMensualNeto >= 0 ? Icons.trending_up : Icons.trending_down,
                    Colors.white,
                  ),

                  const SizedBox(height: 12),

                  _buildSummaryRow(
                    'Gastos variables del mes',
                    formatter.format(gastosVariablesDelMes),
                    Icons.shopping_cart,
                    Colors.white70,
                  ),

                  const SizedBox(height: 12),

                  _buildSummaryRow(
                    'Ingresos mensuales',
                    formatter.format(user.sueldo),
                    Icons.attach_money,
                    Colors.white70,
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getMotivationIcon(porcentajeAhorro.toDouble()),
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getMotivationMessage(porcentajeAhorro.toDouble(), ahorroMensualNeto),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getMotivationIcon(double porcentajeAhorro) {
    if (porcentajeAhorro < 0) return Icons.warning;
    if (porcentajeAhorro >= 20) return Icons.star;
    if (porcentajeAhorro >= 10) return Icons.thumb_up;
    if (porcentajeAhorro >= 5) return Icons.trending_up;
    return Icons.info;
  }

  String _getMotivationMessage(double porcentajeAhorro, double ahorroMensual) {
    if (ahorroMensual < 0) {
      return '¡Atención! Estás gastando ${porcentajeAhorro.abs().toStringAsFixed(1)}% más de lo que ganas. Necesitas actuar ya.';
    }

    if (porcentajeAhorro >= 20) {
      return '¡Excelente! Estás ahorrando ${porcentajeAhorro.toStringAsFixed(1)}% de tus ingresos. ¡Eres un campeón del ahorro!';
    } else if (porcentajeAhorro >= 15) {
      return '¡Muy bien! Ahorras ${porcentajeAhorro.toStringAsFixed(1)}% de tus ingresos. Vas por buen camino.';
    } else if (porcentajeAhorro >= 10) {
      return 'Buen trabajo. Ahorras ${porcentajeAhorro.toStringAsFixed(1)}% de tus ingresos. Puedes mejorar un poco más.';
    } else if (porcentajeAhorro >= 5) {
      return 'Vas bien, pero puedes mejorar. Intenta reducir algunos gastos variables.';
    } else {
      return 'Es hora de tomar acción. Revisa tus gastos y encuentra oportunidades de ahorro.';
    }
  }
}
