import 'package:fl_finance_mngt/presentation/page/home_page.dart';
import 'package:fl_finance_mngt/presentation/page/report_page.dart';
import 'package:fl_finance_mngt/presentation/page/settings_page.dart';
import 'package:fl_finance_mngt/presentation/widget/fab_item_title.dart';
import 'package:fl_finance_mngt/service/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => MainPageState();
}

class MainPageState extends ConsumerState<MainPage> {
  bool extendFab = false;

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
      /* floatingActionButton: currentPageIndex == 0
          ? FloatingActionButton(
              onPressed: () =>
                DialogService.pushInputTransactionDialog(context),
              child: const Icon(Icons.add),
            )
          : null, */
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: currentPageIndex == 0
          ? ExpandableFab(
              overlayStyle: const ExpandableFabOverlayStyle(color: Colors.black54, blur: 3),
              type: ExpandableFabType.up,
              distance: 55,
              children: [
                Row(
                  children: [
                    const FabItemTitle(title: 'Add Internal Transfer'),
                    const SizedBox(width: 10),
                    FloatingActionButton.small(
                      heroTag: null,
                      child: const Icon(Icons.attach_money),
                      onPressed: () => DialogService.pushInputInternalTransferDialog(context),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const FabItemTitle(title: 'Add Transaction'),
                    const SizedBox(width: 10),
                    FloatingActionButton.small(
                      heroTag: null,
                      child: const Icon(Icons.add),
                      onPressed: () => DialogService.pushInputTransactionDialog(context),
                    ),
                  ],
                ),
              ],
            )
          : null,
      appBar: AppBar(
        title: Center(child: Text(pagesTitle[currentPageIndex])),
        surfaceTintColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
          padding: EdgeInsets.all(currentPageIndex == 1 ? 0 : 8),
          child: pages[currentPageIndex]),
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