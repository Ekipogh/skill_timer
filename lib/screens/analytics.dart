import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/models/learning_session.dart';
import 'package:skill_timer/models/skill.dart';
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
                const SizedBox(height: 16),
                _buildActivityAndStreak(skillProvider),
                const SizedBox(height: 16),
                _buildTrendCharts(skillProvider),
                const SizedBox(height: 16),
                _buildInsightCards(skillProvider),
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
    final pieChart = PieChartCard(
      title: 'Time by Skill',
      data: skillProvider.getTimeBySkill(length: 5),
    );
    final barChart = BarChartCard(
      title: 'Time by Category',
      data: skillProvider.getTimeByCategory(length: 5),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: pieChart),
        const SizedBox(width: 12),
        Expanded(child: barChart),
      ],
    );
  }

  Widget _buildActivityAndStreak(SkillProvider skillProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LearningActivityCard(
            dailyTotals: _buildRecentDailyTotals(skillProvider, weeks: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StreakAnalyticsCard(
            currentStreak: skillProvider.getCurrentStreak(),
            longestStreak: _getLongestStreak(skillProvider.learningSessions),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCharts(SkillProvider skillProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TimeOverTimeCard(
            monthlyTotals: _buildMonthlyTotals(skillProvider.learningSessions),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: WeekdaySessionsCard(
            weekdayTotals: _buildWeekdayTotals(skillProvider.learningSessions),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCards(SkillProvider skillProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnalyticsListCard(
            title: 'Top Skills',
            icon: Icons.emoji_events,
            iconColor: Colors.amber,
            items: _topSkillItems(skillProvider),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnalyticsListCard(
            title: 'Fastest Growing',
            icon: Icons.trending_up,
            iconColor: Colors.green,
            items: _fastestGrowingItems(skillProvider),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnalyticsListCard(
            title: 'Neglected Skills',
            icon: Icons.history,
            iconColor: Colors.deepOrange,
            items: _neglectedSkillItems(skillProvider),
          ),
        ),
      ],
    );
  }

  Map<DateTime, int> _buildRecentDailyTotals(
    SkillProvider provider, {
    required int weeks,
  }) {
    final today = _dateOnly(DateTime.now());
    final start = today.subtract(Duration(days: weeks * 7 - 1));
    final totals = <DateTime, int>{
      for (int day = 0; day < weeks * 7; day++)
        start.add(Duration(days: day)): 0,
    };

    for (final session in provider.learningSessions) {
      final date = _dateOnly(session.datePerformed);
      if (totals.containsKey(date)) {
        totals[date] = totals[date]! + session.duration;
      }
    }

    return totals;
  }

  Map<String, int> _buildMonthlyTotals(List<LearningSession> sessions) {
    final now = DateTime.now();
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final months = List.generate(6, (index) {
      final monthOffset = 5 - index;
      return DateTime(now.year, now.month - monthOffset);
    });
    final totals = <String, int>{
      for (final month in months) labels[month.month - 1]: 0,
    };

    for (final session in sessions) {
      for (final month in months) {
        if (session.datePerformed.year == month.year &&
            session.datePerformed.month == month.month) {
          final key = labels[month.month - 1];
          totals[key] = totals[key]! + session.duration;
        }
      }
    }

    return totals;
  }

  Map<String, int> _buildWeekdayTotals(List<LearningSession> sessions) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final totals = <String, int>{for (final label in labels) label: 0};

    for (final session in sessions) {
      final label = labels[session.datePerformed.weekday - 1];
      totals[label] = totals[label]! + session.duration;
    }

    return totals;
  }

  List<AnalyticsListItem> _topSkillItems(SkillProvider provider) {
    return provider
        .getTimeBySkill(length: 3)
        .entries
        .map(
          (entry) => AnalyticsListItem(
            title: entry.key,
            trailing: Formatters.formatDurationFromSeconds(entry.value),
          ),
        )
        .toList();
  }

  List<AnalyticsListItem> _fastestGrowingItems(SkillProvider provider) {
    final now = DateTime.now();
    final currentStart = now.subtract(const Duration(days: 30));
    final previousStart = now.subtract(const Duration(days: 60));
    final items = <AnalyticsListItem>[];

    for (final skill in provider.skills) {
      final current = provider.learningSessions
          .where(
            (session) =>
                session.skillId == skill.id &&
                session.datePerformed.isAfter(currentStart),
          )
          .fold(0, (sum, session) => sum + session.duration);
      final previous = provider.learningSessions
          .where(
            (session) =>
                session.skillId == skill.id &&
                session.datePerformed.isAfter(previousStart) &&
                !session.datePerformed.isAfter(currentStart),
          )
          .fold(0, (sum, session) => sum + session.duration);

      if (current == 0) continue;
      final growth = previous == 0
          ? 100
          : (((current - previous) / previous) * 100).round();
      items.add(
        AnalyticsListItem(
          title: skill.name,
          trailing: '+$growth%',
          trailingColor: Colors.green,
        ),
      );
    }

    items.sort((a, b) {
      final aValue = int.tryParse(a.trailing.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
      final bValue = int.tryParse(b.trailing.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
      return bValue.compareTo(aValue);
    });
    return items.take(3).toList();
  }

  List<AnalyticsListItem> _neglectedSkillItems(SkillProvider provider) {
    final now = DateTime.now();
    final items = <({Skill skill, DateTime? lastSession})>[];

    for (final skill in provider.skills) {
      final sessions = provider.learningSessions
          .where((session) => session.skillId == skill.id)
          .toList()
        ..sort((a, b) => b.datePerformed.compareTo(a.datePerformed));
      items.add((skill: skill, lastSession: sessions.isEmpty ? null : sessions.first.datePerformed));
    }

    items.sort((a, b) {
      if (a.lastSession == null && b.lastSession == null) return 0;
      if (a.lastSession == null) return -1;
      if (b.lastSession == null) return 1;
      return a.lastSession!.compareTo(b.lastSession!);
    });

    return items.take(3).map((item) {
      final trailing = item.lastSession == null
          ? 'Never'
          : '${now.difference(item.lastSession!).inDays} days ago';
      return AnalyticsListItem(title: item.skill.name, trailing: trailing);
    }).toList();
  }

  int _getLongestStreak(List<LearningSession> sessions) {
    if (sessions.isEmpty) return 0;
    final activeDates = sessions.map((session) => _dateOnly(session.datePerformed)).toSet().toList()
      ..sort();

    var longest = 1;
    var current = 1;
    for (var index = 1; index < activeDates.length; index++) {
      if (activeDates[index].difference(activeDates[index - 1]).inDays == 1) {
        current++;
      } else {
        longest = current > longest ? current : longest;
        current = 1;
      }
    }
    return current > longest ? current : longest;
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}

class LearningActivityCard extends StatelessWidget {
  final Map<DateTime, int> dailyTotals;

  const LearningActivityCard({required this.dailyTotals, super.key});

  @override
  Widget build(BuildContext context) {
    final maxDuration = dailyTotals.values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    final days = dailyTotals.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellSize = ((constraints.maxWidth - 15 * 4) / 16)
                      .clamp(8.0, 18.0);
                  return Wrap(
                    direction: Axis.vertical,
                    spacing: 4,
                    runSpacing: 4,
                    children: days.map((entry) {
                      final intensity = maxDuration == 0
                          ? 0.0
                          : entry.value / maxDuration;
                      return Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            Colors.green.withValues(alpha: 0.12),
                            Colors.green,
                            intensity,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Less', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 8),
                for (final alpha in [0.12, 0.28, 0.44, 0.64, 0.88]) ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: alpha),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text('More', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StreakAnalyticsCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakAnalyticsCard({
    required this.currentStreak,
    required this.longestStreak,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Streak', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _StreakRing(
                    value: currentStreak,
                    label: 'Current Streak',
                    color: Colors.deepOrange,
                    icon: Icons.local_fire_department,
                  ),
                ),
                Expanded(
                  child: _StreakRing(
                    value: longestStreak,
                    label: 'Longest Streak',
                    color: Colors.amber,
                    icon: Icons.emoji_events,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakRing extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final IconData icon;

  const _StreakRing({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 118,
          height: 118,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value == 0
                    ? 0.0
                    : (value / (value + 8)).clamp(0.0, 1.0).toDouble(),
                strokeWidth: 5,
                color: color,
                backgroundColor: color.withValues(alpha: 0.16),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color),
                  Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text('days'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

class TimeOverTimeCard extends StatelessWidget {
  final Map<String, int> monthlyTotals;

  const TimeOverTimeCard({required this.monthlyTotals, super.key});

  @override
  Widget build(BuildContext context) {
    final entries = monthlyTotals.entries.toList();
    final maxSeconds = monthlyTotals.values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    final maxY = maxSeconds <= 0 ? 1.0 : (maxSeconds / 3600) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time Over Time', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toStringAsFixed(0)}h',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              entries[index].key,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var index = 0; index < entries.length; index++)
                          FlSpot(index.toDouble(), entries[index].value / 3600),
                      ],
                      color: Colors.deepPurple,
                      barWidth: 3,
                      isCurved: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.deepPurple.withValues(alpha: 0.14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeekdaySessionsCard extends StatelessWidget {
  final Map<String, int> weekdayTotals;

  const WeekdaySessionsCard({required this.weekdayTotals, super.key});

  @override
  Widget build(BuildContext context) {
    final maxValue = weekdayTotals.values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sessions by Weekday',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...weekdayTotals.entries.map((entry) {
              final value = maxValue == 0 ? 0.0 : entry.value / maxValue;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(width: 34, child: Text(entry.key)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 12,
                          color: Colors.blue,
                          backgroundColor: Colors.blue.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 52,
                      child: Text(
                        Formatters.formatDurationFromSeconds(entry.value),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class AnalyticsListItem {
  final String title;
  final String trailing;
  final Color? trailingColor;

  const AnalyticsListItem({
    required this.title,
    required this.trailing,
    this.trailingColor,
  });
}

class AnalyticsListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<AnalyticsListItem> items;

  const AnalyticsListCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.isEmpty
        ? [const AnalyticsListItem(title: 'No data yet', trailing: '')]
        : items;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var index = 0; index < visibleItems.length; index++) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: iconColor.withValues(alpha: 0.18),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(fontSize: 11, color: iconColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      visibleItems[index].title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    visibleItems[index].trailing,
                    style: TextStyle(
                      color: visibleItems[index].trailingColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (index < visibleItems.length - 1) const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
