class SavingsResult {
  final double ahorroMensualNeto;
  final double ahorroAcumulado;
  final double tiempoParaMeta;
  final double gastosVariablesMaximos;

  SavingsResult({
    required this.ahorroMensualNeto,
    required this.ahorroAcumulado,
    required this.tiempoParaMeta,
    required this.gastosVariablesMaximos,
  });
}

class SimulationResult {
  final double ahorroActual;
  final double nuevoAhorro;
  final double diferencia;

  SimulationResult({
    required this.ahorroActual,
    required this.nuevoAhorro,
    required this.diferencia,
  });
}
