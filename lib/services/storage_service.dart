import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';
import '../models/expense.dart';
import '../models/goal.dart';

class StorageService {
  static const String _userDataKey = 'user_data';
  static const String _expensesKey = 'expenses';
  static const String _goalsKey = 'goals';

  // User data methods
  static Future<void> saveUser(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(userData.toJson());
    await prefs.setString(_userDataKey, jsonString);
  }

  static Future<UserData?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userDataKey);

    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserData.fromJson(jsonMap);
    }
    return null;
  }

  // Expenses methods
  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = expenses.map((expense) => expense.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_expensesKey, jsonString);
  }

  static Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_expensesKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Goals methods
  static Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = goals.map((goal) => goal.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_goalsKey, jsonString);
  }

  static Future<List<Goal>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_goalsKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Goal.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_expensesKey);
    await prefs.remove(_goalsKey);
  }

  // Legacy methods for compatibility
  static Future<void> saveUserData(UserData userData) async {
    await saveUser(userData);
  }

  static Future<UserData?> getUserData() async {
    return await getUser();
  }

  static Future<void> clearUserData() async {
    await clearAll();
  }

  static Future<List<Map<String, dynamic>>> getCalculationHistory() async {
    return []; // Empty for compatibility
  }
}
