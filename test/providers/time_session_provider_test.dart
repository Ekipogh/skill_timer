import 'package:flutter_test/flutter_test.dart';
import 'package:skill_timer/models/skill.dart';
import 'package:skill_timer/providers/skill_category_provider.dart';
import 'package:skill_timer/providers/time_session_provider.dart';

class _SuccessfulSkillProvider extends SkillProvider {
  @override
  Future<void> addSession(Map<String, Object> session) async {}
}

void main() {
  const target = Duration(seconds: 5);
  final firstSkill = Skill(
    id: 'first',
    name: 'First skill',
    description: '',
    category: 'test',
  );
  final secondSkill = Skill(
    id: 'second',
    name: 'Second skill',
    description: '',
    category: 'test',
  );

  group('TimerSessionProvider target time lifecycle', () {
    Future<void> advanceStopwatch(
      WidgetTester tester,
      Duration duration,
    ) async {
      await tester.runAsync(() => Future<void>.delayed(duration));
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('preserves an unmet target when pausing and resuming', (
      tester,
    ) async {
      final provider = TimerSessionProvider();
      addTearDown(provider.dispose);

      await provider.start(firstSkill);
      await provider.setTargetTime(target);
      await tester.pump(const Duration(seconds: 1));
      await provider.pause();

      expect(provider.targetTime, target);

      await provider.resume();
      await tester.pump(const Duration(seconds: 1));

      expect(provider.targetTime, target);
      await provider.pause();
    });

    testWidgets('preserves the target when it is reached', (tester) async {
      final provider = TimerSessionProvider();
      addTearDown(provider.dispose);

      await provider.start(firstSkill);
      await provider.setTargetTime(const Duration(milliseconds: 20));
      await advanceStopwatch(tester, const Duration(milliseconds: 30));

      expect(provider.targetTime, const Duration(milliseconds: 20));
      await provider.pause();
    });

    testWidgets('preserves the target when switching to another skill', (
      tester,
    ) async {
      final provider = TimerSessionProvider();
      addTearDown(provider.dispose);

      await provider.start(firstSkill);
      await provider.setTargetTime(target);
      await provider.start(secondSkill);

      expect(provider.currentSkill, secondSkill);
      expect(provider.targetTime, target);
      await provider.pause();
    });

    testWidgets('clears the target when a session is discarded', (
      tester,
    ) async {
      final provider = TimerSessionProvider();
      addTearDown(provider.dispose);

      await provider.start(firstSkill);
      await provider.setTargetTime(target);
      await provider.discard();

      expect(provider.targetTime, Duration.zero);

      await provider.start(firstSkill);
      expect(provider.targetTime, Duration.zero);
      await provider.pause();
    });

    testWidgets('clears the target after a successful save', (tester) async {
      final provider = TimerSessionProvider();
      final skillProvider = _SuccessfulSkillProvider();
      addTearDown(provider.dispose);
      addTearDown(skillProvider.dispose);

      await provider.start(firstSkill);
      await provider.setTargetTime(target);
      await advanceStopwatch(tester, const Duration(milliseconds: 1100));
      await provider.pause();

      final session = await provider.save(skillProvider);

      expect(session, isNotNull);
      expect(provider.targetTime, Duration.zero);
    });

    testWidgets('a reached target can be replaced in the same session', (
      tester,
    ) async {
      final provider = TimerSessionProvider();
      addTearDown(provider.dispose);

      await provider.start(firstSkill);
      await provider.setTargetTime(const Duration(milliseconds: 20));
      await advanceStopwatch(tester, const Duration(milliseconds: 30));
      expect(provider.targetTime, const Duration(milliseconds: 20));

      await provider.setTargetTime(const Duration(milliseconds: 60));
      await advanceStopwatch(tester, const Duration(milliseconds: 40));

      expect(provider.targetTime, const Duration(milliseconds: 60));
      await provider.pause();
    });
  });
}
