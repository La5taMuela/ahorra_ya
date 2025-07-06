import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/savings_provider.dart';
import '../../data/models/user_model.dart';
import '../../core/currency/currency_widgets.dart';
import '../../core/currency/currency_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _fixedExpensesController = TextEditingController();

  bool _isLoading = false;
  double _savingsPercentage = 20.0; // 20% por defecto

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = context.read<SavingsProvider>();
    if (provider.user != null) {
      final user = provider.user!;
      _incomeController.text = CurrencyService.format(user.monthlyIncome);
      _fixedExpensesController.text = CurrencyService.format(user.fixedExpenses);

      // Calcular porcentaje de ahorro actual
      if (user.monthlyIncome > 0) {
        _savingsPercentage = ((user.monthlyIncome - user.fixedExpenses - user.variableExpenses) / user.monthlyIncome) * 100;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Financiera'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),

              _buildSectionTitle('💰 Información Financiera'),
              _buildFinancialInfoSection(),
              const SizedBox(height: 24),

              _buildSectionTitle('🎯 Meta de Ahorro'),
              _buildSavingsGoalSection(),
              const SizedBox(height: 32),

              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: const Color(0xFF2E7D32).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.savings,
              size: 48,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 12),
            const Text(
              '¡Configura tu perfil financiero!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Solo necesitamos tu información financiera básica para ayudarte a optimizar tus ahorros',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }

  Widget _buildFinancialInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CurrencyTextFormField(
              controller: _incomeController,
              labelText: 'Sueldo mensual (${CurrencyService.currencyCode})',
              helperText: 'Ingresa tu sueldo líquido mensual',
              prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF2E7D32)),
              onChanged: (value) => _updateCalculations(),
            ),
            const SizedBox(height: 16),
            CurrencyTextFormField(
              controller: _fixedExpensesController,
              labelText: 'Gastos fijos mensuales (${CurrencyService.currencyCode})',
              helperText: 'Arriendo, servicios, seguros, etc.',
              prefixIcon: const Icon(Icons.home, color: Color(0xFF2E7D32)),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tus gastos fijos';
                }
                final amount = CurrencyService.parse(value);
                if (amount < 0) {
                  return 'Ingresa un monto válido';
                }
                return null;
              },
              onChanged: (value) => _updateCalculations(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsGoalSection() {
    final income = CurrencyService.parse(_incomeController.text);
    final fixedExpenses = CurrencyService.parse(_fixedExpensesController.text);
    final availableAmount = income - fixedExpenses;
    final savingsAmount = (availableAmount * _savingsPercentage / 100);
    final remainingAmount = availableAmount - savingsAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Porcentaje de ahorro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_savingsPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _savingsPercentage,
              min: 5,
              max: 50,
              divisions: 45,
              activeColor: const Color(0xFF2E7D32),
              onChanged: (value) {
                setState(() {
                  _savingsPercentage = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildCalculationSummary(income, fixedExpenses, savingsAmount, remainingAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationSummary(double income, double fixedExpenses, double savingsAmount, double remainingAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('💵 Sueldo mensual:', income),
          _buildSummaryRow('🏠 Gastos fijos:', fixedExpenses),
          const Divider(thickness: 2),
          _buildSummaryRow('💰 Ahorro mensual:', savingsAmount, isHighlight: true),
          _buildSummaryRow('🛒 Disponible para gastos:', remainingAmount),
          if (remainingAmount < 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tus gastos fijos superan tu sueldo. Revisa tu presupuesto.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? const Color(0xFF2E7D32) : null,
              fontSize: 14,
            ),
          ),
          CurrencyText(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlight ? const Color(0xFF2E7D32) : null,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Guardar Configuración',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _updateCalculations() {
    setState(() {});
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final income = CurrencyService.parse(_incomeController.text);
      final fixedExpenses = CurrencyService.parse(_fixedExpensesController.text);
      final availableAmount = income - fixedExpenses;
      final savingsAmount = (availableAmount * _savingsPercentage / 100);
      final variableExpenses = availableAmount - savingsAmount;

      final user = UserModel(
        id: context.read<SavingsProvider>().user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Usuario', // Nombre por defecto
        email: 'usuario@ahorraya.com', // Email por defecto
        monthlyIncome: income,
        fixedExpenses: fixedExpenses,
        variableExpenses: variableExpenses.clamp(0, double.infinity),
        createdAt: context.read<SavingsProvider>().user?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await context.read<SavingsProvider>().saveUser(user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Configuración guardada exitosamente'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _fixedExpensesController.dispose();
    super.dispose();
  }
}
