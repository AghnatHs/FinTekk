import 'package:fl_finance_mngt/presentation/page/home_page.dart';
import 'package:fl_finance_mngt/presentation/page/report_page.dart';
import 'package:fl_finance_mngt/presentation/page/settings_page.dart';
import 'package:fl_finance_mngt/service/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => MainPageState();
}

class MainPageState extends ConsumerState<MainPage> {
  int currentPageIndex = 0;
  List<Widget> pages = [
    const HomePage(),
    const ReportPage(),
    const SettingsPage(),
  ];
  List<String> pagesTitle = ['Home', 'Report', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: currentPageIndex == 0
          ? FloatingActionButton(
              onPressed: () =>
                DialogService.pushInputTransactionDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
      appBar: AppBar(
        title: Center(child: Text(pagesTitle[currentPageIndex])),
        surfaceTintColor: Theme.of(context).primaryColor,
      ),
      body: Padding(padding: const EdgeInsets.all(8), child: pages[currentPageIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          )
        ],
      ),
    );
  }
}
