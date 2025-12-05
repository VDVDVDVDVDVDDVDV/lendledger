import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:lendledger/models/loan.dart';
import 'package:lendledger/models/payment.dart';
import 'package:lendledger/models/audit_log.dart';
import 'package:lendledger/utils/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(DatabaseConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create Loans Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.loansTable} (
        ${DatabaseConstants.columnId} TEXT PRIMARY KEY,
        ${DatabaseConstants.columnBorrowerName} TEXT NOT NULL,
        ${DatabaseConstants.columnFundSource} TEXT NOT NULL,
        ${DatabaseConstants.columnTransactionMode} TEXT NOT NULL,
        ${DatabaseConstants.columnPrincipalAmount} REAL NOT NULL,
        ${DatabaseConstants.columnInterestRate} REAL NOT NULL,
        ${DatabaseConstants.columnFrequency} TEXT NOT NULL,
        ${DatabaseConstants.columnLoanStartDate} TEXT NOT NULL,
        ${DatabaseConstants.columnCostOfCapital} REAL,
        ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.columnUpdatedAt} TEXT NOT NULL
      )
    ''');

    // Create Payments Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.paymentsTable} (
        ${DatabaseConstants.columnId} TEXT PRIMARY KEY,
        ${DatabaseConstants.columnLoanId} TEXT NOT NULL,
        ${DatabaseConstants.columnAmountPaid} REAL NOT NULL,
        ${DatabaseConstants.columnPaymentDate} TEXT NOT NULL,
        ${DatabaseConstants.columnCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.columnLoanId}) 
          REFERENCES ${DatabaseConstants.loansTable} (${DatabaseConstants.columnId})
          ON DELETE CASCADE
      )
    ''');

    // Create Audit Logs Table
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.auditLogsTable} (
        ${DatabaseConstants.columnId} TEXT PRIMARY KEY,
        ${DatabaseConstants.columnActionType} TEXT NOT NULL,
        ${DatabaseConstants.columnRecordType} TEXT NOT NULL,
        ${DatabaseConstants.columnRecordId} TEXT NOT NULL,
        ${DatabaseConstants.columnDataSnapshot} TEXT NOT NULL,
        ${DatabaseConstants.columnTimestamp} TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_loans_borrower 
      ON ${DatabaseConstants.loansTable}(${DatabaseConstants.columnBorrowerName})
    ''');

    await db.execute('''
      CREATE INDEX idx_payments_loan 
      ON ${DatabaseConstants.paymentsTable}(${DatabaseConstants.columnLoanId})
    ''');
  }

  // ==================== LOAN OPERATIONS ====================

  Future<String> createLoan(Loan loan) async {
    final db = await database;
    await db.insert(DatabaseConstants.loansTable, loan.toMap());
    
    // Create audit log
    await _createAuditLog(
      actionType: 'CREATE',
      recordType: 'LOAN',
      recordId: loan.id,
      dataSnapshot: jsonEncode(loan.toMap()),
    );
    
    return loan.id;
  }

  Future<Loan?> getLoan(String id) async {
    final db = await database;
    final maps = await db.query(
      DatabaseConstants.loansTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Loan.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Loan>> getAllLoans() async {
    final db = await database;
    final maps = await db.query(
      DatabaseConstants.loansTable,
      orderBy: '${DatabaseConstants.columnLoanStartDate} DESC',
    );

    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  Future<List<Loan>> getLoansByFundSource(String fundSource) async {
    final db = await database;
    final maps = await db.query(
      DatabaseConstants.loansTable,
      where: '${DatabaseConstants.columnFundSource} = ?',
      whereArgs: [fundSource],
    );

    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  Future<List<Loan>> getLoansByTransactionMode(String transactionMode) async {
    final db = await database;
    final maps = await db.query(
      DatabaseConstants.loansTable,
      where: '${DatabaseConstants.columnTransactionMode} = ?',
      whereArgs: [transactionMode],
    );

    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  Future<int> updateLoan(Loan loan) async {
    final db = await database;
    
    // Create audit log before update
    await _createAuditLog(
      actionType: 'UPDATE',
      recordType: 'LOAN',
      recordId: loan.id,
      dataSnapshot: jsonEncode(loan.toMap()),
    );
    
    return await db.update(
      DatabaseConstants.loansTable,
      loan.toMap(),
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [loan.id],
    );
  }

  Future<int> deleteLoan(String id) async {
    final db = await database;
    
    // Get loan data before deletion for audit log
    final loan = await getLoan(id);
    if (loan != null) {
      await _createAuditLog(
        actionType: 'DELETE',
        recordType: 'LOAN',
        recordId: id,
        dataSnapshot: jsonEncode(loan.toMap()),
      );
    }
    
    return await db.delete(
      DatabaseConstants.loansTable,
      where: '${DatabaseConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  // ==================== PAYMENT OPERATIONS ====================

  Future<String> createPayment(Payment payment) async {
    final db = await database;
    await db.insert(DatabaseConstants.paymentsTable, payment.toMap());
    
    // Create audit log
    await _createAuditLog(
      actionType: 'CREATE',
      recordType: 'PAYMENT',
      recordId: payment.id,
      dataSnapshot: jsonEncode(payment.toMap()),
    );
    
    return payment.id;
  }

  Future<List<Payment>> getPaymentsByLoan(String loanId) async {
    final db = await database;
    final maps = await db.query(
      DatabaseConstants.paymentsTable,
      where: '${DatabaseConstants.columnLoanId} = ?',
      whereArgs: [loanId],
      orderBy: '${DatabaseConstants.columnPaymentDate} DESC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  Future<double> getTotalPaidForLoan(String loanId) async {
    final payments = await getPaymentsByLoan(loanId);
    return payments.fold(0.0, (sum, payment) => sum + payment.amountPaid);
  }

  // ==================== AUDIT LOG OPERATIONS ====================

  Future<void> _createAuditLog({
    required String actionType,
    required String recordType,
    required String recordId,
    required String dataSnapshot,
  }) async {
    final db = await database;
    final auditLog = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      actionType: actionType,
      recordType: recordType,
      recordId: recordId,
      dataSnapshot: dataSnapshot,
      timestamp: DateTime.now(),
    );

    await db.insert(DatabaseConstants.auditLogsTable, auditLog.toMap());
  }

  Future<List<AuditLog>> getAuditLogs({int limit = 100}) async {
    final db = await database;
    final maps = await db.query(
      DatabaseConstants.auditLogsTable,
      orderBy: '${DatabaseConstants.columnTimestamp} DESC',
      limit: limit,
    );

    return maps.map((map) => AuditLog.fromMap(map)).toList();
  }

  // ==================== STATISTICS ====================

  Future<double> getTotalOutstandingPrincipal() async {
    final loans = await getAllLoans();
    return loans.fold(0.0, (sum, loan) => sum + loan.principalAmount);
  }

  Future<Map<String, double>> getCapitalSplit() async {
    final loans = await getAllLoans();
    double selfFunded = 0.0;
    double borrowed = 0.0;

    for (var loan in loans) {
      if (loan.fundSource == AppStrings.selfFunded) {
        selfFunded += loan.principalAmount;
      } else {
        borrowed += loan.principalAmount;
      }
    }

    return {
      'selfFunded': selfFunded,
      'borrowed': borrowed,
    };
  }

  // ==================== DATABASE MANAGEMENT ====================

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}