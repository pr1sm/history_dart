@TestOn('browser')
import 'dart:async';
import 'dart:html' hide Location;

import 'package:test/test.dart';

import 'package:history/src/core/location.dart';
import 'package:history/src/browser/hash_history.dart';
import 'package:history/src/browser/hash_transition_manager.dart';
import 'package:history/src/utils/utils.dart' show Prompt, Action;

import '../mocks/history_mocks.dart' show MockHashHistory;
import '../mocks/mocks.dart' show MockLocation;

void main() {
  group('HashTransitionManager', () {
    HashTransitionManager<HashHistory> transitionManager;

    group('confirmTransitionTo', () {
      setUp(() {
        Prompt prompt =
            (Location _, Action __) async => new Future.value('test');
        transitionManager = new HashTransitionManager<HashHistory>();
        transitionManager.prompt = prompt;
      });

      test('returns true when prompt is null', () async {
        transitionManager.prompt = null;
        var nullCheck =
            await transitionManager.confirmTransitionTo(null, null, null);
        var nonNullCheck = await transitionManager.confirmTransitionTo(
            new MockLocation(),
            Action.pop,
            (_) async => new Future.value(false));
        expect(nullCheck, isTrue);
        expect(nonNullCheck, isTrue);
      });

      test('returns true when prompt is not null, but confirmation is null',
          () async {
        var check = await transitionManager.confirmTransitionTo(
            new MockLocation(), Action.pop, null);
        expect(check, isTrue);
      });

      test(
          'returns confirmation result when all necessary parameters are provided',
          () async {
        var check = await transitionManager.confirmTransitionTo(
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
      setUp(() {
        transitionManager = new HashTransitionManager<HashHistory>();
      });

      test('notifies stream listeners when valid transition is passed',
          () async {
        var mockBrowserHistory = new MockHashHistory();
        var completeBrowserHistory = new MockHashHistory();
        var c = new Completer();
        var callCount = 0;
        transitionManager.stream.listen((data) {
          callCount += 1;
          if (data == completeBrowserHistory) {
            c.complete();
          }
        });

        transitionManager.notify(mockBrowserHistory);
        transitionManager.notify(mockBrowserHistory);
        transitionManager.notify(mockBrowserHistory);
        transitionManager.notify(completeBrowserHistory);

        await c.future;

        expect(callCount, equals(4));
      });

      test('handles null transition correctly', () async {
        var mockBrowserHistory = new MockHashHistory();
        var completeBrowserHistory = new MockHashHistory();
        var c = new Completer();
        var callCount = 0;
        transitionManager.stream.listen((data) {
          callCount += 1;
          if (data == completeBrowserHistory) {
            c.complete();
          }
        });

        transitionManager.notify(mockBrowserHistory);
        transitionManager.notify(null);
        transitionManager.notify(mockBrowserHistory);
        transitionManager.notify(completeBrowserHistory);

        await c.future;

        expect(callCount, equals(3));
      });
    });

    group('super prompt', () {
      Prompt prompt;

      setUp(() {
        transitionManager = new HashTransitionManager<HashHistory>();
        prompt = (Location _, Action __) async => new Future.value('test');
      });

      test('setting new prompt works correctly', () async {
        transitionManager.prompt = prompt;
        expect(transitionManager.prompt, equals(prompt));
        expect(await (transitionManager.prompt)(null, null), equals('test'));
      });

      test('overriding prompt works correctly', () async {
        var newPrompt =
            (Location _, Action __) async => new Future.value('newtest');

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

    group('window listeners', () {
      Completer c;
      int callCount;
      StreamSubscription sub;
      HashChangeHandler handler;

      setUp(() {
        c = new Completer();
        callCount = 0;
        handler = (Event e) {
          e.preventDefault();
          callCount += 1;
          c.complete();
        };
        transitionManager =
            new HashTransitionManager<HashHistory>(hashChangeHandler: handler);
      });

      tearDown(() {
        if (sub != null) {
          sub.cancel();
        }
        if (transitionManager.prompt != null) {
          transitionManager.prompt = null;
        }
        if (!c.isCompleted) {
          c.complete();
        }
        callCount = 0;
      });

      test('are added when prompt is added (no stream listeners)', () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));
      });

      test('are removed when prompt is removed (no stream listeners)',
          () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(1));
      });

      test('are added when stream listeners are added (no prompt)', () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));
      });

      test('are added when stream listeners are removed (no prompt)', () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        sub.cancel();
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(1));
      });

      test('remain when prompt is added (with stream listeners)', () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        transitionManager.prompt = ((_, __) async => new Future.value('yes'));
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(2));
      });

      test('remain when prompt is removed (with stream listeners)', () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(3));
      });

      test('remain when stream listeners are added (with non-null prompt)',
          () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(2));
      });

      test('remain when stream listeners are removed (with non-null prompt)',
          () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(3));

        transitionManager.prompt = null;
      });

      test(
          'are added/removed correctly for the flow: +prompt -> +listen -> -listen -> -prompt',
          () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(3));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(3));
      });

      test(
          'are added/removed correctly for the flow: +prompt -> +listen -> -prompt -> -listen',
          () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(3));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(3));
      });

      test(
          'are added/removed correctly for the flow: +prompt -> -prompt -> +listen -> -listen',
          () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(1));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(2));
      });

      test(
          'are added/removed correctly for the flow: +listen -> +prompt -> -prompt -> -listen',
          () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(3));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(3));
      });

      test(
          'are added/removed correctly for the flow: +listen -> +prompt -> -listen -> -prompt',
          () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(3));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(3));
      });

      test(
          'are added/removed correctly for the flow: +listen -> -listen -> +prompt -> -prompt',
          () async {
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(1));

        c = new Completer();
        transitionManager.prompt =
            (Location _, Action __) async => new Future.value('yes');
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('hashchange'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(2));
      });
    });
  });
}
