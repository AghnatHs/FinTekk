import 'dart:io';
import 'package:fl_finance_mngt/service/permission_services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<void> exportDatabaseToDownloads() async {
  try {
    // Request permissions first
    bool hasPermission = await PermissionService.requestAllStoragePermissions();
    if (!hasPermission) {
      debugPrint('Storage permission not granted');
      return;
    }

    // Get database path
    final dbPath = await getDatabasesPath();
    final dbFile = File('${dbPath}_fintekk.db'); 
    debugPrint('Database file path: $dbFile');
    
    if (!await dbFile.exists()) {
      debugPrint('Database file not found');
      return;
    }

    // Get Downloads directory
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getDownloadsDirectory();
    }

    if (downloadsDir == null) {
      debugPrint('Downloads directory not found');
      return;
    }

    // Copy database to Downloads
    final destinationFile = File('${downloadsDir.path}/fintek_db_backup.db');
    await dbFile.copy(destinationFile.path);
    
    debugPrint('Database exported to: ${destinationFile.path}');
  } catch (e) {
    debugPrint('Error exporting database: $e');
  }
}