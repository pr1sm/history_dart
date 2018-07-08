@TestOn('browser || vm')
import 'dart:async';

import 'package:test/test.dart';

import 'package:history/src/core/transition_manager.dart';
import 'package:history/src/utils/utils.dart' show Action, Prompt;

import 'mocks.dart' show MockLocation;

void main() {
  group('TransitionManager', () {
    TransitionManager<String> transitionManager;

    setUp(() {
      transitionManager = new TransitionManager<String>();
    });

    group('confirmTransitionTo', () {
      setUp(() {
        transitionManager.prompt = (_, __) async => new Future.value('test');
      });

      test('returns true when prompt is null', () async {
        transitionManager.prompt = null;
        bool nullCheck =
            await transitionManager.confirmTransitionTo(null, null, null);
        bool nonNullCheck = await transitionManager.confirmTransitionTo(
            new MockLocation(),
            Action.pop,
            (_) async => new Future.value(false));
        expect(nullCheck, isTrue);
        expect(nonNullCheck, isTrue);
      });

      test('returns true when prompt is not null, but confirmation is null',
          () async {
        bool check = await transitionManager.confirmTransitionTo(
            new MockLocation(), Action.pop, null);
        expect(check, isTrue);
      });

      test(
          'returns confirmation result when all necessary parameters are provided',
          () async {
        bool check = await transitionManager.confirmTransitionTo(
            new MockLocation(),
            Action.pop,
            (_) async => new Future.value(true));
        expect(check, isTrue);
        check = await transitionManager.confirmTransitionTo(new MockLocation(),
            Action.pop, (_) async => new Future.value(false));
        expect(check, isFalse);
      });
    });

    group('notify', () {
      test('notifies stream listeners when valid transition is passed',
          () async {
        Completer c = new Completer();
        int callCount = 0;
        transitionManager.stream.listen((data) {
          callCount += 1;
          if (data == 'end') {
            c.complete();
          }
        });

        transitionManager.notify('one');
        transitionManager.notify('two');
        transitionManager.notify('three');
        transitionManager.notify('end');

        await c.future;

        expect(callCount, equals(4));
      });

      test('handles null transition correctly', () async {
        Completer c = new Completer();
        int callCount = 0;
        transitionManager.stream.listen((data) {
          callCount += 1;
          if (data == 'end') {
            c.complete();
          }
        });

        transitionManager.notify('one');
        transitionManager.notify(null);
        transitionManager.notify('two');
        transitionManager.notify('end');

        await c.future;

        expect(callCount, equals(3));
      });
    });

    group('prompt', () {
      Prompt prompt;

      setUp(() {
        prompt = (_, __) async => new Future.value('test');
      });

      test('setting new prompt works correctly', () async {
        transitionManager.prompt = prompt;
        expect(transitionManager.prompt, equals(prompt));
        expect(await (transitionManager.prompt)(null, null), equals('test'));
      });

      test('overriding prompt works correctly', () async {
        var newPrompt = (_, __) async => new Future.value('newtest');

        transitionManager.prompt = prompt;
        expect(transitionManager.prompt, equals(prompt));
        expect(transitionManager.prompt, isNot(equals(newPrompt)));
        expect(await (transitionManager.prompt)(null, null), equals('test'));

        transitionManager.prompt = newPrompt;
        expect(transitionManager.prompt, equals(newPrompt));
        expect(transitionManager.prompt, isNot(equals(prompt)));
        expect(await (transitionManager.prompt)(null, null), equals('newtest'));
      });

      test('setting null prompt works correctly', () async {
        transitionManager.prompt = prompt;
        expect(transitionManager.prompt, equals(prompt));
        expect(await (transitionManager.prompt)(null, null), equals('test'));

        transitionManager.prompt = null;
        expect(transitionManager.prompt, isNull);
      });
    });
  });
}
