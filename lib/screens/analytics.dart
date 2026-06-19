import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/utils/formatters.dart';
import '../providers/skill_category_provider.dart';
import '../widgets/widgets.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Make sure data is loaded when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SkillProvider>();
      if (provider.learningSessions.isEmpty) {
        provider.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithGradient(
      appBar: CustomAppBar(title: 'Analytics', centerTitle: true),
      body: Consumer<SkillProvider>(
        builder: (context, skillProvider, child) {
          // Loading state
          if (skillProvider.isLoading &&
              skillProvider.learningSessions.isEmpty) {
            return const LoadingCard(text: 'Loading session data...');
          }

          // Error state
          if (skillProvider.hasError) {
            return ErrorCard(
              title: 'Failed to load sessions',
              message: skillProvider.error ?? 'Unknown error',
              buttonText: 'Retry',
              onButtonPressed: () => skillProvider.refresh(),
            );
          }

          // No data state
          if (skillProvider.learningSessions.isEmpty) {
            return const Center(child: Text('No session data available.'));
          }
          // Data available state
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildAnalyticsSummary(),
                SizedBox(height: 16),
                _buildPeriodStrip(),
                SizedBox(height: 16),
                _buildTimeCharts(skillProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatCard(
          title: 'Total Hours',
          value: Formatters.formatDurationFromSeconds(
            context.watch<SkillProvider>().getTotalTime(),
          ),
          icon: Icons.access_time,
          color: Colors.blue,
        ),
        StatCard(
          title: 'Total Sessions',
          value: context
              .watch<SkillProvider>()
              .learningSessions
              .length
              .toString(),
          icon: Icons.list_alt,
          color: Colors.green,
        ),
        StatCard(
          title: 'Average Session',
          value: Formatters.formatDurationFromSeconds(
            context.watch<SkillProvider>().getAverageSessionDuration(),
          ),
          icon: Icons.timer,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Session Streak',
          value: context.watch<SkillProvider>().getCurrentStreak().toString(),
          icon: Icons.whatshot,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildPeriodStrip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: PeriodMetric(
              icon: Icons.today,
              label: 'Today',
              value: Formatters.formatDurationFromSeconds(
                context.watch<SkillProvider>().getTimeForPeriod(Period.today),
              ),
              color: Colors.blue,
            ),
          ),
          _divider(),
          Expanded(
            child: PeriodMetric(
              icon: Icons.date_range,
              label: 'This Week',
              value: Formatters.formatDurationFromSeconds(
                context.watch<SkillProvider>().getTimeForPeriod(Period.thisWeek),
              ),
              color: Colors.green,
            ),
          ),
          _divider(),
          Expanded(
            child: PeriodMetric(
              icon: Icons.calendar_today,
              label: 'This Month',
              value: Formatters.formatDurationFromSeconds(
                context.watch<SkillProvider>().getTimeForPeriod(Period.thisMonth),
              ),
              color: Colors.orange,
            ),
          ),
          _divider(),
          Expanded(
            child: PeriodMetric(
              icon: Icons.calendar_view_month,
              label: 'This Year',
              value: Formatters.formatDurationFromSeconds(
                context.watch<SkillProvider>().getTimeForPeriod(Period.thisYear),
              ),
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const VerticalDivider(color: Colors.grey, thickness: 1, width: 20);
  }

  Widget _buildTimeCharts(SkillProvider skillProvider) {
    return Row(
      children: [
        Expanded(
          child: PieChartCard(
            title: 'Time by Skill',
            data: skillProvider.getTimeBySkill(length: 5),
          ),
        ),
      ],
    );
  }
}
