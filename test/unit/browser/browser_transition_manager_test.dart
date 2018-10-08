@TestOn('browser')
import 'dart:async';
import 'dart:html' hide Location;

import 'package:test/test.dart';

import 'package:history/src/core/location.dart';
import 'package:history/src/browser/browser_history.dart';
import 'package:history/src/browser/browser_transition_manager.dart';
import 'package:history/src/utils/utils.dart' show Prompt, Action;

import '../mocks/history_mocks.dart' show MockBrowserHistory;
import '../mocks/mocks.dart' show MockLocation;

void main() {
  group('BrowserTransitionManager', () {
    BrowserTransitionManager<BrowserHistory> transitionManager;

    group('confirmTransitionTo', () {
      setUp(() {
        Prompt prompt =
            (Location _, Action __) async => new Future.value('test');
        transitionManager = new BrowserTransitionManager<BrowserHistory>();
        transitionManager.prompt = prompt;
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
      setUp(() {
        transitionManager = new BrowserTransitionManager<BrowserHistory>();
      });

      test('notifies stream listeners when valid transition is passed',
          () async {
        MockBrowserHistory mockBrowserHistory = new MockBrowserHistory();
        MockBrowserHistory completeBrowserHistory = new MockBrowserHistory();
        Completer c = new Completer();
        int callCount = 0;
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
        MockBrowserHistory mockBrowserHistory = new MockBrowserHistory();
        MockBrowserHistory completeBrowserHistory = new MockBrowserHistory();
        Completer c = new Completer();
        int callCount = 0;
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
        transitionManager = new BrowserTransitionManager<BrowserHistory>();
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
      PopStateChangeHandler handler;
      Prompt prompt;

      setUp(() {
        c = new Completer();
        callCount = 0;
        handler = (Event e) {
          e.preventDefault();
          callCount += 1;
          c.complete();
        };
        prompt = (Location _, Action __) async => new Future.value('yes');
        transitionManager = new BrowserTransitionManager<BrowserHistory>(
            popStateChangeHandler: handler);
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
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));
      });

      test('are removed when prompt is removed (no stream listeners)',
          () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(1));
      });

      test('are added when stream listeners are added (no prompt)', () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));
      });

      test('are added when stream listeners are removed (no prompt)', () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        sub.cancel();
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(1));
      });

      test('remain when prompt is added (with stream listeners)', () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(2));
      });

      test('remain when prompt is removed (with stream listeners)', () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(3));
      });

      test('remain when stream listeners are added (with non-null prompt)',
          () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(2));
      });

      test('remain when stream listeners are removed (with non-null prompt)',
          () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(3));

        transitionManager.prompt = null;
      });

      test(
          'are added/removed correctly for the flow: +prompt -> +listen -> -listen -> -prompt',
          () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(3));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(3));
      });

      test(
          'are added/removed correctly for the flow: +prompt -> +listen -> -prompt -> -listen',
          () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(3));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(3));
      });

      test(
          'are added/removed correctly for the flow: +prompt -> -prompt -> +listen -> -listen',
          () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(1));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(2));
      });

      test(
          'are added/removed correctly for the flow: +listen -> +prompt -> -prompt -> -listen',
          () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(3));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(3));
      });

      test(
          'are added/removed correctly for the flow: +listen -> +prompt -> -listen -> -prompt',
          () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        c = new Completer();
        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(3));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(3));
      });

      test(
          'are added/removed correctly for the flow: +listen -> -listen -> +prompt -> -prompt',
          () async {
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(0));

        sub = transitionManager.stream.listen((_) {});
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(1));

        c = new Completer();
        sub.cancel();
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(1));

        c = new Completer();
        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await c.future;
        expect(callCount, equals(2));

        c = new Completer();
        transitionManager.prompt = null;
        window.dispatchEvent(new PopStateEvent('popstate'));
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(2));
      });

      test('hashchange events are tracked when flag is passed', () async {
        Completer c2 = new Completer();
        int callCount2 = 0;
        HashChangeHandler handler2 = (Event e) {
          e.preventDefault();
          callCount2 += 1;
          c2.complete();
        };
        transitionManager = new BrowserTransitionManager<BrowserHistory>(
            popStateChangeHandler: handler,
            hashChangeHandler: handler2,
            needsHashChangeHandler: true);

        c = new Completer();
        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        window.dispatchEvent(new HashChangeEvent('hashchange'));
        await c.future;
        await c2.future;
        expect(callCount, equals(1));
        expect(callCount2, equals(1));
      });

      test('hashchange events are not tracked when flag is not passed',
          () async {
        Completer c2 = new Completer();
        int callCount2 = 0;
        HashChangeHandler handler2 = (Event e) {
          e.preventDefault();
          callCount2 += 1;
          c2.complete();
        };
        transitionManager = new BrowserTransitionManager<BrowserHistory>(
            popStateChangeHandler: handler,
            hashChangeHandler: handler2,
            needsHashChangeHandler: false);

        c = new Completer();
        transitionManager.prompt = prompt;
        window.dispatchEvent(new PopStateEvent('popstate'));
        window.dispatchEvent(new HashChangeEvent('hashchange'));
        await c.future;
        await new Future.delayed(new Duration(microseconds: 1), () {});
        expect(callCount, equals(1));
        expect(callCount2, equals(0));
      });
    });
  });
}
