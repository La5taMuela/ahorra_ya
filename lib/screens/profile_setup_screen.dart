import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';
import '../providers/savings_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _sueldoController = TextEditingController();
  final _gastosFijosController = TextEditingController();
  final _metaAhorroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = context.read<SavingsProvider>();
    final userData = provider.user;

    if (userData != null) {
      _nombreController.text = userData.nombre;
      _sueldoController.text = userData.sueldo.toString();
      _gastosFijosController.text = userData.gastosFijos.toString();
      _metaAhorroController.text = userData.metaAhorro.toString();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _sueldoController.dispose();
    _gastosFijosController.dispose();
    _metaAhorroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurar Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 64,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cuéntanos sobre ti',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Esta información nos ayudará a personalizar tus recomendaciones de ahorro',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _sueldoController,
                decoration: const InputDecoration(
                  labelText: 'Sueldo mensual',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  helperText: 'Tu ingreso mensual total',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu sueldo';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _gastosFijosController,
                decoration: const InputDecoration(
                  labelText: 'Gastos fijos mensuales',
                  prefixIcon: Icon(Icons.home_outlined),
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  helperText: 'Arriendo, servicios, seguros, etc.',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tus gastos fijos';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _metaAhorroController,
                decoration: const InputDecoration(
                  labelText: 'Meta de ahorro',
                  prefixIcon: Icon(Icons.savings_outlined),
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  helperText: '¿Cuánto quieres ahorrar en total?',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu meta de ahorro';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Guardar Perfil'),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tus gastos variables (comida, transporte, entretenimiento) los registrarás día a día en la app.',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userData = UserData(
        nombre: _nombreController.text,
        sueldo: double.parse(_sueldoController.text),
        gastosFijos: double.parse(_gastosFijosController.text),
        gastosVariables: 0.0, // Se calculará automáticamente desde los gastos registrados
        metaAhorro: double.parse(_metaAhorroController.text),
      );

      context.read<SavingsProvider>().updateUserData(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Perfil guardado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
