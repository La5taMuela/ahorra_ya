import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/user_data.dart';
import '../models/expense.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';
import '../services/savings_calculator.dart';

class SavingsProvider with ChangeNotifier {
  UserData? _user;
  List<Expense> _expenses = [];
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  UserData? get user => _user;
  List<Expense> get expenses => _expenses;
  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getter para compatibilidad con archivos existentes
  UserData? get userData => _user;

  double get ahorroMensualNeto {
    if (_user == null) return 0;
    final gastosVariablesReales = _getGastosVariablesDelMes();
    return SavingsCalculator.calcularAhorroMensualNeto(
      _user!.sueldo,
      _user!.gastosFijos,
      gastosVariablesReales,
    );
  }

  double get gastosVariablesDelMes {
    return _getGastosVariablesDelMes();
  }

  // Getter para compatibilidad
  Map<String, double>? get currentResult {
    if (_user == null) return null;
    return {
      'ahorroMensualNeto': ahorroMensualNeto,
      'ahorroAcumulado': proyectarAhorro(12),
      'tiempoParaMeta': estimarTiempoParaMeta(_user!.metaAhorro).toDouble(),
      'gastosVariablesMaximos': calcularGastosVariablesMaximos(_user!.sueldo * 0.1),
    };
  }

  double _getGastosVariablesDelMes() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthlyExpenses = _expenses
        .where((expense) =>
    expense.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
        expense.date.isBefore(endOfMonth.add(const Duration(days: 1))))
        .fold(0.0, (sum, expense) => sum + expense.amount);

    // If no expenses recorded this month, use the user's estimated gastosVariables
    return monthlyExpenses > 0 ? monthlyExpenses : (_user?.gastosVariables ?? 0.0);
  }

  Future<void> initializeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await StorageService.getUser();
      _expenses = await StorageService.getExpenses();
      _goals = await StorageService.getGoals();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar los datos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserData(UserData userData) async {
    try {
      await StorageService.saveUser(userData);
      _user = userData;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al guardar los datos: $e';
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      _expenses.add(expense);
      await StorageService.saveExpenses(_expenses);
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar el gasto: $e';
      notifyListeners();
    }
  }

  Future<void> removeExpense(String id) async {
    try {
      _expenses.removeWhere((expense) => expense.id == id);
      await StorageService.saveExpenses(_expenses);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar el gasto: $e';
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    try {
      _goals.add(goal);
      await StorageService.saveGoals(_goals);
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar la meta: $e';
      notifyListeners();
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        await StorageService.saveGoals(_goals);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar la meta: $e';
      notifyListeners();
    }
  }

  Future<void> updateGoalProgress(String id, double amount) async {
    try {
      final index = _goals.indexWhere((goal) => goal.id == id);
      if (index != -1) {
        _goals[index] = _goals[index].copyWith(currentAmount: amount);
        await StorageService.saveGoals(_goals);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar el progreso: $e';
      notifyListeners();
    }
  }

  Future<void> removeGoal(String id) async {
    try {
      _goals.removeWhere((goal) => goal.id == id);
      await StorageService.saveGoals(_goals);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar la meta: $e';
      notifyListeners();
    }
  }

  Future<void> clearData() async {
    try {
      await StorageService.clearAll();
      _user = null;
      _expenses = [];
      _goals = [];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al limpiar los datos: $e';
      notifyListeners();
    }
  }

  // Funciones matemáticas
  double proyectarAhorro(int meses) {
    if (_user == null) return 0;

    // Si los coeficientes están definidos, usar el modelo cuadrático
    if (_user!.ahorroCoefA != 0.0 || _user!.ahorroCoefB != 0.0 || _user!.ahorroCoefC != 0.0) {
      return SavingsCalculator.proyectarAhorroCuadratico(
        _user!.ahorroCoefA,
        _user!.ahorroCoefB,
        _user!.ahorroCoefC,
        meses,
      );
    }

    // Fallback al modelo lineal
    return SavingsCalculator.proyectarAhorroAcumulado(ahorroMensualNeto, meses);
  }

  int estimarTiempoParaMeta(double metaAhorro) {
    if (_user == null) return -1;

    // Si los coeficientes están definidos, usar el modelo cuadrático
    if (_user!.ahorroCoefA != 0.0 || _user!.ahorroCoefB != 0.0 || _user!.ahorroCoefC != 0.0) {
      double time = SavingsCalculator.estimarTiempoParaMetaCuadratico(
        metaAhorro,
        _user!.ahorroCoefA,
        _user!.ahorroCoefB,
        _user!.ahorroCoefC,
      );
      return time >= 0 ? time.ceil() : -1;
    }

    // Fallback al modelo lineal
    return SavingsCalculator.estimarTiempoParaMeta(metaAhorro, ahorroMensualNeto);
  }

  double calcularGastosVariablesMaximos(double ahorroDeseado) {
    if (_user == null) return 0;
    return SavingsCalculator.calcularGastosVariablesMaximos(
      _user!.sueldo,
      _user!.gastosFijos,
      ahorroDeseado,
    );
  }

  double simularCambioIngresos(double porcentajeCambio) {
    if (_user == null) return 0;
    return SavingsCalculator.simularCambioEnIngresos(
      _user!.sueldo,
      porcentajeCambio,
      _user!.gastosFijos,
      gastosVariablesDelMes,
    );
  }

  double simularCambioGastos(double porcentajeCambio) {
    if (_user == null) return 0;
    return SavingsCalculator.simularCambioEnGastos(
      _user!.sueldo,
      _user!.gastosFijos,
      gastosVariablesDelMes,
      porcentajeCambio,
    );
  }

  // Métodos para compatibilidad con widgets existentes
  double getTotalExpensesForMonth(DateTime month) {
    return _expenses
        .where((expense) {
      return expense.date.year == month.year && expense.date.month == month.month;
    })
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getExpensesByCategory(DateTime month) {
    final monthExpenses = _expenses.where((expense) {
      return expense.date.year == month.year && expense.date.month == month.month;
    });

    final Map<String, double> categoryTotals = {};
    for (final expense in monthExpenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  // Métodos de simulación para compatibilidad
  Map<String, double> simulateIncomeChange(double nuevoSueldo) {
    if (_user == null) return {};
    final ahorroActual = ahorroMensualNeto;
    final nuevoAhorro = SavingsCalculator.calcularAhorroMensualNeto(
      nuevoSueldo,
      _user!.gastosFijos,
      gastosVariablesDelMes,
    );
    return {
      'ahorroActual': ahorroActual,
      'nuevoAhorro': nuevoAhorro,
      'diferencia': nuevoAhorro - ahorroActual,
    };
  }

  Map<String, double> simulateExpenseChange(double nuevosGastosFijos, double nuevosGastosVariables) {
    if (_user == null) return {};
    final ahorroActual = ahorroMensualNeto;
    final nuevoAhorro = SavingsCalculator.calcularAhorroMensualNeto(
      _user!.sueldo,
      nuevosGastosFijos,
      nuevosGastosVariables,
    );
    return {
      'ahorroActual': ahorroActual,
      'nuevoAhorro': nuevoAhorro,
      'diferencia': nuevoAhorro - ahorroActual,
    };
  }

  double calculateMaxVariableExpenses(double ahorroObjetivo) {
    return calcularGastosVariablesMaximos(ahorroObjetivo);
  }

  // Nuevos métodos para exponer las funciones de cálculo avanzadas
  double getTasaCambioAhorro(double t) {
    if (_user == null) return 0;
    return SavingsCalculator.calcularDerivadaAhorro(_user!.ahorroCoefA, _user!.ahorroCoefB, t);
  }

  double getTiempoExtremoAhorro() {
    if (_user == null) return double.nan;
    return SavingsCalculator.encontrarExtremoAhorro(_user!.ahorroCoefA, _user!.ahorroCoefB);
  }

  double getConcavidadAhorro() {
    if (_user == null) return 0;
    return SavingsCalculator.calcularSegundaDerivadaAhorro(_user!.ahorroCoefA);
  }

  String getTendenciaAhorro(double t) {
    if (_user == null) return 'Desconocida';
    return SavingsCalculator.analizarTendencia(_user!.ahorroCoefA, _user!.ahorroCoefB, t);
  }

  bool tieneModeloCuadratico() {
    if (_user == null) return false;
    return _user!.ahorroCoefA != 0.0 || _user!.ahorroCoefB != 0.0 || _user!.ahorroCoefC != 0.0;
  }
}
