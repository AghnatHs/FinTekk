import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/presentation/page/home_page.dart';
import 'package:fl_finance_mngt/presentation/page/report_page.dart';
import 'package:fl_finance_mngt/presentation/page/settings_page.dart';
import 'package:fl_finance_mngt/service/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => MainPageState();
}

class MainPageState extends ConsumerState<MainPage> with TickerProviderStateMixin {
  int currentPageIndex = 0;
  late AnimationController _fabAnimationController;
  late AnimationController _pageAnimationController;
  late Animation<double> _fabScaleAnimation;
  late PageController _pageController;

  final List<Widget> pages = [
    const HomePage(),
    const ReportPage(),
    const SettingsPage(),
  ];

  final List<NavigationItem> navigationItems = [
    NavigationItem(
      icon: Icons.home_rounded,
      selectedIcon: Icons.home,
      label: 'Home',
      description: 'Overview and transactions',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics_rounded,
      label: 'Reports',
      description: 'Financial insights',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
      description: 'App configuration',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _fabAnimationController.forward();
    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index != currentPageIndex) {
      HapticFeedback.lightImpact();
      setState(() {
        currentPageIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ColorConst.surfaceLight,
      extendBody: true,

      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConst.spacingS),
              decoration: BoxDecoration(
                color: ColorConst.textOnPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(UIConst.radiusS),
              ),
              child: Icon(
                navigationItems[currentPageIndex].selectedIcon,
                color: ColorConst.textOnPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConst.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    navigationItems[currentPageIndex].label,
                    style: theme.appBarTheme.titleTextStyle?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    navigationItems[currentPageIndex].description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ColorConst.textOnPrimary.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: ColorConst.primaryGreen,
        foregroundColor: ColorConst.textOnPrimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorConst.primaryGreen,
                ColorConst.primaryGreenDark,
              ],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(bottom: 70), 
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          children: pages,
        ),
      ),

      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: currentPageIndex == 0
          ? AnimatedBuilder(
              animation: _fabScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabScaleAnimation.value,
                  child: ExpandableFab(
                    key: GlobalKey<ExpandableFabState>(),
                    overlayStyle: ExpandableFabOverlayStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                      blur: 4,
                    ),
                    type: ExpandableFabType.up,
                    distance: 70,
                    childrenAnimation: ExpandableFabAnimation.rotate,
                    childrenOffset: const Offset(0, 10),
                    openButtonBuilder: FloatingActionButtonBuilder(
                      size: 64,
                      builder: (context, onPressed, progress) {
                        return Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ColorConst.primaryGreen,
                                ColorConst.primaryGreenDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: ColorConst.primaryGreen.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onPressed,
                              borderRadius: BorderRadius.circular(32),
                              child: const Icon(
                                Icons.add_rounded,
                                color: ColorConst.textOnPrimary,
                                size: 28,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    closeButtonBuilder: FloatingActionButtonBuilder(
                      size: 64,
                      builder: (context, onPressed, progress) {
                        return Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ColorConst.expenseRed,
                                ColorConst.expenseRed.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: ColorConst.expenseRed.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onPressed,
                              borderRadius: BorderRadius.circular(32),
                              child: const Icon(
                                Icons.close_rounded,
                                color: ColorConst.textOnPrimary,
                                size: 28,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    children: [
                      // Add Internal Transfer
                      _buildFabChild(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          DialogService.pushInputInternalTransferDialog(context);
                        },
                        icon: Icons.swap_horiz_rounded,
                        label: 'Transfer',
                        color: ColorConst.accentBlue,
                      ),
                      // Add Transaction
                      _buildFabChild(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          DialogService.pushInputTransactionDialog(context);
                        },
                        icon: Icons.add_circle_rounded,
                        label: 'Transaction',
                        color: ColorConst.primaryGreen,
                      ),
                    ],
                  ),
                );
              },
            )
          : null,

      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ColorConst.neutralGray.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(UIConst.radiusL),
              topRight: Radius.circular(UIConst.radiusL),
            ),
            child: NavigationBar(
              selectedIndex: currentPageIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: ColorConst.surfaceLight,
              height: 70, 
              animationDuration: const Duration(milliseconds: 300),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentPageIndex;

                return NavigationDestination(
                  icon: Container(
                    padding: const EdgeInsets.all(UIConst.spacingS),
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected ? ColorConst.primaryGreen : ColorConst.textSecondary,
                    ),
                  ),
                  selectedIcon: Container(
                    padding: const EdgeInsets.all(UIConst.spacingS),
                    child: Icon(
                      item.selectedIcon,
                      color: ColorConst.primaryGreen,
                    ),
                  ),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFabChild({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConst.spacingM,
            vertical: UIConst.spacingS,
          ),
          decoration: BoxDecoration(
            color: ColorConst.cardBackground,
            borderRadius: BorderRadius.circular(UIConst.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: ColorConst.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: UIConst.spacingM),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(28),
              child: Icon(
                icon,
                color: ColorConst.textOnPrimary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String description;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.description,
  });
}
