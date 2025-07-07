import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/savings_provider.dart';
import '../widgets/savings_summary_card.dart';
import '../widgets/simulations_widget.dart';
import '../widgets/optimization_widget.dart';
import '../widgets/expenses_tracker_widget.dart';
import '../widgets/goals_widget.dart';
import 'profile_setup_screen.dart';
import 'expense_input_screen.dart';
import '../widgets/enhanced_projections_widget.dart';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;

          if (isWideScreen) {
            return _buildWebLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const SizedBox.shrink();
          }

          return _buildBottomNavigation();
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () => _navigateToExpenseInput(),
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            tooltip: 'Agregar gastos',
            child: const Icon(Icons.add),
          );
        },
      ),
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

        if (provider.user == null) {
          return _buildWelcomeScreen();
        }

        return IndexedStack(
          index: _selectedIndex,
          children: const [
            _DashboardTab(),
            _ExpensesTab(),
            _GoalsTab(),
            _ProjectionsTab(),
            _SimulationsTab(),
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
              'Tu calculadora de ahorro inteligente para optimizar tus finanzas',
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
            Container(
              width: 250,
              color: const Color(0xFF2E7D32),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                  _buildNavItem(1, Icons.receipt_long, 'Gastos'),
                  _buildNavItem(2, Icons.flag, 'Metas'),
                  _buildNavItem(3, Icons.trending_up, 'Proyecciones'),
                  _buildNavItem(4, Icons.science, 'Simulaciones'),
                  _buildNavItem(5, Icons.analytics, 'Optimización'),
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
            Expanded(
              child: provider.user == null
                  ? _buildWelcomeScreen()
                  : IndexedStack(
                index: _selectedIndex,
                children: const [
                  _DashboardTab(),
                  _ExpensesTab(),
                  _GoalsTab(),
                  _ProjectionsTab(),
                  _SimulationsTab(),
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
          icon: Icon(Icons.receipt_long),
          label: 'Gastos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flag),
          label: 'Metas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Proyecciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.science),
          label: 'Simulaciones',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Optimización',
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
          EnhancedProjectionsWidget(isPreview: true),
        ],
      ),
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  const _ExpensesTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: ExpensesTrackerWidget(),
    );
  }
}

class _GoalsTab extends StatelessWidget {
  const _GoalsTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: GoalsWidget(),
    );
  }
}

class _ProjectionsTab extends StatelessWidget {
  const _ProjectionsTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: EnhancedProjectionsWidget(),
    );
  }
}

class _SimulationsTab extends StatelessWidget {
  const _SimulationsTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: SimulationsWidget(),
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
