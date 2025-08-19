import 'package:fl_finance_mngt/core/constants.dart';
import 'package:fl_finance_mngt/database/app_config.dart';
import 'package:fl_finance_mngt/database/app_config_provider.dart';
import 'package:fl_finance_mngt/service/dialog_services.dart';
import 'package:fl_finance_mngt/service/export_database_services.dart';
import 'package:fl_finance_mngt/service/permission_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppConfig appConfig = ref.watch(appConfigProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorConst.surfaceLight,
            ColorConst.surfaceLight.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                UIConst.spacingM,
                UIConst.spacingL,
                UIConst.spacingM,
                UIConst.spacingXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Management Section
                  _buildSection(
                    title: 'Transaction Management',
                    icon: Icons.account_balance_wallet,
                    color: ColorConst.primaryGreen,
                    children: [
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Account Editor',
                        subtitle: 'Add or edit transaction accounts',
                        color: ColorConst.accentBlue,
                        onTap: () => DialogService.pushAccountEditor(context),
                      ),
                      const SizedBox(height: UIConst.spacingS),
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.category_outlined,
                        title: 'Category Editor',
                        subtitle: 'Add or edit transaction categories',
                        color: ColorConst.accentPurple,
                        onTap: () => DialogService.pushCategoryEditor(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: UIConst.spacingXL),

                  // Data Management Section
                  _buildSection(
                    title: 'Data Management',
                    icon: Icons.storage,
                    color: ColorConst.accentOrange,
                    children: [
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.backup_outlined,
                        title: 'Export Database',
                        subtitle: 'Export data to Downloads directory',
                        color: ColorConst.accentOrange,
                        onTap: () => _handleDatabaseExport(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: UIConst.spacingXL),

                  // App Information Section
                  _buildSection(
                    title: 'App Information',
                    icon: Icons.info,
                    color: ColorConst.neutralGray,
                    children: [
                      _buildInfoCard(
                        context: context,
                        appConfig: appConfig,
                        theme: theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConst.spacingM,
            vertical: UIConst.spacingS,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConst.spacingS),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UIConst.radiusS),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: UIConst.spacingM),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ColorConst.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: UIConst.spacingS),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(UIConst.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(UIConst.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(UIConst.spacingL),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConst.spacingM),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UIConst.radiusM),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: UIConst.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ColorConst.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: UIConst.spacingXS),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ColorConst.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(UIConst.spacingS),
                decoration: BoxDecoration(
                  color: ColorConst.surfaceLight,
                  borderRadius: BorderRadius.circular(UIConst.radiusS),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ColorConst.textSecondary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required AppConfig appConfig,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(UIConst.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConst.neutralGray.withValues(alpha: 0.1),
            ColorConst.neutralGray.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(UIConst.radiusL),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConst.spacingM),
                decoration: BoxDecoration(
                  color: ColorConst.neutralGray.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UIConst.radiusM),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: ColorConst.neutralGray,
                  size: 24,
                ),
              ),
              const SizedBox(width: UIConst.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appConfig.getInfo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorConst.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: UIConst.spacingXS),
                    Text(
                      appConfig.getPackage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorConst.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConst.spacingM),
          Container(
            padding: const EdgeInsets.all(UIConst.spacingM),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(UIConst.radiusM),
              border: Border.all(
                color: ColorConst.primaryGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: ColorConst.primaryGreen,
                  size: 18,
                ),
                const SizedBox(width: UIConst.spacingS),
                Expanded(
                  child: Text(
                    'Thank you for using FinTekk!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ColorConst.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDatabaseExport(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(UIConst.spacingXL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(UIConst.radiusL),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: ColorConst.primaryGreen,
                ),
                const SizedBox(height: UIConst.spacingM),
                Text(
                  'Exporting database...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ColorConst.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      );

      bool hasPermission = await PermissionService.requestAllStoragePermissions();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (hasPermission) {
        // Proceed with database export
        await exportDatabaseToDownloads();
        if (!context.mounted) return;

        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                SizedBox(width: UIConst.spacingS),
                Text('Database exported successfully!'),
              ],
            ),
            backgroundColor: ColorConst.incomeGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConst.radiusM),
            ),
          ),
        );
      } else {
        if (!context.mounted) return;

        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.white,
                ),
                SizedBox(width: UIConst.spacingS),
                Expanded(
                  child: Text('Storage permission required to export database'),
                ),
              ],
            ),
            backgroundColor: ColorConst.expenseRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConst.radiusM),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return;

      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
              ),
              SizedBox(width: UIConst.spacingS),
              Expanded(
                child: Text('Failed to export database'),
              ),
            ],
          ),
          backgroundColor: ColorConst.expenseRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConst.radiusM),
          ),
        ),
      );
    }
  }
}
