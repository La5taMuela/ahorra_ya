import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';
import '../providers/savings_provider.dart';
import '../services/savings_calculator.dart';

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
  final _ahorroInicialController = TextEditingController();
  final _factorCrecimientoController = TextEditingController();

  bool _usarModeloAvanzado = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _factorCrecimientoController.text = '2.0'; // Valor por defecto 2%
  }

  void _loadExistingData() {
    final provider = context.read<SavingsProvider>();
    final userData = provider.user;

    if (userData != null) {
      _nombreController.text = userData.nombre;
      _sueldoController.text = userData.sueldo.toString();
      _gastosFijosController.text = userData.gastosFijos.toString();
      _metaAhorroController.text = userData.metaAhorro.toString();

      // Verificar si ya tiene modelo cuadrático
      if (userData.ahorroCoefA != 0.0 || userData.ahorroCoefB != 0.0 || userData.ahorroCoefC != 0.0) {
        _usarModeloAvanzado = true;
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _sueldoController.dispose();
    _gastosFijosController.dispose();
    _metaAhorroController.dispose();
    _ahorroInicialController.dispose();
    _factorCrecimientoController.dispose();
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
                        'Configuración de Perfil Financiero',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configura tu información para obtener proyecciones precisas',
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

              // Información básica
              _buildBasicInfoSection(),

              const SizedBox(height: 24),

              // Modelo de ahorro avanzado
              _buildAdvancedModelSection(),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Guardar Configuración'),
              ),

              const SizedBox(height: 16),

              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),

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
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedModelSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.purple[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'Proyecciones Avanzadas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Utiliza algoritmos avanzados para proyecciones más precisas',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Activar Proyecciones Inteligentes'),
              subtitle: const Text('Proyecciones que consideran crecimiento gradual del ahorro'),
              value: _usarModeloAvanzado,
              onChanged: (value) {
                setState(() {
                  _usarModeloAvanzado = value;
                });
              },
              activeColor: Colors.purple[700],
            ),

            if (_usarModeloAvanzado) ...[
              const SizedBox(height: 16),

              TextFormField(
                controller: _ahorroInicialController,
                decoration: const InputDecoration(
                  labelText: 'Ahorro inicial (opcional)',
                  prefixIcon: Icon(Icons.account_balance),
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  helperText: 'Dinero que ya tienes ahorrado',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _factorCrecimientoController,
                decoration: const InputDecoration(
                  labelText: 'Expectativa de crecimiento mensual (%)',
                  prefixIcon: Icon(Icons.trending_up),
                  border: OutlineInputBorder(),
                  helperText: 'Ej: 2.0 para 2% de mejora mensual en ahorro',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Información Importante',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Los gastos variables se registran día a día en la app\n'
                '• El modelo cuadrático permite proyecciones más realistas\n'
                '• Puedes cambiar entre modelos en cualquier momento',
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final sueldo = double.parse(_sueldoController.text);
      final gastosFijos = double.parse(_gastosFijosController.text);
      final metaAhorro = double.parse(_metaAhorroController.text);

      double coefA = 0.0;
      double coefB = 0.0;
      double coefC = 0.0;

      if (_usarModeloAvanzado) {
        // Calcular coeficientes automáticamente
        final ahorroInicial = double.tryParse(_ahorroInicialController.text) ?? 0.0;
        final factorCrecimiento = double.tryParse(_factorCrecimientoController.text) ?? 2.0;

        final coeficientes = SavingsCalculator.calcularCoeficientesAutomaticos(
          sueldo: sueldo,
          gastosFijos: gastosFijos,
          gastosVariablesEstimados: 0.0, // Se calculará dinámicamente
          metaAhorro: metaAhorro,
          ahorroInicial: ahorroInicial,
          factorCrecimiento: factorCrecimiento / 100, // Convertir porcentaje
        );

        coefA = coeficientes['coefA']!;
        coefB = coeficientes['coefB']!;
        coefC = coeficientes['coefC']!;
      }

      final userData = UserData(
        nombre: _nombreController.text,
        sueldo: sueldo,
        gastosFijos: gastosFijos,
        gastosVariables: 0.0, // Se sigue calculando dinámicamente
        metaAhorro: metaAhorro,
        ahorroCoefA: coefA,
        ahorroCoefB: coefB,
        ahorroCoefC: coefC,
      );

      context.read<SavingsProvider>().updateUserData(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _usarModeloAvanzado
                  ? '¡Perfil guardado con modelo cuadrático activado!'
                  : '¡Perfil guardado exitosamente!'
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
