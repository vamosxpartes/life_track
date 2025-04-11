import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:life_track/models/models.dart' hide Transaction;
import 'package:life_track/models/transaction.dart' as app_models;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'life_track.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Tabla de Diario
    await db.execute('''
      CREATE TABLE diary_entries (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT,
        imagePaths TEXT,
        location TEXT,
        attachments TEXT
      )
    ''');

    // Tabla de Hábitos
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        frequency TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT,
        goal INTEGER NOT NULL,
        completionDates TEXT,
        reminderTime TEXT,
        isActive INTEGER NOT NULL
      )
    ''');

    // Tabla de Contactos
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        photoPath TEXT,
        phoneNumber TEXT,
        email TEXT,
        birthdate TEXT,
        occupation TEXT,
        meetingPlaces TEXT,
        interestLevel INTEGER NOT NULL,
        notes TEXT,
        tags TEXT,
        createdAt TEXT NOT NULL,
        lastInteraction TEXT,
        height TEXT,
        bodyType TEXT,
        eyeColor TEXT,
        hairColor TEXT,
        buttocksSize TEXT,
        breastsSize TEXT,
        waistSize TEXT,
        personalityTraits TEXT,
        relationshipStatus TEXT,
        isArchived INTEGER DEFAULT 0
      )
    ''');

    // Tabla de Interacciones
    await db.execute('''
      CREATE TABLE interactions (
        id TEXT PRIMARY KEY,
        contactId TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        location TEXT,
        notes TEXT NOT NULL,
        topics TEXT,
        relationshipProgress INTEGER NOT NULL,
        imagePaths TEXT,
        FOREIGN KEY (contactId) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de Cuentas Financieras
    await db.execute('''
      CREATE TABLE financial_accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        institutionName TEXT,
        balance REAL NOT NULL,
        accountNumber TEXT,
        notes TEXT,
        color TEXT,
        isActive INTEGER NOT NULL
      )
    ''');

    // Tabla de Transacciones
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        accountId TEXT NOT NULL,
        destinationAccountId TEXT,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        subcategory TEXT,
        description TEXT,
        tags TEXT,
        imagePath TEXT,
        isRecurring INTEGER NOT NULL,
        FOREIGN KEY (accountId) REFERENCES financial_accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (destinationAccountId) REFERENCES financial_accounts (id) ON DELETE SET NULL
      )
    ''');

    // Tabla de Metas de Ahorro
    await db.execute('''
      CREATE TABLE saving_goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL,
        startDate TEXT NOT NULL,
        targetDate TEXT,
        accountId TEXT,
        category TEXT,
        iconName TEXT,
        color TEXT,
        isActive INTEGER NOT NULL,
        FOREIGN KEY (accountId) REFERENCES financial_accounts (id) ON DELETE SET NULL
      )
    ''');
    
    // Tabla de Préstamos
    await db.execute('''
      CREATE TABLE loans (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        personName TEXT,
        type TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        remainingAmount REAL NOT NULL,
        interestRate REAL,
        startDate TEXT NOT NULL,
        dueDate TEXT,
        description TEXT,
        tags TEXT,
        accountId TEXT,
        status TEXT NOT NULL,
        imagePath TEXT,
        FOREIGN KEY (accountId) REFERENCES financial_accounts (id) ON DELETE SET NULL
      )
    ''');

    // Tabla de Gastos Recurrentes
    await db.execute('''
      CREATE TABLE recurring_expenses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        accountId TEXT,
        category TEXT NOT NULL,
        subcategory TEXT,
        frequency INTEGER NOT NULL,
        customDays INTEGER,
        nextDueDate TEXT NOT NULL,
        reminderDays INTEGER NOT NULL,
        isActive INTEGER NOT NULL,
        iconName TEXT,
        color TEXT,
        FOREIGN KEY (accountId) REFERENCES financial_accounts (id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migración de la versión 1 a la 2 para la tabla contacts
      await db.execute('ALTER TABLE contacts RENAME COLUMN meetingPlace TO meetingPlaces');
      await db.execute('ALTER TABLE contacts ADD COLUMN height TEXT');
      await db.execute('ALTER TABLE contacts ADD COLUMN bodyType TEXT');
      await db.execute('ALTER TABLE contacts ADD COLUMN eyeColor TEXT');
      await db.execute('ALTER TABLE contacts ADD COLUMN hairColor TEXT');
      await db.execute('ALTER TABLE contacts ADD COLUMN buttocksSize TEXT');
      await db.execute('ALTER TABLE contacts ADD COLUMN breastsSize TEXT');
      await db.execute('ALTER TABLE contacts ADD COLUMN waistSize TEXT');
      await db.execute('ALTER TABLE contacts ADD COLUMN personalityTraits TEXT');
      await db.execute('ALTER TABLE contacts ADD COLUMN relationshipStatus TEXT');
    }
    
    if (oldVersion < 3) {
      // Migración para añadir la tabla de gastos recurrentes
      await db.execute('''
        CREATE TABLE recurring_expenses (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          amount REAL NOT NULL,
          accountId TEXT,
          category TEXT NOT NULL,
          subcategory TEXT,
          frequency INTEGER NOT NULL,
          customDays INTEGER,
          nextDueDate TEXT NOT NULL,
          reminderDays INTEGER NOT NULL,
          isActive INTEGER NOT NULL,
          iconName TEXT,
          color TEXT,
          FOREIGN KEY (accountId) REFERENCES financial_accounts (id) ON DELETE SET NULL
        )
      ''');
    }
    
    if (oldVersion < 4) {
      // Migración para añadir la columna isArchived a la tabla contacts
      await db.execute('ALTER TABLE contacts ADD COLUMN isArchived INTEGER DEFAULT 0');
    }
  }

  // Métodos para Diario
  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert(
      'diary_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DiaryEntry>> getDiaryEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('diary_entries', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => DiaryEntry.fromMap(maps[i]));
  }

  Future<DiaryEntry?> getDiaryEntryById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return DiaryEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteDiaryEntry(String id) async {
    final db = await database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para Hábitos
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  Future<Habit?> getHabitById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(String id) async {
    final db = await database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para Contactos
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<Contact?> getContactById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(String id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para Interacciones
  Future<int> insertInteraction(Interaction interaction) async {
    final db = await database;
    return await db.insert(
      'interactions',
      interaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Interaction>> getInteractionsByContactId(String contactId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'interactions',
      where: 'contactId = ?',
      whereArgs: [contactId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Interaction.fromMap(maps[i]));
  }

  Future<int> updateInteraction(Interaction interaction) async {
    final db = await database;
    return await db.update(
      'interactions',
      interaction.toMap(),
      where: 'id = ?',
      whereArgs: [interaction.id],
    );
  }

  Future<int> deleteInteraction(String id) async {
    final db = await database;
    return await db.delete(
      'interactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para Cuentas Financieras
  Future<int> insertFinancialAccount(FinancialAccount account) async {
    final db = await database;
    return await db.insert(
      'financial_accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FinancialAccount>> getFinancialAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('financial_accounts', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => FinancialAccount.fromMap(maps[i]));
  }

  Future<FinancialAccount?> getFinancialAccountById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return FinancialAccount.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateFinancialAccount(FinancialAccount account) async {
    final db = await database;
    return await db.update(
      'financial_accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteFinancialAccount(String id) async {
    final db = await database;
    return await db.delete(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para Transacciones
  Future<int> insertTransaction(app_models.Transaction transaction) async {
    final db = await database;
    return await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<app_models.Transaction>> getTransactionsByAccountId(String accountId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => app_models.Transaction.fromMap(maps[i]));
  }

  Future<List<app_models.Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => app_models.Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(app_models.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para Metas de Ahorro
  Future<int> insertSavingGoal(SavingGoal goal) async {
    final db = await database;
    return await db.insert(
      'saving_goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SavingGoal>> getSavingGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('saving_goals', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => SavingGoal.fromMap(maps[i]));
  }

  Future<SavingGoal?> getSavingGoalById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saving_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SavingGoal.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSavingGoal(SavingGoal goal) async {
    final db = await database;
    return await db.update(
      'saving_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteSavingGoal(String id) async {
    final db = await database;
    return await db.delete(
      'saving_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para Préstamos
  Future<int> insertLoan(Loan loan) async {
    final db = await database;
    return await db.insert(
      'loans',
      loan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Loan>> getLoans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('loans', orderBy: 'startDate DESC');
    return List.generate(maps.length, (i) => Loan.fromMap(maps[i]));
  }

  Future<List<Loan>> getActiveLoans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'loans',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'startDate DESC',
    );
    return List.generate(maps.length, (i) => Loan.fromMap(maps[i]));
  }

  Future<Loan?> getLoanById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'loans',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Loan.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateLoan(Loan loan) async {
    final db = await database;
    return await db.update(
      'loans',
      loan.toMap(),
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

  Future<int> deleteLoan(String id) async {
    final db = await database;
    return await db.delete(
      'loans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para Gastos Recurrentes
  Future<List<RecurringExpense>> getRecurringExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recurring_expenses');
    return List.generate(maps.length, (i) {
      return RecurringExpense.fromMap(maps[i]);
    });
  }

  Future<String> insertRecurringExpense(RecurringExpense expense) async {
    final db = await database;
    await db.insert(
      'recurring_expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return expense.id;
  }

  Future<int> updateRecurringExpense(RecurringExpense expense) async {
    final db = await database;
    return await db.update(
      'recurring_expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteRecurringExpense(String id) async {
    final db = await database;
    return await db.delete(
      'recurring_expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 