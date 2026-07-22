import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';
import '../providers/skill_category_provider.dart';
import '../models/skill.dart';
import '../utils/utils.dart';
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
                  Formatters.formatMonthYear(_selectedMonth),
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
            value: Formatters.formatDuration(totalTime),
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
                          Formatters.formatDuration(entry.value),
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
                          Formatters.formatDate(date),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          Formatters.formatDuration(dayTotal),
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
                            Formatters.formatDuration(session.duration),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          PopupMenuButton<_SessionAction>(
                            tooltip: 'Session actions',
                            onSelected: (action) {
                              switch (action) {
                                case _SessionAction.edit:
                                  _editSession(session, provider);
                                case _SessionAction.delete:
                                  _deleteSession(session, skill.name, provider);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: _SessionAction.edit,
                                child: ListTile(
                                  leading: Icon(Icons.edit_outlined),
                                  title: Text('Edit'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              PopupMenuItem(
                                value: _SessionAction.delete,
                                child: ListTile(
                                  leading: Icon(Icons.delete_outline),
                                  title: Text('Delete'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
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

  Future<void> _editSession(
    LearningSession session,
    SkillProvider provider,
  ) async {
    final updatedSession = await showDialog<LearningSession>(
      context: context,
      builder: (context) =>
          _EditSessionDialog(session: session, skills: provider.skills),
    );
    if (updatedSession == null || !mounted) return;

    final success = await provider.updateSession(updatedSession);
    if (!mounted) return;
    if (success) {
      CustomSnackBar.showSuccess(context, message: 'Session updated');
    } else {
      CustomSnackBar.showError(
        context,
        message: provider.error ?? 'Failed to update session',
      );
    }
  }

  Future<void> _deleteSession(
    LearningSession session,
    String skillName,
    SkillProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session?'),
        content: Text(
          '$skillName · ${Formatters.formatDuration(session.duration)} · '
          '${Formatters.formatDate(session.datePerformed)}\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await provider.deleteSession(session.id);
    if (!mounted) return;
    if (success) {
      CustomSnackBar.showSuccess(context, message: 'Session deleted');
    } else {
      CustomSnackBar.showError(
        context,
        message: provider.error ?? 'Failed to delete session',
      );
    }
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
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.1),
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
}

enum _SessionAction { edit, delete }

class _EditSessionDialog extends StatefulWidget {
  const _EditSessionDialog({required this.session, required this.skills});

  final LearningSession session;
  final List<Skill> skills;

  @override
  State<_EditSessionDialog> createState() => _EditSessionDialogState();
}

class _EditSessionDialogState extends State<_EditSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _skillId;
  late DateTime _date;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    _skillId = widget.session.skillId;
    _date = widget.session.datePerformed;
    _hoursController = TextEditingController(
      text: (widget.session.duration ~/ 3600).toString(),
    );
    _minutesController = TextEditingController(
      text: ((widget.session.duration % 3600) ~/ 60).toString(),
    );
    _secondsController = TextEditingController(
      text: (widget.session.duration % 60).toString(),
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasCurrentSkill = widget.skills.any((skill) => skill.id == _skillId);
    return AlertDialog(
      title: const Text('Edit session'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _skillId,
                  decoration: const InputDecoration(
                    labelText: 'Skill',
                    prefixIcon: Icon(Icons.psychology_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    if (!hasCurrentSkill)
                      DropdownMenuItem(
                        value: _skillId,
                        child: const Text('Unknown skill'),
                      ),
                    ...widget.skills.map(
                      (skill) => DropdownMenuItem(
                        value: skill.id,
                        child: Text(skill.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) _skillId = value;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(Formatters.formatDate(_date)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Duration', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _durationField('Hours', _hoursController)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _durationField(
                        'Minutes',
                        _minutesController,
                        maximum: 59,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _durationField(
                        'Seconds',
                        _secondsController,
                        maximum: 59,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save changes'),
        ),
      ],
    );
  }

  Widget _durationField(
    String label,
    TextEditingController controller, {
    int? maximum,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final number = int.tryParse(value ?? '');
        if (number == null ||
            number < 0 ||
            (maximum != null && number > maximum)) {
          return maximum == null ? 'Invalid' : '0–$maximum';
        }
        return null;
      },
    );
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final defaultFirstDate = DateTime(2020);
    final firstDate = _date.isBefore(defaultFirstDate)
        ? _date
        : defaultFirstDate;
    final lastDate = _date.isAfter(today) ? _date : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _date.hour,
        _date.minute,
        _date.second,
        _date.millisecond,
        _date.microsecond,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final duration =
        int.parse(_hoursController.text) * 3600 +
        int.parse(_minutesController.text) * 60 +
        int.parse(_secondsController.text);
    if (duration == 0) {
      CustomSnackBar.showError(
        context,
        message: 'Duration must be greater than zero',
      );
      return;
    }
    Navigator.of(context).pop(
      widget.session.copyWith(
        skillId: _skillId,
        datePerformed: _date,
        duration: duration,
      ),
    );
  }
}
