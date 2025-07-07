class SavingsCalculator {
  // Función 1: Calcular ahorro mensual neto
  static double calcularAhorroMensualNeto(double sueldo, double gastosFijos, double gastosVariablesReales) {
    return sueldo - gastosFijos - gastosVariablesReales;
  }

  // Función 2: Proyectar ahorro acumulado
  static double proyectarAhorroAcumulado(double ahorroMensual, int meses) {
    if (ahorroMensual <= 0) return 0;
    return ahorroMensual * meses;
  }

  // Función 3: Estimar tiempo para alcanzar meta
  static int estimarTiempoParaMeta(double metaAhorro, double ahorroMensual) {
    if (ahorroMensual <= 0) return -1; // Imposible alcanzar la meta
    return (metaAhorro / ahorroMensual).ceil();
  }

  // Función 4: Calcular gastos variables máximos
  static double calcularGastosVariablesMaximos(double sueldo, double gastosFijos, double ahorroDeseado) {
    return sueldo - gastosFijos - ahorroDeseado;
  }

  // Función 5: Simular cambio en ingresos
  static double simularCambioEnIngresos(double sueldoActual, double porcentajeCambio, double gastosFijos, double gastosVariables) {
    final nuevoSueldo = sueldoActual * (1 + porcentajeCambio / 100);
    return nuevoSueldo - gastosFijos - gastosVariables;
  }

  // Función 6: Simular cambio en gastos
  static double simularCambioEnGastos(double sueldo, double gastosFijos, double gastosVariablesActuales, double porcentajeCambio) {
    final nuevosGastosVariables = gastosVariablesActuales * (1 + porcentajeCambio / 100);
    return sueldo - gastosFijos - nuevosGastosVariables;
  }
}
