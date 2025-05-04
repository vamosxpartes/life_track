import 'package:flutter/material.dart';
import 'package:life_track/screens/diary/diary_screen.dart';
import 'package:life_track/screens/habits/habits_screen.dart';
import 'package:life_track/screens/contacts/contacts_screen.dart';
import 'package:life_track/screens/finances/finances_screen.dart';
import 'package:life_track/screens/analytics/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:life_track/providers/providers.dart';

// Importar los colores de la app
import 'package:life_track/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const DiaryScreen(),
    const HabitsScreen(),
    const ContactsScreen(),
    const FinancesScreen(),
    const DashboardScreen(),
  ];

  // Lista de colores para cada sección
  final List<Color> _sectionColors = [
    AppColors.diaryPrimary,
    AppColors.habitsPrimary,
    AppColors.relationsPrimary,
    AppColors.financesPrimary,
    AppColors.analyticsPrimary,
  ];

  @override
  void initState() {
    super.initState();
    _initProviders();
  }

  Future<void> _initProviders() async {
    // Inicializar datos de providers
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<DiaryProvider>(context, listen: false).loadEntries();
      // ignore: use_build_context_synchronously
      await Provider.of<HabitProvider>(context, listen: false).loadHabits();
      // ignore: use_build_context_synchronously
      await Provider.of<ContactProvider>(context, listen: false).loadContacts();
      // ignore: use_build_context_synchronously
      await Provider.of<FinancesProvider>(context, listen: false).loadAccounts();
      // ignore: use_build_context_synchronously
      await Provider.of<FinancesProvider>(context, listen: false).loadTransactions();
      // ignore: use_build_context_synchronously
      await Provider.of<FinancesProvider>(context, listen: false).loadSavingGoals();
      // ignore: use_build_context_synchronously
      await Provider.of<FinancesProvider>(context, listen: false).loadRecurringExpenses();
      // ignore: use_build_context_synchronously
      await Provider.of<AnalyticsProvider>(context, listen: false).loadMetrics();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el color actual para la sección seleccionada
    final Color currentColor = _sectionColors[_currentIndex];
    
    return Theme(
      // Anular el tema con el color de la sección actual
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: currentColor,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: currentColor.withAlpha(100),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: currentColor,
          foregroundColor: Colors.black,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: currentColor,
        ),
      ),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: AppColors.surface,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.book_outlined, color: _currentIndex == 0 ? currentColor : Colors.grey),
              selectedIcon: Icon(Icons.book, color: currentColor),
              label: 'Diario',
            ),
            NavigationDestination(
              icon: Icon(Icons.repeat_outlined, color: _currentIndex == 1 ? currentColor : Colors.grey),
              selectedIcon: Icon(Icons.repeat, color: currentColor),
              label: 'Hábitos',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline, color: _currentIndex == 2 ? currentColor : Colors.grey),
              selectedIcon: Icon(Icons.favorite, color: currentColor),
              label: 'Relaciones',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_outlined, color: _currentIndex == 3 ? currentColor : Colors.grey),
              selectedIcon: Icon(Icons.account_balance, color: currentColor),
              label: 'Finanzas',
            ),
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: _currentIndex == 4 ? currentColor : Colors.grey),
              selectedIcon: Icon(Icons.dashboard, color: currentColor),
              label: 'Dashboard',
            ),
          ],
        ),
      ),
    );
  }
} 