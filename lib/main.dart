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
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorConst.primaryGreen,
          brightness: Brightness.light,
          primary: ColorConst.primaryGreen,
          secondary: ColorConst.accentBlue,
          tertiary: ColorConst.accentOrange,
          surface: ColorConst.surfaceLight,
        ),
        useMaterial3: true,

        appBarTheme: AppBarTheme(
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: ColorConst.textOnPrimary,
            letterSpacing: 0.5,
          ),
          backgroundColor: ColorConst.primaryGreen,
          foregroundColor: ColorConst.textOnPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: UIConst.elevationMedium,
          shadowColor: ColorConst.primaryGreenDark.withValues(alpha: 0.3),
          centerTitle: true,
        ),

        cardTheme: CardThemeData(
          elevation: UIConst.elevationLow,
          shadowColor: ColorConst.neutralGray.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConst.radiusM),
          ),
          color: ColorConst.cardBackground,
          margin: const EdgeInsets.symmetric(
            horizontal: UIConst.spacingS,
            vertical: UIConst.spacingXS,
          ),
        ),

        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(
            horizontal: UIConst.spacingM,
            vertical: UIConst.spacingS,
          ),
          visualDensity: VisualDensity.comfortable,
        ),

        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: ColorConst.textPrimary,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: ColorConst.textPrimary,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: ColorConst.textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: ColorConst.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ColorConst.textPrimary,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ColorConst.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: ColorConst.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: ColorConst.textPrimary,
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorConst.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ColorConst.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ColorConst.textPrimary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: ColorConst.textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ColorConst.textPrimary,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ColorConst.textSecondary,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ColorConst.textSecondary,
          ),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: ColorConst.primaryGreen,
          foregroundColor: ColorConst.textOnPrimary,
          elevation: UIConst.elevationMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConst.radiusM),
          ),
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: ColorConst.cardBackground,
          elevation: UIConst.elevationMedium,
          shadowColor: ColorConst.neutralGray.withValues(alpha: 0.2),
          indicatorColor: ColorConst.primaryGreen.withValues(alpha: 0.1),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorConst.primaryGreen,
              );
            }
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorConst.textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: ColorConst.primaryGreen,
                size: 24,
              );
            }
            return const IconThemeData(
              color: ColorConst.textSecondary,
              size: 24,
            );
          }),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorConst.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConst.radiusM),
            borderSide: const BorderSide(color: ColorConst.neutralGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConst.radiusM),
            borderSide: BorderSide(color: ColorConst.neutralGray.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConst.radiusM),
            borderSide: const BorderSide(color: ColorConst.primaryGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConst.radiusM),
            borderSide: const BorderSide(color: ColorConst.expenseRed),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UIConst.spacingM,
            vertical: UIConst.spacingM,
          ),
          labelStyle: const TextStyle(color: ColorConst.textSecondary),
          hintStyle: const TextStyle(color: ColorConst.textSecondary),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConst.primaryGreen,
            foregroundColor: ColorConst.textOnPrimary,
            elevation: UIConst.elevationLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConst.radiusM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: UIConst.spacingL,
              vertical: UIConst.spacingM,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: ColorConst.primaryGreen,
            side: const BorderSide(color: ColorConst.primaryGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConst.radiusM),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: UIConst.spacingL,
              vertical: UIConst.spacingM,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: ColorConst.primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConst.radiusS),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: UIConst.spacingM,
              vertical: UIConst.spacingS,
            ),
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}
