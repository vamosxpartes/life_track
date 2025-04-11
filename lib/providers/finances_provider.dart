import 'package:flutter/foundation.dart';
import 'package:life_track/models/models.dart';
import 'package:life_track/models/transaction.dart' as app_models;
import 'package:life_track/services/database_service.dart';
import 'package:intl/intl.dart';

class FinancesProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<FinancialAccount> _accounts = [];
  List<app_models.Transaction> _transactions = [];
  List<SavingGoal> _savingGoals = [];
  List<Loan> _loans = [];
  List<RecurringExpense> _recurringExpenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FinancialAccount> get accounts => _accounts;
  List<app_models.Transaction> get transactions => _transactions;
  List<SavingGoal> get savingGoals => _savingGoals;
  List<Loan> get loans => _loans;
  List<Loan> get activeLoans => _loans.where((loan) => loan.status == LoanStatus.active).toList();
  List<RecurringExpense> get recurringExpenses => _recurringExpenses;
  List<RecurringExpense> get activeRecurringExpenses => 
      _recurringExpenses.where((expense) => expense.isActive).toList();
  List<RecurringExpense> get dueRecurringExpenses => 
      _recurringExpenses.where((expense) => expense.isActive && expense.isDue()).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalBalance {
    return _accounts.fold(0, (sum, account) => sum + account.balance);
  }

  Future<void> loadAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _accounts = await _databaseService.getFinancialAccounts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar las cuentas: $e';
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _databaseService.getAllTransactions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar las transacciones: $e';
      notifyListeners();
    }
  }

  Future<void> loadSavingGoals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _savingGoals = await _databaseService.getSavingGoals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar las metas de ahorro: $e';
      notifyListeners();
    }
  }

  Future<void> loadLoans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loans = await _databaseService.getLoans();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar los préstamos: $e';
      notifyListeners();
    }
  }

  Future<void> loadRecurringExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recurringExpenses = await _databaseService.getRecurringExpenses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar los gastos recurrentes: $e';
      notifyListeners();
    }
  }

  Future<void> addAccount(FinancialAccount account) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (account.institutionName != null) {
      }
      
      await _databaseService.insertFinancialAccount(account);
      await loadAccounts();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al añadir la cuenta: $e';
      notifyListeners();
    }
  }

  Future<void> updateAccount(FinancialAccount account) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.updateFinancialAccount(account);
      await loadAccounts();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar la cuenta: $e';
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.deleteFinancialAccount(id);
      await loadAccounts();
      await loadTransactions();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar la cuenta: $e';
      notifyListeners();
    }
  }

  Future<void> addTransaction(app_models.Transaction transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Actualizar saldo de cuenta
      final sourceAccount = _accounts.firstWhere((a) => a.id == transaction.accountId);
      double newBalance = sourceAccount.balance;
      
      if (transaction.type == app_models.TransactionType.expense) {
        newBalance -= transaction.amount;
      } else if (transaction.type == app_models.TransactionType.income) {
        newBalance += transaction.amount;
      } else if (transaction.type == app_models.TransactionType.transfer && 
                transaction.destinationAccountId != null) {
        newBalance -= transaction.amount;
        
        // Actualizar cuenta destino
        final destAccount = _accounts.firstWhere(
          (a) => a.id == transaction.destinationAccountId);
        final updatedDestAccount = destAccount.copyWith(
          balance: destAccount.balance + transaction.amount
        );
        await _databaseService.updateFinancialAccount(updatedDestAccount);
      }
      
      // Actualizar cuenta origen
      final updatedSourceAccount = sourceAccount.copyWith(balance: newBalance);
      await _databaseService.updateFinancialAccount(updatedSourceAccount);
      
      // Guardar transacción
      await _databaseService.insertTransaction(transaction);
      
      await loadAccounts();
      await loadTransactions();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al añadir la transacción: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Primero necesitamos encontrar la transacción para revertir su efecto
      final transaction = _transactions.firstWhere((t) => t.id == id);
      
      // Revertir cambios en el saldo de la cuenta
      final sourceAccount = _accounts.firstWhere((a) => a.id == transaction.accountId);
      double newBalance = sourceAccount.balance;
      
      if (transaction.type == app_models.TransactionType.expense) {
        newBalance += transaction.amount;
      } else if (transaction.type == app_models.TransactionType.income) {
        newBalance -= transaction.amount;
      } else if (transaction.type == app_models.TransactionType.transfer && 
                transaction.destinationAccountId != null) {
        newBalance += transaction.amount;
        
        // Revertir cambios en la cuenta destino
        final destAccount = _accounts.firstWhere(
          (a) => a.id == transaction.destinationAccountId);
        final updatedDestAccount = destAccount.copyWith(
          balance: destAccount.balance - transaction.amount
        );
        await _databaseService.updateFinancialAccount(updatedDestAccount);
      }
      
      // Actualizar cuenta origen
      final updatedSourceAccount = sourceAccount.copyWith(balance: newBalance);
      await _databaseService.updateFinancialAccount(updatedSourceAccount);
      
      // Eliminar transacción
      await _databaseService.deleteTransaction(id);
      
      await loadAccounts();
      await loadTransactions();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar la transacción: $e';
      notifyListeners();
    }
  }

  Future<void> addSavingGoal(SavingGoal goal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.insertSavingGoal(goal);
      await loadSavingGoals();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al añadir la meta de ahorro: $e';
      notifyListeners();
    }
  }

  Future<void> updateSavingGoal(SavingGoal goal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.updateSavingGoal(goal);
      await loadSavingGoals();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar la meta de ahorro: $e';
      notifyListeners();
    }
  }

  Future<void> deleteSavingGoal(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.deleteSavingGoal(id);
      await loadSavingGoals();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar la meta de ahorro: $e';
      notifyListeners();
    }
  }

  Future<void> addToSavingGoal(SavingGoal goal, double amount, String accountId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Crear transacción
      final transaction = app_models.Transaction(
        accountId: accountId,
        date: DateTime.now(),
        amount: amount,
        type: app_models.TransactionType.expense,
        category: 'Ahorro',
        subcategory: goal.name,
        description: 'Aporte a meta de ahorro: ${goal.name}',
      );
      
      await addTransaction(transaction);
      
      // Actualizar la meta
      final updatedGoal = goal.copyWith(
        currentAmount: goal.currentAmount + amount
      );
      await updateSavingGoal(updatedGoal);
      
      await loadAccounts();
      await loadTransactions();
      await loadSavingGoals();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al añadir a la meta de ahorro: $e';
      notifyListeners();
    }
  }

  List<app_models.Transaction> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _transactions.where((transaction) {
      return !transaction.date.isBefore(startDate) && 
             !transaction.date.isAfter(endDate);
    }).toList();
  }

  Map<String, double> getExpensesByCategory({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final expenses = _transactions.where((t) => 
        t.type == app_models.TransactionType.expense &&
        !t.date.isBefore(startDate) && 
        !t.date.isAfter(endDate)
    ).toList();
    
    final Map<String, double> categoryTotals = {};
    
    for (var expense in expenses) {
      if (categoryTotals.containsKey(expense.category)) {
        categoryTotals[expense.category] = categoryTotals[expense.category]! + expense.amount;
      } else {
        categoryTotals[expense.category] = expense.amount;
      }
    }
    
    return categoryTotals;
  }

  List<MapEntry<String, double>> getIncomeByMonth(int year) {
    final Map<String, double> monthlyIncome = {};
    
    // Inicializar meses
    for (int i = 1; i <= 12; i++) {
      final month = DateFormat('MMM').format(DateTime(year, i));
      monthlyIncome[month] = 0;
    }
    
    for (var transaction in _transactions) {
      if (transaction.type == app_models.TransactionType.income && 
          transaction.date.year == year) {
        final month = DateFormat('MMM').format(transaction.date);
        monthlyIncome[month] = (monthlyIncome[month] ?? 0) + transaction.amount;
      }
    }
    
    return monthlyIncome.entries.toList();
  }

  Future<void> addLoan(Loan loan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Si el préstamo está asociado a una cuenta, actualizamos su saldo
      if (loan.accountId != null) {
        final account = _accounts.firstWhere((a) => a.id == loan.accountId);
        double newBalance = account.balance;
        
        // Si es un préstamo que damos, disminuimos el saldo de la cuenta
        if (loan.type == LoanType.given) {
          newBalance -= loan.totalAmount;
        } 
        // Si es un préstamo que recibimos, aumentamos el saldo de la cuenta
        else if (loan.type == LoanType.received) {
          newBalance += loan.totalAmount;
        }
        
        // Actualizar cuenta
        final updatedAccount = account.copyWith(balance: newBalance);
        await _databaseService.updateFinancialAccount(updatedAccount);
      }
      
      // Guardar préstamo
      await _databaseService.insertLoan(loan);
      
      await loadAccounts();
      await loadLoans();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al añadir el préstamo: $e';
      notifyListeners();
    }
  }

  Future<void> updateLoan(Loan loan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.updateLoan(loan);
      await loadLoans();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar el préstamo: $e';
      notifyListeners();
    }
  }

  Future<void> deleteLoan(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Obtener el préstamo antes de borrarlo para poder revertir los cambios en la cuenta
      final loan = _loans.firstWhere((l) => l.id == id);
      
      // Si el préstamo está asociado a una cuenta, revertimos su efecto en el saldo
      if (loan.accountId != null) {
        final account = _accounts.firstWhere((a) => a.id == loan.accountId);
        double newBalance = account.balance;
        
        // Revertir efecto: si era un préstamo dado, devolvemos el dinero a la cuenta
        if (loan.type == LoanType.given) {
          newBalance += loan.remainingAmount; // Solo devolvemos lo que queda por pagar
        } 
        // Revertir efecto: si era un préstamo recibido, quitamos el dinero de la cuenta
        else if (loan.type == LoanType.received) {
          newBalance -= loan.remainingAmount; // Solo quitamos lo que queda por pagar
        }
        
        // Actualizar cuenta
        final updatedAccount = account.copyWith(balance: newBalance);
        await _databaseService.updateFinancialAccount(updatedAccount);
      }

      await _databaseService.deleteLoan(id);
      await loadAccounts();
      await loadLoans();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar el préstamo: $e';
      notifyListeners();
    }
  }

  // Registrar un pago de un préstamo
  Future<void> recordLoanPayment(String loanId, double amount, DateTime date, {String? description}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Obtener el préstamo
      final loan = _loans.firstWhere((l) => l.id == loanId);
      
      // Verificar que el monto no exceda lo que queda por pagar
      if (amount > loan.remainingAmount) {
        throw Exception('El monto del pago excede la cantidad restante del préstamo');
      }
      
      // Calcular el monto restante
      final newRemainingAmount = loan.remainingAmount - amount;
      
      // Determinar el estado del préstamo después del pago
      final newStatus = newRemainingAmount <= 0 ? LoanStatus.completed : loan.status;
      
      // Actualizar el préstamo
      final updatedLoan = loan.copyWith(
        remainingAmount: newRemainingAmount,
        status: newStatus,
      );
      
      // Si el préstamo está asociado a una cuenta, registramos el pago como una transacción
      if (loan.accountId != null) {
        final accountId = loan.accountId!;
        
        // Crear transacción según tipo de préstamo
        final transactionType = loan.type == LoanType.given 
            ? app_models.TransactionType.income 
            : app_models.TransactionType.expense;
            
        final transaction = app_models.Transaction(
          accountId: accountId,
          date: date,
          amount: amount,
          type: transactionType,
          category: 'Préstamo',
          subcategory: loan.type == LoanType.given ? 'Pago recibido' : 'Pago realizado',
          description: description ?? 'Pago de préstamo: ${loan.name}',
          tags: ['préstamo', loan.type.name],
        );
        
        await addTransaction(transaction);
      }
      
      // Guardar préstamo actualizado
      await _databaseService.updateLoan(updatedLoan);
      await loadLoans();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al registrar el pago del préstamo: $e';
      notifyListeners();
    }
  }

  Future<void> addRecurringExpense(RecurringExpense expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.insertRecurringExpense(expense);
      await loadRecurringExpenses();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al añadir el gasto recurrente: $e';
      notifyListeners();
    }
  }

  Future<void> updateRecurringExpense(RecurringExpense expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.updateRecurringExpense(expense);
      await loadRecurringExpenses();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar el gasto recurrente: $e';
      notifyListeners();
    }
  }

  Future<void> deleteRecurringExpense(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _databaseService.deleteRecurringExpense(id);
      await loadRecurringExpenses();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar el gasto recurrente: $e';
      notifyListeners();
    }
  }

  Future<void> processRecurringExpense(RecurringExpense expense, {String? note}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Verificar que haya una cuenta asociada
      if (expense.accountId == null) {
        throw Exception('Este gasto no tiene una cuenta asociada');
      }
      
      // Obtener la fecha actual
      final now = DateTime.now();
      
      // Crear la transacción
      final transaction = app_models.Transaction(
        accountId: expense.accountId!,
        date: now,
        amount: expense.amount,
        type: app_models.TransactionType.expense,
        category: expense.category,
        subcategory: expense.subcategory,
        description: note ?? 'Pago de ${expense.name}',
        tags: ['recurrente', expense.frequency.toString().split('.').last],
      );
      
      // Registrar la transacción (esto ya actualiza el saldo de la cuenta)
      await addTransaction(transaction);
      
      // Determinar si estamos pagando un gasto vencido o actual
      final bool isOverdue = expense.nextDueDate.isBefore(now.subtract(const Duration(days: 1)));
      
      // Calcular la siguiente fecha de pago
      DateTime nextDate;
      
      // Si el pago está vencido y corresponde al período actual, mantenemos la siguiente fecha programada
      // Si no, calculamos la próxima fecha basada en la fecha actual
      if (isOverdue) {
        // Primero actualizamos a la fecha que estaba vencida
        nextDate = expense.getNextDueDate();
        
        // Verificamos si la nueva fecha todavía está en el pasado (puede ocurrir si han pasado varios periodos)
        // Si es así, seguimos avanzando hasta llegar a una fecha futura
        while (nextDate.isBefore(now)) {
          switch (expense.frequency) {
            case RecurrenceFrequency.daily:
              nextDate = nextDate.add(const Duration(days: 1));
              break;
            case RecurrenceFrequency.weekly:
              nextDate = nextDate.add(const Duration(days: 7));
              break;
            case RecurrenceFrequency.biweekly:
              nextDate = nextDate.add(const Duration(days: 14));
              break;
            case RecurrenceFrequency.monthly:
              final month = nextDate.month < 12 ? nextDate.month + 1 : 1;
              final year = nextDate.month < 12 ? nextDate.year : nextDate.year + 1;
              final day = nextDate.day;
              final daysInMonth = DateTime(year, month + 1, 0).day;
              final adjustedDay = day > daysInMonth ? daysInMonth : day;
              nextDate = DateTime(year, month, adjustedDay);
              break;
            case RecurrenceFrequency.quarterly:
              final month = (nextDate.month + 3 - 1) % 12 + 1;
              final year = nextDate.month > 9 ? nextDate.year + 1 : nextDate.year;
              final day = nextDate.day;
              final daysInMonth = DateTime(year, month + 1, 0).day;
              final adjustedDay = day > daysInMonth ? daysInMonth : day;
              nextDate = DateTime(year, month, adjustedDay);
              break;
            case RecurrenceFrequency.yearly:
              nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
              break;
            case RecurrenceFrequency.custom:
              if (expense.customDays != null) {
                nextDate = nextDate.add(Duration(days: expense.customDays!));
              }
              break;
          }
        }
      } else {
        // Si no está vencido, simplemente obtenemos la próxima fecha según la frecuencia
        nextDate = expense.getNextDueDate();
      }
      
      // Actualizar el gasto recurrente con la nueva fecha
      final updatedExpense = expense.copyWith(
        nextDueDate: nextDate,
      );
      
      await updateRecurringExpense(updatedExpense);
      
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al procesar el gasto recurrente: $e';
      notifyListeners();
    }
  }

  Future<void> skipRecurringExpense(RecurringExpense expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Calcular la siguiente fecha de pago
      final nextDate = expense.getNextDueDate();
      
      // Actualizar el gasto recurrente con la nueva fecha
      final updatedExpense = expense.copyWith(
        nextDueDate: nextDate,
      );
      
      await updateRecurringExpense(updatedExpense);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al omitir el gasto recurrente: $e';
      notifyListeners();
    }
  }
} 