import 'package:fl_finance_mngt/database/app_config.dart';
import 'package:fl_finance_mngt/database/app_config_provider.dart';
import 'package:fl_finance_mngt/service/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppConfig appConfig = ref.watch(appConfigProvider);

    return SettingsList(
        lightTheme: SettingsThemeData(
            settingsListBackground: Theme.of(context).colorScheme.background),
        sections: [
          SettingsSection(
            title: const Text('Transaction'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Account Editor'),
                value: const Text('Add or edit a transaction account'),
                onPressed: (BuildContext context) => DialogService.pushAccountEditor(context),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.category),
                title: const Text('Category Editor'),
                value: const Text('Add or edit a transaction category'),
                onPressed: (BuildContext context) => DialogService.pushCategoryEditor(context),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('About'),
            tiles: [
              SettingsTile(
                leading: const Icon(Icons.info_outline),
                title: Text(appConfig.getInfo),
                value: Text(appConfig.getPackage),
              ),
            ],
          ),
        ]);
  }
}
