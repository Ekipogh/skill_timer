import 'package:file_selector/file_selector.dart' show XTypeGroup, openFile;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skill_timer/screens/analytics.dart';
import 'package:skill_timer/screens/session_report.dart';
import '../providers/skill_category_provider.dart';
import '../services/database_backup_service.dart';
import '../widgets/dev_database_utils.dart';
import '../widgets/widgets.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _backupFileType = XTypeGroup(
    label: 'Skill Timer backup',
    extensions: ['json'],
    mimeTypes: ['application/json'],
  );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildStatisticsSection(context),
                const Divider(height: 1),
                _buildActionsSection(context),
                if (kDebugMode) const Divider(height: 1),
                if (kDebugMode) _buildDeveloperSection(context),
              ],
            ),
          ),
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Skill Timer',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Track your learning journey',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Consumer<SkillProvider>(
                builder: (context, provider, child) {
                  final totalCategories = provider.skillCategories.length;
                  final totalSkills = provider.skills.length;

                  return Row(
                    children: [
                      _buildQuickStat(
                        context,
                        icon: Icons.category,
                        label: 'Categories',
                        value: '$totalCategories',
                      ),
                      const SizedBox(width: 20),
                      _buildQuickStat(
                        context,
                        icon: Icons.school,
                        label: 'Skills',
                        value: '$totalSkills',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Statistics'),
        _buildDrawerTile(
          context,
          icon: Icons.dashboard_customize_outlined,
          title: 'Sessions Report',
          subtitle: 'View your learning sessions',
          onTap: () => _navigateToSessionsReport(context),
        ),
        _buildDrawerTile(
          context,
          icon: Icons.analytics_outlined,
          title: 'Progress Analytics',
          subtitle: 'Track your improvement',
          onTap: () => _navigateToAnalytics(context),
        ),
        _buildDrawerTile(
          context,
          icon: Icons.leaderboard_outlined,
          title: 'Achievements',
          subtitle: 'Your learning milestones',
          onTap: () => _navigateToAchievements(context),
          enabled: false, // Not implemented yet
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Actions'),
        _buildDrawerTile(
          context,
          icon: Icons.backup_outlined,
          title: 'Export Data',
          subtitle: 'Backup your progress',
          onTap: () => _exportData(context),
        ),
        _buildDrawerTile(
          context,
          icon: Icons.restore_outlined,
          title: 'Import Data',
          subtitle: 'Restore from backup',
          onTap: () => _importData(context),
        ),
        _buildDrawerTile(
          context,
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'Customize your experience',
          onTap: () => _navigateToSettings(context),
          enabled: false, // Not implemented yet
        ),
      ],
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Developer'),
        _buildDrawerTile(
          context,
          icon: Icons.developer_mode_outlined,
          title: 'Debug Screen',
          subtitle: 'Database utilities & debug info',
          onTap: () => _navigateToDebugScreen(context),
        ),
        _buildDrawerTile(
          context,
          icon: Icons.refresh_outlined,
          title: 'Refresh Data',
          subtitle: 'Reload all categories and skills',
          onTap: () => _refreshData(context),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? Theme.of(context).colorScheme.primary : Colors.grey,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled
              ? Theme.of(context).colorScheme.onSurface
              : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
              : Colors.grey.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Skill Timer v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToSessionsReport(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/sessions_report'),
        builder: (context) => const SessionReport(),
      ),
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/analytics'),
        builder: (context) => const AnalyticsScreen(),
      ),
    );
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.pop(context); // Close drawer
    // TODO: Implement achievements screen
  }

  Future<void> _exportData(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    Navigator.pop(context); // Close drawer
    try {
      final bytes = await DatabaseBackupService().exportBackup();
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final fileName = 'skill_timer_backup_$date.json';
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes, mimeType: 'application/json', name: fileName),
          ],
          fileNameOverrides: [fileName],
          subject: 'Skill Timer backup',
          sharePositionOrigin: shareOrigin,
        ),
      );
    } catch (error) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: 'Could not export data: $error',
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    Navigator.pop(context); // Close drawer
    try {
      final file = await openFile(
        acceptedTypeGroups: const [_backupFileType],
        confirmButtonText: 'Import',
      );
      if (file == null || !context.mounted) return;

      final bytes = await file.readAsBytes();
      DatabaseBackupService.decodeAndValidate(bytes);
      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Replace all data?'),
          content: const Text(
            'Importing this backup will replace every current category, skill, and session. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      await DatabaseBackupService().importBackup(bytes);
      if (!context.mounted) return;
      await context.read<SkillProvider>().refresh();
      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Backup imported successfully',
        );
      }
    } catch (error) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: 'Could not import data: $error',
        );
      }
    }
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pop(context); // Close drawer
    // TODO: Implement settings screen
  }

  void _navigateToDebugScreen(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/debug'),
        builder: (context) => const DevDatabaseUtils(),
      ),
    );
  }

  void _refreshData(BuildContext context) {
    Navigator.pop(context); // Close drawer
    context.read<SkillProvider>().refresh();

    // Show confirmation
    CustomSnackBar.showSuccess(context, message: 'Data refreshed successfully');
  }
}
