import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahorra_ya/data/models/user_model.dart';
import 'package:ahorra_ya/data/models/savings_goal_model.dart';
import 'package:ahorra_ya/data/models/expense_model.dart';

class CacheService {
  static const String _userKey = 'user_data';
  static const String _goalsKey = 'savings_goals';
  static const String _expensesKey = 'expenses_data';
  static const String _settingsKey = 'app_settings';
  
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  // User data
  static Future<bool> saveUser(UserModel user) async {
    await init();
    final userJson = jsonEncode(user.toJson());
    return await _prefs!.setString(_userKey, userJson);
  }
  
  static Future<UserModel?> getUser() async {
    await init();
    final userJson = _prefs!.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }
  
  // Savings goals
  static Future<bool> saveSavingsGoals(List<SavingsGoalModel> goals) async {
    await init();
    final goalsJson = jsonEncode(goals.map((g) => g.toJson()).toList());
    return await _prefs!.setString(_goalsKey, goalsJson);
  }
  
  static Future<List<SavingsGoalModel>> getSavingsGoals() async {
    await init();
    final goalsJson = _prefs!.getString(_goalsKey);
    if (goalsJson == null) return [];
    
    try {
      final goalsList = jsonDecode(goalsJson) as List;
      return goalsList.map((g) => SavingsGoalModel.fromJson(g)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Expenses
  static Future<bool> saveExpenses(List<ExpenseModel> expenses) async {
    await init();
    final expensesJson = jsonEncode(expenses.map((e) => e.toJson()).toList());
    return await _prefs!.setString(_expensesKey, expensesJson);
  }
  
  static Future<List<ExpenseModel>> getExpenses() async {
    await init();
    final expensesJson = _prefs!.getString(_expensesKey);
    if (expensesJson == null) return [];
    
    try {
      final expensesList = jsonDecode(expensesJson) as List;
      return expensesList.map((e) => ExpenseModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // App settings
  static Future<bool> saveSetting(String key, dynamic value) async {
    await init();
    final settings = await getSettings();
    settings[key] = value;
    final settingsJson = jsonEncode(settings);
    return await _prefs!.setString(_settingsKey, settingsJson);
  }
  
  static Future<Map<String, dynamic>> getSettings() async {
    await init();
    final settingsJson = _prefs!.getString(_settingsKey);
    if (settingsJson == null) return {};
    
    try {
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
  
  // Clear all data
  static Future<bool> clearAllData() async {
    await init();
    return await _prefs!.clear();
  }
}
