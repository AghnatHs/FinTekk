import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/core/globals.dart';
import 'package:fl_finance_mngt/database/app_config.dart';
import 'package:fl_finance_mngt/database/app_config_provider.dart';
import 'package:fl_finance_mngt/database/database.dart';
import 'package:fl_finance_mngt/database/database_provider.dart';
import 'package:fl_finance_mngt/presentation/page/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // databaseFactory.deleteDatabase('${await getDatabasesPath()}_fintekk.db');
  Database database = await DatabaseHelper.initDb();
  DatabaseHelper databaseHelper = DatabaseHelper(database);

  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(databaseHelper),
      appConfigProvider.overrideWithValue(AppConfig(sharedPrefs, packageInfo)),
    ],
    child: const App(),
  ));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FinTekk',
      scaffoldMessengerKey: globalSnackbarKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorConst.defaultAppColor),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          backgroundColor: ColorConst.defaultAppColor,
          surfaceTintColor: ColorConst.defaultAppColor,
        ),
        textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 16), bodySmall: TextStyle(fontSize: 14)),
      ),
      home: const MainPage(),
    );
  }
}
