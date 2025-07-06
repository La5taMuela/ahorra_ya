import 'dart:math' as math;

class MathService {
  // Cálculo de ahorro óptimo usando derivadas
  static double calculateOptimalSavings({
    required double monthlyIncome,
    required double fixedExpenses,
    required double variableExpenses,
    required double targetAmount,
    required int monthsToTarget,
    double interestRate = 0.05, // 5% anual por defecto
  }) {
    final availableAmount = monthlyIncome - fixedExpenses - variableExpenses;

    // Si no hay dinero disponible, no se puede ahorrar
    if (availableAmount <= 0) return 0;

    // Cálculo con interés compuesto usando límites
    final monthlyRate = interestRate / 12;

    if (monthlyRate == 0 || monthsToTarget <= 0) {
      // Sin interés, cálculo lineal
      return monthsToTarget > 0 ? targetAmount / monthsToTarget : 0;
    }

    // Fórmula de anualidad para alcanzar meta con interés compuesto
    final denominator = (math.pow(1 + monthlyRate, monthsToTarget) - 1) / monthlyRate;
    final requiredSavings = targetAmount / denominator;

    // Optimización: no exceder el 70% del dinero disponible
    final maxRecommendedSavings = availableAmount * 0.7;

    return math.min(requiredSavings, maxRecommendedSavings);
  }

  // Cálculo de tiempo necesario para alcanzar meta
  static int calculateTimeToGoal({
    required double targetAmount,
    required double monthlySavings,
    double interestRate = 0.05,
  }) {
    if (monthlySavings <= 0) return -1;

    final monthlyRate = interestRate / 12;

    if (monthlyRate == 0) {
      return (targetAmount / monthlySavings).ceil();
    }

    // Usando logaritmos para resolver la ecuación exponencial
    final numerator = math.log(1 + (targetAmount * monthlyRate) / monthlySavings);
    final denominator = math.log(1 + monthlyRate);

    return (numerator / denominator).ceil();
  }

  // Proyección de crecimiento usando interés compuesto
  static List<double> projectSavingsGrowth({
    required double monthlySavings,
    required int months,
    double interestRate = 0.05,
  }) {
    final monthlyRate = interestRate / 12;
    final projections = <double>[];
    double currentAmount = 0;

    for (int i = 0; i <= months; i++) {
      projections.add(currentAmount);
      currentAmount = currentAmount * (1 + monthlyRate) + monthlySavings;
    }

    return projections;
  }

  // Análisis de sensibilidad usando derivadas parciales
  static Map<String, double> sensitivityAnalysis({
    required double monthlyIncome,
    required double fixedExpenses,
    required double variableExpenses,
    required double targetAmount,
    required int monthsToTarget,
  }) {
    const delta = 0.01; // 1% de cambio

    final baseOptimal = calculateOptimalSavings(
      monthlyIncome: monthlyIncome,
      fixedExpenses: fixedExpenses,
      variableExpenses: variableExpenses,
      targetAmount: targetAmount,
      monthsToTarget: monthsToTarget,
    );

    // Derivada parcial respecto al ingreso
    final incomeDerivative = (calculateOptimalSavings(
      monthlyIncome: monthlyIncome * (1 + delta),
      fixedExpenses: fixedExpenses,
      variableExpenses: variableExpenses,
      targetAmount: targetAmount,
      monthsToTarget: monthsToTarget,
    ) - baseOptimal) / (monthlyIncome * delta);

    // Derivada parcial respecto a gastos variables
    final expenseDerivative = (calculateOptimalSavings(
      monthlyIncome: monthlyIncome,
      fixedExpenses: fixedExpenses,
      variableExpenses: variableExpenses * (1 + delta),
      targetAmount: targetAmount,
      monthsToTarget: monthsToTarget,
    ) - baseOptimal) / (variableExpenses * delta);

    return {
      'incomeImpact': incomeDerivative,
      'expenseImpact': expenseDerivative,
    };
  }

  // Optimización dinámica para ajustes mensuales
  static double dynamicAdjustment({
    required double currentSavings,
    required double actualExpenses,
    required double budgetedExpenses,
    required double remainingMonths,
  }) {
    final expenseDifference = actualExpenses - budgetedExpenses;

    if (remainingMonths <= 0) return currentSavings;

    // Ajuste proporcional distribuido en los meses restantes
    final monthlyAdjustment = expenseDifference / remainingMonths;

    return math.max(0, currentSavings - monthlyAdjustment);
  }
}
