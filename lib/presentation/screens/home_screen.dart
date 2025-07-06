import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../providers/savings_provider.dart';
import '../widgets/savings_summary_card.dart';
import '../widgets/goals_list_widget.dart';
import '../widgets/expense_tracker_widget.dart';
import '../widgets/optimization_widget.dart';
import 'profile_setup_screen.dart';
import 'expense_input_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsProvider>().initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AHORRA YA!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          // Botón principal + para agregar gastos
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
            onPressed: () => _navigateToExpenseInput(),
            tooltip: 'Agregar gastos',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => _navigateToProfileSetup(),
            tooltip: 'Configurar perfil',
          ),
        ],
      ),
      body: ResponsiveBreakpoints.of(context).isMobile
          ? _buildMobileLayout()
          : _buildWebLayout(),
      bottomNavigationBar: ResponsiveBreakpoints.of(context).isMobile
          ? _buildBottomNavigation()
          : null,
      floatingActionButton: ResponsiveBreakpoints.of(context).isMobile
          ? FloatingActionButton(
        onPressed: () => _navigateToExpenseInput(),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Agregar gastos',
      )
          : null,
    );
  }

  Widget _buildMobileLayout() {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF2E7D32)),
                SizedBox(height: 16),
                Text('Cargando datos financieros...'),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.initializeData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        // Mostrar mensaje de bienvenida si no hay usuario configurado
        if (provider.user == null) {
          return _buildWelcomeScreen();
        }

        return IndexedStack(
          index: _selectedIndex,
          children: const [
            _DashboardTab(),
            _GoalsTab(),
            _ExpensesTab(),
            _OptimizationTab(),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.savings,
              size: 100,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Bienvenido a AHORRA YA!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Tu asistente financiero inteligente que usa matemáticas avanzadas para optimizar tus ahorros',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToProfileSetup(),
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Comenzar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Consumer<SavingsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          children: [
            // Sidebar navigation for web
            Container(
              width: 250,
              color: const Color(0xFF2E7D32),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                  _buildNavItem(1, Icons.savings, 'Metas'),
                  _buildNavItem(2, Icons.receipt_long, 'Gastos'),
                  _buildNavItem(3, Icons.analytics, 'Optimización'),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToExpenseInput(),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Gastos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: provider.user == null
                  ? _buildWelcomeScreen()
                  : IndexedStack(
                index: _selectedIndex,
                children: const [
                  _DashboardTab(),
                  _GoalsTab(),
                  _ExpensesTab(),
                  _OptimizationTab(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2E7D32),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.savings),
          label: 'Metas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Gastos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Análisis',
        ),
      ],
    );
  }

  void _navigateToProfileSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSetupScreen(),
      ),
    );
  }

  void _navigateToExpenseInput() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExpenseInputScreen(),
      ),
    );
  }
}

// Tabs content
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SavingsSummaryCard(),
          SizedBox(height: 16),
          GoalsListWidget(isPreview: true),
          SizedBox(height: 16),
          ExpenseTrackerWidget(isPreview: true),
        ],
      ),
    );
  }
}

class _GoalsTab extends StatelessWidget {
  const _GoalsTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: GoalsListWidget(),
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  const _ExpensesTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: ExpenseTrackerWidget(),
    );
  }
}

class _OptimizationTab extends StatelessWidget {
  const _OptimizationTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: OptimizationWidget(),
    );
  }
}
