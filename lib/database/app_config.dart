import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: AppConfig notifiers

class AppConfig {
  final SharedPreferences prefs;
  final PackageInfo packageInfo;
  AppConfig(this.prefs, this.packageInfo);

  String get getInfo => '${packageInfo.appName} ${packageInfo.version}';

  String get getPackage => packageInfo.packageName;
}
