import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../providers/skill_category_provider.dart';
import '../models/skill.dart';
import 'package:skill_timer/models/learning_session.dart';

class SessionReport extends StatefulWidget {
  const SessionReport({super.key});

  @override
  State<SessionReport> createState() => _SessionReportState();
}

class _SessionReportState extends State<SessionReport> {
  DateTime _selectedMonth = DateTime.now();

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
      appBar: CustomAppBar(
        title: 'Session Report',
        centerTitle: true,
        actions: [
          CustomIconButton(
            icon: Icons.refresh,
            onPressed: () => context.read<SkillProvider>().refresh(),
            tooltip: 'Refresh Data',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<SkillProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading && provider.learningSessions.isEmpty) {
            return const LoadingCard(text: 'Loading session data...');
          }

          // Error state
          if (provider.hasError) {
            return ErrorCard(
              title: 'Failed to load sessions',
              message: provider.error ?? 'Unknown error',
              buttonText: 'Retry',
              onButtonPressed: () => provider.refresh(),
            );
          }

          // Get sessions for the selected month
          final monthSessions = provider.getSessionsForMonth(_selectedMonth);
          final totalTime = provider.getTotalTimeForMonth(_selectedMonth);
          final totalSessions = provider.getTotalSessionsForMonth(
            _selectedMonth,
          );
          final skillBreakdown = provider.getSkillTimeBreakdownForMonth(
            _selectedMonth,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthSelector(),
                const SizedBox(height: 20),
                _buildSummaryCards(
                  totalTime,
                  totalSessions,
                  monthSessions.length,
                ),
                const SizedBox(height: 20),
                _buildSkillBreakdown(skillBreakdown),
                const SizedBox(height: 20),
                _buildSessionsList(monthSessions, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 24),
            const SizedBox(width: 12),
            Text('Report for', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            InkWell(
              onTap: () => _showMonthPicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatMonth(_selectedMonth),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(int totalTime, int totalSessions, int activeDays) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Time',
            value: _formatDuration(totalTime),
            icon: Icons.timer,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Sessions',
            value: totalSessions.toString(),
            icon: Icons.play_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Active Days',
            value: activeDays.toString(),
            icon: Icons.calendar_today,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillBreakdown(Map<String, int> skillBreakdown) {
    if (skillBreakdown.isEmpty) {
      return EmptyStateCard(
        icon: Icons.bar_chart,
        title: 'No skill data',
        subtitle: 'No learning sessions found for this month',
        buttonText: 'Go to Home',
        onButtonPressed: () => Navigator.of(context).pop(),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time by Skill',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...skillBreakdown.entries.map((entry) {
              final percentage = skillBreakdown.values.isEmpty
                  ? 0.0
                  : (entry.value /
                        skillBreakdown.values.reduce((a, b) => a + b));
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          _formatDuration(entry.value),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
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

  Widget _buildSessionsList(
    List<LearningSession> sessions,
    SkillProvider provider,
  ) {
    if (sessions.isEmpty) {
      return EmptyStateCard(
        icon: Icons.history,
        title: 'No sessions this month',
        subtitle: 'Start a timer session to see your progress here',
        buttonText: 'Go to Home',
        onButtonPressed: () => Navigator.of(context).pop(),
      );
    }

    // Group sessions by date
    final Map<DateTime, List<LearningSession>> sessionsByDate = {};
    for (var session in sessions) {
      final date = DateTime(
        session.datePerformed.year,
        session.datePerformed.month,
        session.datePerformed.day,
      );
      sessionsByDate[date] = [...(sessionsByDate[date] ?? []), session];
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session History',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sessionsByDate.entries.map((entry) {
              final date = entry.key;
              final daySessions = entry.value;
              final dayTotal = daySessions.fold(
                0,
                (sum, session) => sum + session.duration,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(date),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          _formatDuration(dayTotal),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ...daySessions.map((session) {
                    final skill = provider.skills.firstWhere(
                      (s) => s.id == session.skillId,
                      orElse: () => Skill(
                        id: session.skillId,
                        name: 'Unknown Skill',
                        description: '',
                        category: '',
                        totalTimeSpent: 0,
                        sessionsCount: 0,
                      ),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              skill.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            _formatDuration(session.duration),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month'),
        contentPadding: const EdgeInsets.all(16),
        content: SizedBox(
          height: 400,
          width: 320,
          child: _buildCustomMonthPicker(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  Widget _buildCustomMonthPicker() {
    final currentYear = DateTime.now().year;
    final startYear = 2020;
    final years = List.generate(
      currentYear - startYear + 1,
      (index) => startYear + index,
    );
    final months = [
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

    return Column(
      children: [
        // Year selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Year',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    final isSelected = year == _selectedMonth.year;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(year.toString()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMonth = DateTime(
                              year,
                              _selectedMonth.month,
                            );
                          });
                          Navigator.of(
                            context,
                          ).pop(DateTime(year, _selectedMonth.month));
                        },
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Month selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Month',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5,
                ),
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected =
                      month == _selectedMonth.month &&
                      _selectedMonth.year == _selectedMonth.year;
                  final isPastMonth =
                      _selectedMonth.year == DateTime.now().year &&
                      month > DateTime.now().month;

                  return FilterChip(
                    label: Text(
                      months[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: isSelected,
                    onSelected: isPastMonth
                        ? null
                        : (selected) {
                            setState(() {
                              _selectedMonth = DateTime(
                                _selectedMonth.year,
                                month,
                              );
                            });
                            Navigator.of(
                              context,
                            ).pop(DateTime(_selectedMonth.year, month));
                          },
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    disabledColor: Colors.grey[300],
                    labelStyle: TextStyle(
                      color: isPastMonth
                          ? Colors.grey
                          : isSelected
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0
          ? '${minutes}m ${remainingSeconds}s'
          : '${minutes}m';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
