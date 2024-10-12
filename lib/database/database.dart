import 'package:fl_finance_mngt/model/account_model.dart';
import 'package:fl_finance_mngt/model/internal_transfer_model.dart';
import 'package:fl_finance_mngt/model/transaction_category_model.dart';
import 'package:fl_finance_mngt/model/transaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

Map<int, String> dbMigrations = {
  1: '''
      CREATE TABLE TransactionCategory ( 
      transaction_category_id TEXT PRIMARY KEY, 
      name TEXT
      )
     ''',
  2: '''
      CREATE TABLE Account (
      account_id TEXT PRIMARY KEY, 
      name TEXT
      )
     ''',
  3: '''
      CREATE TABLE Transactionz (
      transaction_id TEXT PRIMARY KEY,
      transaction_category_id TEXT,
      account_id TEXT,
      date TEXT,
      amount INTEGER,
      description TEXT,
      type TEXT,  
      FOREIGN KEY (transaction_category_id) REFERENCES TransactionCategory (transaction_category_id) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (account_id) REFERENCES Account (account_id) ON DELETE CASCADE ON UPDATE CASCADE
      )
     ''',
  4: '''
      INSERT INTO TransactionCategory(transaction_category_id, name) 
      VALUES ("tsctgry-${const Uuid().v7()}", "Transfer")
     ''',
  5: '''
      INSERT INTO Account(account_id, name)
      VALUES("account-${const Uuid().v7()}", "Primary")
     ''',
  6: '''
      INSERT INTO Account(account_id, name)
      VALUES("account-${const Uuid().v7()}", "Savings")
     ''',
  7: '''
     ALTER TABLE TransactionCategory ADD color INTEGER
     ''',
  8: '''
     UPDATE TransactionCategory
     SET color = 4278190080
     ''',
  9: '''
      CREATE TABLE InternalTransfer(
      internal_transfer_id TEXT PRIMARY KEY,
      account_id TEXT NOT NULL,
      amount INT NOT NULL,
      type TEXT NOT NULL,
      date TEXT NOT NULL,
      FOREIGN KEY (account_id) REFERENCES Account (account_id) ON DELETE CASCADE ON UPDATE CASCADE
      )
     ''',
  // WRONG TABLE DEFINITION
  10: '''
      DROP TABLE IF EXISTS InternalTransfer
      ''',
  11: '''
      CREATE TABLE InternalTransfer(
      internal_transfer_id TEXT PRIMARY KEY,
      linked_transfer_id TEXT,
      account_id TEXT NOT NULL,
      amount INT NOT NULL,
      type TEXT NOT NULL,
      date TEXT NOT NULL,
      FOREIGN KEY (account_id) REFERENCES Account (account_id) ON DELETE CASCADE ON UPDATE CASCADE
      )
     ''',
};

class DatabaseHelper {
  Database database;
  DatabaseHelper(this.database);
  static Future<Database> initDb() async {
    int dbMigrationsLength = dbMigrations.length;
    String path = '${await getDatabasesPath()}_fintekk.db';

    Database database = await openDatabase(
      path,
      version: dbMigrationsLength,
      onCreate: (Database db, int version) async {
        for (int i = 1; i <= dbMigrationsLength; i++) {
          await db.execute(dbMigrations[i]!);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (int i = oldVersion + 1; i <= newVersion; i++) {
          await db.execute(dbMigrations[i]!);
        }
      },
    );

    return database;
  }

  // >-- TranscationCategory
  Future<List<Map>> getAllTransactionCategories() async {
    return await database.rawQuery('''
      SELECT * FROM TransactionCategory
    ''');
  }

  Future<int> addTransactionCategory(TranscactionCategory transactionCategory) async {
    return await database.rawInsert('''
       INSERT INTO TransactionCategory(transaction_category_id, name, color) 
       VALUES (?, ?, ?)
    ''', [transactionCategory.id, transactionCategory.name, transactionCategory.color]);
  }

  Future<int> updateTransactionCategory(String transactionCategoryId, String newName, int newColor) async {
    return await database.rawUpdate('''
      UPDATE TransactionCategory
      SET name = ?, color = ?
      WHERE transaction_category_id = ?
    ''', [newName, newColor, transactionCategoryId]);
  }

  // >-- Account
  Future<List<Map>> getAllAccounts() async {
    return await database.rawQuery('''
      SELECT * FROM Account
    ''');
  }

  Future<int> addAccount(Account account) async {
    return await database.rawInsert('''
      INSERT INTO Account(account_id, name)
      VALUES (?, ?)
    ''', [account.id, account.name]);
  }

  Future<int> updateAccount(String accountId, String newName) async {
    return await database.rawUpdate('''
      UPDATE Account
      SET name = ?
      WHERE account_id = ?
    ''', [newName, accountId]);
  }

  // >-- Transactionz
  Future<List<Map>> getAllTransactions() async {
    return await database.rawQuery('''
      SELECT
          transaction_id,
          Transactionz.transaction_category_id,
          Transactionz.account_id,
          date,
          amount,
          description,
          type,
          TransactionCategory.name AS category,
          TransactionCategory.color AS categoryColor,
          Account.name AS account
      FROM Transactionz
      INNER JOIN (TransactionCategory) ON
      Transactionz.transaction_category_id = TransactionCategory.transaction_category_id
      INNER JOIN(Account) ON
      Transactionz.account_id = Account.account_id
    ''');
  }

  Future<int> addTransaction(Transactionn transaction) async {
    return await database.rawInsert('''
    INSERT INTO Transactionz (transaction_id, transaction_category_id, account_id, date, amount, description, type)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', [
      transaction.id,
      transaction.transactionCategoryId,
      transaction.accountId,
      transaction.date,
      transaction.amount,
      transaction.description,
      transaction.type
    ]);
  }

  Future<int> updateTransaction(Transactionn transaction) async {
    return await database.rawUpdate('''
      UPDATE Transactionz
      SET transaction_category_id = ?, account_id = ?, date = ?, amount = ?, description = ?, type = ?
      WHERE transaction_id = ?
    ''', [
      transaction.transactionCategoryId,
      transaction.accountId,
      transaction.date,
      transaction.amount,
      transaction.description,
      transaction.type,
      transaction.id,
    ]);
  }

  Future<int> deleteTransaction(String transactionId) async {
    return await database.rawDelete('''
        DELETE FROM Transactionz WHERE transaction_id = ? 
    ''', [transactionId]);
  }

  //>-- Internal Transfer
  Future<List<Map>> getAllInternalTransfer() async {
    return await database.rawQuery('''
      SELECT
        internal_transfer_id,
        linked_transfer_id,
        InternalTransfer.account_id,
        amount,
        type,
        date,
        Account.name as account_name 
      FROM InternalTransfer
      INNER JOIN(Account) ON
      InternalTransfer.account_id = Account.account_id
    ''');
  }

  Future<int> addInternalTransfer(InternalTransfer internalTransfer) async {
    return await database.rawInsert('''
      INSERT INTO InternalTransfer(internal_transfer_id,linked_transfer_id,account_id, amount, type, date)
      VALUES (?,?,?,?,?,?)
    ''', [
      internalTransfer.id,
      internalTransfer.linkedTransferId,
      internalTransfer.accountId,
      internalTransfer.amount,
      internalTransfer.type,
      internalTransfer.date
    ]);
  }
  
  Future<int> deleteInternalTransfer(String linkedTransferId) async {
    return await database.rawDelete('''
      DELETE FROM InternalTransfer WHERE linked_transfer_id = ?
    ''', [linkedTransferId]);
  }
}
