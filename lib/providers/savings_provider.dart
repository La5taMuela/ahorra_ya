import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/models/savings_goal_model.dart';
import '../data/models/expense_model.dart';
import '../services/cache_service.dart';
import '../services/math_service.dart';
import 'package:intl/intl.dart';

class SavingsProvider extends ChangeNotifier {
  UserModel? _user;
  List<SavingsGoalModel> _savingsGoals = [];
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;
  String? _budgetAlert;
  String? get budgetAlert => _budgetAlert;

  // Getters
  UserModel? get user => _user;
  List<SavingsGoalModel> get savingsGoals => _savingsGoals;
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculated properties
  double get totalSaved => _savingsGoals.fold(0, (sum, goal) => sum + goal.currentAmount);
  double get totalTarget => _savingsGoals.fold(0, (sum, goal) => sum + goal.targetAmount);
  double get monthlyExpenses => _expenses
      .where((e) => e.date.month == DateTime.now().month)
      .fold(0, (sum, expense) => sum + expense.amount);

  // Initialize data from cache
  Future<void> initializeData() async {
    _setLoading(true);
    try {
      _user = await CacheService.getUser();
      _savingsGoals = await CacheService.getSavingsGoals();
      _expenses = await CacheService.getExpenses();
      _clearError();
    } catch (e) {
      _setError('Error loading data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // User management
  Future<void> saveUser(UserModel user) async {
    _setLoading(true);
    try {
      await CacheService.saveUser(user);
      _user = user;
      _clearError();
    } catch (e) {
      _setError('Error saving user: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Savings goals management
  Future<void> addSavingsGoal(SavingsGoalModel goal) async {
    _setLoading(true);
    try {
      _savingsGoals.add(goal);
      await CacheService.saveSavingsGoals(_savingsGoals);
      _clearError();
    } catch (e) {
      _setError('Error adding savings goal: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSavingsGoal(SavingsGoalModel updatedGoal) async {
    _setLoading(true);
    try {
      final index = _savingsGoals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        _savingsGoals[index] = updatedGoal;
        await CacheService.saveSavingsGoals(_savingsGoals);
      }
      _clearError();
    } catch (e) {
      _setError('Error updating savings goal: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSavingsGoal(String goalId) async {
    _setLoading(true);
    try {
      _savingsGoals.removeWhere((goal) => goal.id == goalId);
      await CacheService.saveSavingsGoals(_savingsGoals);
      _clearError();
    } catch (e) {
      _setError('Error deleting savings goal: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Expense management
  Future<void> addExpense(ExpenseModel expense) async {
    _setLoading(true);
    try {
      _expenses.add(expense);
      await CacheService.saveExpenses(_expenses);
      _checkBudgetAlert();
      _clearError();
    } catch (e) {
      _setError('Error adding expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  // NUEVAS FUNCIONES PARA GASTOS
  Future<void> updateExpense(ExpenseModel updatedExpense) async {
    _setLoading(true);
    try {
      final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
        await CacheService.saveExpenses(_expenses);
        _checkBudgetAlert();
      }
      _clearError();
    } catch (e) {
      _setError('Error updating expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    _setLoading(true);
    try {
      _expenses.removeWhere((expense) => expense.id == expenseId);
      await CacheService.saveExpenses(_expenses);
      _checkBudgetAlert();
      _clearError();
    } catch (e) {
      _setError('Error deleting expense: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Mathematical calculations
  double calculateOptimalSavings(SavingsGoalModel goal) {
    if (_user == null) return 0;

    final monthsToTarget = goal.targetDate.difference(DateTime.now()).inDays ~/ 30;

    return MathService.calculateOptimalSavings(
      monthlyIncome: _user!.monthlyIncome,
      fixedExpenses: _user!.fixedExpenses,
      variableExpenses: _user!.variableExpenses,
      targetAmount: goal.remainingAmount,
      monthsToTarget: monthsToTarget,
    );
  }

  List<double> getProjections(SavingsGoalModel goal) {
    final optimalSavings = calculateOptimalSavings(goal);
    final monthsToTarget = goal.targetDate.difference(DateTime.now()).inDays ~/ 30;

    return MathService.projectSavingsGrowth(
      monthlySavings: optimalSavings,
      months: monthsToTarget,
    );
  }

  // Budget alerts
  void _checkBudgetAlert() {
    if (_user == null) return;

    final currentMonthExpenses = monthlyExpenses;
    final budgetLimit = _user!.variableExpenses;
    final percentageUsed = budgetLimit > 0 ? (currentMonthExpenses / budgetLimit) * 100 : 0;

    if (currentMonthExpenses > budgetLimit) {
      _budgetAlert = '¡Presupuesto excedido! Has gastado \$${NumberFormat('#,###', 'es_CL').format((currentMonthExpenses - budgetLimit).toInt())} más de lo planeado';
      _setError(_budgetAlert!);
    } else if (percentageUsed > 80) {
      _budgetAlert = 'Atención: Has usado ${percentageUsed.toStringAsFixed(1)}% de tu presupuesto mensual';
    } else if (percentageUsed > 60) {
      _budgetAlert = 'Vas bien: Has usado ${percentageUsed.toStringAsFixed(1)}% de tu presupuesto mensual';
    } else {
      _budgetAlert = null;
    }
  }

  void clearBudgetAlert() {
    _budgetAlert = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
