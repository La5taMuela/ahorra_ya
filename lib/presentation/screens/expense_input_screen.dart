import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/savings_provider.dart';
import '../../data/models/expense_model.dart';
import '../../utils/currency_formatter.dart' hide CLPInputFormatter;
import '../../utils/clp_input_formatter.dart';

class ExpenseInputScreen extends StatefulWidget {
  const ExpenseInputScreen({super.key});

  @override
  State<ExpenseInputScreen> createState() => _ExpenseInputScreenState();
}

class _ExpenseInputScreenState extends State<ExpenseInputScreen> {
  final List<ExpenseRow> _expenses = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<String> _categories = [
    'Alimentación',
    'Transporte',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Servicios',
    'Ropa',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _addNewRow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💸 Registrar Gastos'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addNewRow,
            tooltip: 'Agregar fila',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExpenses,
            tooltip: 'Guardar gastos',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBudgetAlert(),
          _buildInstructions(),
          _buildHeader(),
          Expanded(
            child: _buildExpenseTable(),
          ),
          _buildSummary(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF2E7D32).withOpacity(0.1),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF2E7D32), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Agrega tus gastos como en una planilla Excel. Puedes ingresar millones (ej: 3.000.000).',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetAlert() {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        if (provider.user == null) return const SizedBox.shrink();

        final currentMonthExpenses = provider.monthlyExpenses;
        final budget = provider.user!.variableExpenses;
        final totalNewExpenses = _expenses
            .where((e) => e.isValid())
            .fold(0.0, (sum, e) => sum + e.getAmount());
        final projectedTotal = currentMonthExpenses + totalNewExpenses;

        if (projectedTotal > budget) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.red[100],
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🚨 ¡Alerta! Excederás tu presupuesto en \$${CurrencyFormatter.formatCLP((projectedTotal - budget))}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF2E7D32).withOpacity(0.1),
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text('📝 Descripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 3, child: Text('💰 Monto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 3, child: Text('📂 Categoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          SizedBox(width: 40), // Para el botón de eliminar
        ],
      ),
    );
  }

  Widget _buildExpenseTable() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        return _buildExpenseRow(index);
      },
    );
  }

  Widget _buildExpenseRow(int index) {
    final expense = _expenses[index];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
        color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
      ),
      child: Row(
        children: [
          // Descripción
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: expense.descriptionController,
              decoration: const InputDecoration(
                hintText: 'Ej: Almuerzo, Gasolina...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
              onChanged: (value) => _updateSummary(),
            ),
          ),
          const SizedBox(width: 8),

          // Monto
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: expense.amountController,
              decoration: const InputDecoration(
                hintText: '50.000',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                prefixText: '\$ ',
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CLPInputFormatter(),
              ],
              onChanged: (value) => _updateSummary(),
            ),
          ),
          const SizedBox(width: 8),

          // Categoría
          Expanded(
            flex: 3,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: expense.category,
                  isExpanded: true,
                  hint: const Text('Seleccionar', style: TextStyle(fontSize: 10)),
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      expense.category = value;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botón eliminar
          SizedBox(
            width: 32,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 16),
              onPressed: () => _removeRow(index),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final total = _expenses
        .where((e) => e.isValid())
        .fold(0.0, (sum, e) => sum + e.getAmount());

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2E7D32).withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: \$${CurrencyFormatter.formatCLP(total)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          Text(
            '${_expenses.where((e) => e.isValid()).length} gastos válidos',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _addNewRow,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Fila'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveExpenses,
              icon: _isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Guardando...' : 'Guardar Todo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewRow() {
    setState(() {
      _expenses.add(ExpenseRow());
    });

    // Scroll al final después de agregar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeRow(int index) {
    setState(() {
      _expenses[index].dispose();
      _expenses.removeAt(index);
    });
    _updateSummary();
  }

  void _updateSummary() {
    setState(() {});
  }

  Future<void> _saveExpenses() async {
    final validExpenses = _expenses.where((e) => e.isValid()).toList();

    if (validExpenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No hay gastos válidos para guardar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<SavingsProvider>();

      for (final expenseRow in validExpenses) {
        final expense = ExpenseModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + expenseRow.hashCode.toString(),
          userId: provider.user?.id ?? 'default',
          description: expenseRow.descriptionController.text,
          amount: expenseRow.getAmount(),
          category: expenseRow.category ?? 'Otros',
          date: DateTime.now(),
          isRecurring: false,
        );

        await provider.addExpense(expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${validExpenses.length} gastos guardados exitosamente'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar gastos: $e'),
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
    for (final expense in _expenses) {
      expense.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}

class ExpenseRow {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String? category;

  bool isValid() {
    return descriptionController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        getAmount() > 0 &&
        category != null;
  }

  double getAmount() {
    return CurrencyFormatter.parseAmount(amountController.text);
  }

  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
  }
}
