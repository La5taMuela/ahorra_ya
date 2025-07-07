import 'dart:math';

class SavingsCalculator {
  // Funciones existentes (lineales) - mantener para compatibilidad
  static double calcularAhorroMensualNeto(double sueldo, double gastosFijos, double gastosVariablesReales) {
    return sueldo - gastosFijos - gastosVariablesReales;
  }

  static double proyectarAhorroAcumulado(double ahorroMensual, int meses) {
    if (ahorroMensual <= 0) return 0;
    return ahorroMensual * meses;
  }

  static int estimarTiempoParaMeta(double metaAhorro, double ahorroMensual) {
    if (ahorroMensual <= 0) return -1;
    return (metaAhorro / ahorroMensual).ceil();
  }

  static double calcularGastosVariablesMaximos(double sueldo, double gastosFijos, double ahorroDeseado) {
    return sueldo - gastosFijos - ahorroDeseado;
  }

  static double simularCambioEnIngresos(double sueldoActual, double porcentajeCambio, double gastosFijos, double gastosVariables) {
    final nuevoSueldo = sueldoActual * (1 + porcentajeCambio / 100);
    return nuevoSueldo - gastosFijos - gastosVariables;
  }

  static double simularCambioEnGastos(double sueldo, double gastosFijos, double gastosVariablesActuales, double porcentajeCambio) {
    final nuevosGastosVariables = gastosVariablesActuales * (1 + porcentajeCambio / 100);
    return sueldo - gastosFijos - nuevosGastosVariables;
  }

  // NUEVAS FUNCIONES CUADRÁTICAS para mejorar las existentes

  /// Proyectar ahorro acumulado con modelo cuadrático
  static double proyectarAhorroCuadratico(double coefA, double coefB, double coefC, int meses) {
    final t = meses.toDouble();
    return coefA * t * t + coefB * t + coefC;
  }

  /// Estimar tiempo para alcanzar meta con modelo cuadrático
  static double estimarTiempoParaMetaCuadratico(double metaAhorro, double coefA, double coefB, double coefC) {
    // Si coefA es 0, se reduce a una ecuación lineal
    if (coefA.abs() < 1e-10) {
      if (coefB.abs() < 1e-10) return -1.0;
      return (metaAhorro - coefC) / coefB;
    }

    // Resolver a*t^2 + b*t + (c - metaAhorro) = 0
    final cPrime = coefC - metaAhorro;
    final discriminant = coefB * coefB - 4 * coefA * cPrime;

    if (discriminant < 0) {
      return -1.0; // Meta no alcanzable
    }

    final sqrtDiscriminant = sqrt(discriminant);
    final t1 = (-coefB + sqrtDiscriminant) / (2 * coefA);
    final t2 = (-coefB - sqrtDiscriminant) / (2 * coefA);

    // Retornar el tiempo positivo más pequeño
    if (t1 >= 0 && t2 >= 0) {
      return min(t1, t2);
    } else if (t1 >= 0) {
      return t1;
    } else if (t2 >= 0) {
      return t2;
    } else {
      return -1.0;
    }
  }

  /// Calcular coeficientes automáticamente basados en datos del usuario
  static Map<String, double> calcularCoeficientesAutomaticos({
    required double sueldo,
    required double gastosFijos,
    required double gastosVariablesEstimados,
    required double metaAhorro,
    double ahorroInicial = 0.0,
    double factorCrecimiento = 0.02, // 2% de crecimiento mensual
  }) {
    // Ahorro mensual neto inicial
    final ahorroMensualBase = sueldo - gastosFijos - gastosVariablesEstimados;

    // Coeficiente C: ahorro inicial
    final coefC = ahorroInicial;

    // Coeficiente B: ahorro mensual base
    final coefB = ahorroMensualBase;

    // Coeficiente A: factor de aceleración basado en el crecimiento esperado
    final coefA = ahorroMensualBase * factorCrecimiento / 12;

    return {
      'coefA': coefA,
      'coefB': coefB,
      'coefC': coefC,
    };
  }

  /// Calcular la derivada del ahorro (tasa de cambio instantánea)
  /// A'(t) = 2*a*t + b
  static double calcularDerivadaAhorro(double coefA, double coefB, double t) {
    return 2 * coefA * t + coefB;
  }

  /// Encontrar el extremo (máximo/mínimo) del ahorro
  /// Para A'(t) = 0 => 2*a*t + b = 0 => t = -b / (2*a)
  static double encontrarExtremoAhorro(double coefA, double coefB) {
    if (coefA.abs() < 1e-10) return double.nan; // No es cuadrática
    return -coefB / (2 * coefA);
  }

  /// Calcular la segunda derivada (concavidad)
  /// A''(t) = 2*a
  static double calcularSegundaDerivadaAhorro(double coefA) {
    return 2 * coefA;
  }

  /// Determinar si el modelo es creciente o decreciente en un punto
  static String analizarTendencia(double coefA, double coefB, double t) {
    final derivada = calcularDerivadaAhorro(coefA, coefB, t);
    if (derivada > 0) return 'Creciente';
    if (derivada < 0) return 'Decreciente';
    return 'Estable';
  }
}
