@TestOn('browser || vm')
import 'dart:async';

import 'package:test/test.dart';

import 'package:history/src/core/location.dart';
import 'package:history/src/core/history.dart';
import 'package:history/src/utils/utils.dart' show Action, Confirmation, Prompt;

typedef History HistoryGenerator({Confirmation confirmation});

typedef dynamic testSuiteRunner();

testSuiteRunner testCoreHistory(HistoryGenerator getHistory,
        {bool supportsState = true}) =>
    () {
      History history;
      StreamSubscription sub;

      setUp(() {
        sub = null;
        history = null;
      });

      tearDown(() {
        if (history != null) {
          history.unblock();
          history = null;
        }
        ;
        if (sub != null) {
          sub.cancel();
          sub = null;
        }
      });

      group('length correctly responds to', () {
        setUp(() {
          history = getHistory();
        });
        test('push', () async {
          expect(history.length, equals(1));
          await history.push('/test');
          expect(history.length, equals(2));
          await history.push('/test2');
          expect(history.length, equals(3));
        });

        test('replace', () async {
          expect(history.length, equals(1));
          await history.replace('/test');
          expect(history.length, equals(1));
          await history.push('/test2');
          expect(history.length, equals(2));
          await history.replace('/test3');
          expect(history.length, equals(2));
        });

        test('go', () async {
          expect(history.length, equals(1));
          await history.push('/test');
          expect(history.length, equals(2));
          await history.push('/test2');
          expect(history.length, equals(3));
          await history.go(-2);
          expect(history.length, equals(3));
          await history.go(2);
          expect(history.length, equals(3));
          await history.go(-1);
          expect(history.length, equals(3));
          await history.go(1);
          expect(history.length, equals(3));
          await history.go(0);
          expect(history.length, equals(3));
        });

        test('goForward', () async {
          expect(history.length, equals(1));
          await history.push('/test');
          expect(history.length, equals(2));
          await history.push('/test2');
          expect(history.length, equals(3));
          await history.go(-2);
          expect(history.length, equals(3));
          await history.goForward();
          expect(history.length, equals(3));
          await history.goForward();
          expect(history.length, equals(3));
        });

        test('goBack', () async {
          expect(history.length, equals(1));
          await history.push('/test');
          expect(history.length, equals(2));
          await history.push('/test2');
          expect(history.length, equals(3));
          await history.goBack();
          expect(history.length, equals(3));
          await history.goBack();
          expect(history.length, equals(3));
        });
      });

      group('location correctly responds to', () {
        setUp(() {
          history = getHistory();
        });
        test('push', () async {
          expect(history.location.path, equals('/'));
          await history.push('/test');
          expect(history.location.path, equals('/test'));
          await history.push('/test2');
          expect(history.location.path, equals('/test2'));
        });

        test('replace', () async {
          expect(history.location.path, equals('/'));
          await history.replace('/test3');
          expect(history.location.path, equals('/test3'));
        });

        test('go', () async {
          expect(history.location.path, equals('/'));
          await history.push('/test');
          expect(history.location.path, equals('/test'));
          await history.push('/test2');
          expect(history.location.path, equals('/test2'));
          await history.go(-2);
          expect(history.location.path, equals('/'));
        });

        test('goForward', () async {
          expect(history.location.path, equals('/'));
          await history.push('/test');
          expect(history.location.path, equals('/test'));
          await history.push('/test2');
          expect(history.location.path, equals('/test2'));
          await history.go(-2);
          expect(history.location.path, equals('/'));
          await history.goForward();
          expect(history.location.path, equals('/test'));
          await history.goForward();
          expect(history.location.path, equals('/test2'));
          await history.goForward();
          expect(history.location.path, equals('/test2'));
        });

        test('goBack', () async {
          expect(history.location.path, equals('/'));
          await history.push('/test');
          expect(history.location.path, equals('/test'));
          await history.push('/test2');
          expect(history.location.path, equals('/test2'));
          await history.goBack();
          expect(history.location.path, equals('/test'));
          await history.goBack();
          expect(history.location.path, equals('/'));
          await history.goBack();
          expect(history.location.path, equals('/'));
        });
      });

      group('action correctly responds to', () {
        setUp(() {
          history = getHistory();
        });
        test('push', () async {
          expect(history.action, equals(Action.pop));
          await history.push('/test');
          expect(history.action, equals(Action.push));
          await history.push('/test2');
          expect(history.action, equals(Action.push));
        });

        test('replace', () async {
          expect(history.action, equals(Action.pop));
          await history.replace('/test3');
          expect(history.action, equals(Action.replace));
        });

        test('go', () async {
          expect(history.action, equals(Action.pop));
          await history.push('/test');
          expect(history.action, equals(Action.push));
          await history.push('/test2');
          expect(history.action, equals(Action.push));
          await history.go(-2);
          expect(history.action, equals(Action.pop));
        });

        test('goForward', () async {
          expect(history.action, equals(Action.pop));
          await history.push('/test');
          expect(history.action, equals(Action.push));
          await history.push('/test2');
          expect(history.action, equals(Action.push));
          await history.go(-2);
          expect(history.action, equals(Action.pop));
          await history.goForward();
          expect(history.action, equals(Action.pop));
          await history.goForward();
          expect(history.action, equals(Action.pop));
          await history.goForward();
          expect(history.action, equals(Action.pop));
        });

        test('goBack', () async {
          expect(history.action, equals(Action.pop));
          await history.push('/test');
          expect(history.action, equals(Action.push));
          await history.push('/test2');
          expect(history.action, equals(Action.push));
          await history.goBack();
          expect(history.action, equals(Action.pop));
          await history.goBack();
          expect(history.action, equals(Action.pop));
          await history.goBack();
          expect(history.action, equals(Action.pop));
        });
      });

      group('isBlocking correctly responds to', () {
        setUp(() {
          history = getHistory();
        });
        test('block', () {
          expect(history.isBlocking, isFalse);
          history.block(null);
          expect(history.isBlocking, isFalse);
          history.block((_, __) async => new Future.value('prompt'));
          expect(history.isBlocking, isTrue);
          history.block(null);
          expect(history.isBlocking, isFalse);
        });

        test('unblock', () {
          expect(history.isBlocking, isFalse);
          history.unblock();
          expect(history.isBlocking, isFalse);
          history.block((_, __) async => new Future.value('prompt'));
          expect(history.isBlocking, isTrue);
          history.unblock();
          expect(history.isBlocking, isFalse);
        });
      });

      group('onChange', () {
        group('notifies after', () {
          Completer c;

          setUp(() {
            c = new Completer();
            history = getHistory();
            sub = history.onChange.listen((h) {
              expect(h, equals(history));
              c.complete();
            });
          });

          tearDown(() {
            if (sub != null) {
              sub.cancel();
            }
            sub = null;
          });

          test('push', () async {
            history.push('/path');
            await c.future;
            expect(history.length, equals(2));
            expect(history.location.pathname, equals('/path'));
            expect(history.action, equals(Action.push));
          });

          test('replace', () async {
            history.replace('/path');
            await c.future;
            expect(history.length, equals(1));
            expect(history.location.pathname, equals('/path'));
            expect(history.action, equals(Action.replace));
          });

          test('go', () async {
            await sub.cancel();
            await history.push('/path');
            await history.push('/path2');
            sub = history.onChange.listen((h) {
              expect(h, equals(history));
              c.complete();
            });
            history.go(-2);
            await c.future;
            expect(history.length, equals(3));
            expect(history.location.pathname, equals('/'));
            expect(history.action, equals(Action.pop));
          });

          test('goForward', () async {
            await sub.cancel();
            await history.push('/path');
            await history.go(-1);
            sub = history.onChange.listen((h) {
              expect(h, equals(history));
              c.complete();
            });
            history.goForward();
            await c.future;
            expect(history.length, equals(2));
            expect(history.location.pathname, equals('/path'));
            expect(history.action, equals(Action.pop));
          });

          test('goBack', () async {
            await sub.cancel();
            await history.push('/path');
            sub = history.onChange.listen((h) {
              expect(h, equals(history));
              c.complete();
            });
            history.goBack();
            await c.future;
            expect(history.length, equals(2));
            expect(history.location.pathname, equals('/'));
            expect(history.action, equals(Action.pop));
          });
        });

        test('waits for confirmation when in blocking mode', () async {
          var c = new Completer();
          var confirmed = new Completer();
          Confirmation confirm = (String _) async {
            confirmed.complete();
            expect(c.isCompleted, isFalse);
            return new Future.value(true);
          };
          history = getHistory(confirmation: confirm);
          sub = history.onChange.listen((_) {
            c.complete();
          });
          history.block('prompt');
          history.push('/path');
          await confirmed.future;
          expect(c.isCompleted, isFalse);
          await c.future;
        });
      });

      group('push', () {
        Completer c;
        Confirmation confirm;

        setUp(() {
          c = new Completer();
          confirm = (String _) async {
            c.complete();
            return new Future.value(true);
          };
        });

        test('works when using a String', () async {
          history = getHistory();
          expect(history.length, equals(1));
          expect(history.location.pathname, equals('/'));
          await history.push('/path');
          expect(history.length, equals(2));
          expect(history.location.pathname, equals('/path'));
        });

        test('works when using a Location', () async {
          history = getHistory();
          expect(history.length, equals(1));
          expect(history.location.pathname, equals('/'));
          var next = new Location(pathname: '/path', key: 'key');
          await history.push(next);
          expect(history.length, equals(2));
          expect(history.location, isNot(equals(next)));
          expect(history.location.key, isNot(equals(next.key)));
          expect(history.location.pathname, equals(next.pathname));
        });

        test('waits for confirmation when in blocking mode', () async {
          history = getHistory(confirmation: confirm);
          await history.push('/path');
          expect(c.isCompleted, isFalse);

          history.block('prompt');
          await history.push('/path2');
          expect(c.isCompleted, isTrue);

          history.unblock();
          c = new Completer();
          await history.push('/path3');
          expect(c.isCompleted, isFalse);
        });

        test('does nothing when transition is denied', () async {
          confirm = (String _) async {
            c.complete();
            return new Future.value(false);
          };
          history = getHistory(confirmation: confirm);
          history.block('prompt');
          await history.push('/path');
          expect(c.isCompleted, isTrue);
          expect(history.length, equals(1));
          expect(history.location.pathname, isNot(equals('/path')));
        });

        test('state is added when provided', () async {
          history = getHistory();
          var stateMatcher = supportsState ? equals('state') : isNull;
          await history.push('/path', 'state');
          expect(history.location.state, stateMatcher);
          await history.push('/path2');
          expect(history.location.state, isNull);
        });

        test(
            'uses Location.state when state is both provided in Location and by parameter',
            () async {
          history = getHistory();
          var next = new Location(pathname: '/path', state: 'locationstate');
          await history.push(next, 'parameterstate');
          var stateMatcher = supportsState ? equals('locationstate') : isNull;
          expect(history.location.state, stateMatcher);
        });
      });

      group('replace', () {
        test('works when using a String', () async {
          history = getHistory();
          expect(history.length, equals(1));
          expect(history.location.pathname, equals('/'));
          await history.replace('/path');
          expect(history.length, equals(1));
          expect(history.location.pathname, equals('/path'));
        });

        test('works when using a Location', () async {
          history = getHistory();
          expect(history.length, equals(1));
          expect(history.location.pathname, equals('/'));
          var next = new Location(pathname: '/path', key: 'key');
          await history.replace(next);
          expect(history.length, equals(1));
          expect(history.location, isNot(equals(next)));
          expect(history.location.key, isNot(equals(next.key)));
          expect(history.location.pathname, equals(next.pathname));
        });

        test('waits for confirmation when in blocking mode', () async {
          var c = new Completer();
          Confirmation confirm = (String _) async {
            c.complete();
            return new Future.value(true);
          };
          history = getHistory(confirmation: confirm);
          await history.replace('/path');
          expect(c.isCompleted, isFalse);

          history.block('prompt');
          await history.replace('/path2');
          expect(c.isCompleted, isTrue);

          history.unblock();
          c = new Completer();
          await history.replace('/path3');
          expect(c.isCompleted, isFalse);
        });

        test('does nothing when transition is denied', () async {
          var c = new Completer();
          Confirmation confirm = (String _) async {
            if (!c.isCompleted) {
              c.complete();
            }
            return new Future.value(false);
          };
          history = getHistory(confirmation: confirm);
          history.block('prompt');
          await history.replace('/path');
          expect(c.isCompleted, isTrue);
          expect(history.length, equals(1));
          expect(history.location.pathname, isNot(equals('/path')));
        });

        test('state is added when provided', () async {
          history = getHistory();
          var stateMatcher = supportsState ? equals('state') : isNull;
          await history.replace('/path', 'state');
          expect(history.location.state, stateMatcher);
          await history.replace('/path2');
          expect(history.location.state, isNull);
        });

        test(
            'uses Location.state when state is both provided in Location and by parameter',
            () async {
          history = getHistory();
          var next = new Location(pathname: '/path', state: 'locationstate');
          await history.replace(next, 'parameterstate');
          var stateMatcher = supportsState ? equals('locationstate') : isNull;
          expect(history.location.state, stateMatcher);
        });
      });

      group('go', () {
        test('works with 0', () async {
          history = getHistory();
          expect(history.length, equals(1));
          expect(history.location.pathname, equals('/'));
          await history.go(0);
          expect(history.length, equals(1));
          expect(history.location.pathname, equals('/'));
        });

        test('works with negative deltas', () async {
          history = getHistory();
          await history.push('/path');
          await history.push('/path2');
          expect(history.length, equals(3));
          expect(history.location.pathname, equals('/path2'));
          await history.go(-2);
          expect(history.length, equals(3));
          expect(history.location.pathname, equals('/'));
        });

        test('works with positive deltas', () async {
          history = getHistory();
          await history.push('/path');
          await history.push('/path2');
          expect(history.length, equals(3));
          expect(history.location.pathname, equals('/path2'));
          await history.go(-2);
          expect(history.length, equals(3));
          expect(history.location.pathname, equals('/'));
          await history.go(2);
          expect(history.length, equals(3));
          expect(history.location.pathname, equals('/path2'));
        });

        test('waits for confirmation when in blocking mode', () async {
          var c = new Completer();
          Confirmation confirm = (String _) async {
            c.complete();
            return new Future.value(true);
          };
          history = getHistory(confirmation: confirm);
          await history.push('/path');
          await history.push('/path2');
          await history.push('/path3');
          await history.go(-3);
          expect(c.isCompleted, isFalse);

          c = new Completer();
          history.block('prompt');
          await history.go(2);
          await c.future;
          expect(c.isCompleted, isTrue);

          history.unblock();
          c = new Completer();
          await history.go(-1);
          expect(c.isCompleted, isFalse);
        });

        test('still emits a change when transition is denied', () async {
          var c = new Completer();
          var c2 = new Completer();
          Confirmation confirm = (String _) async {
            c.complete();
            return new Future.value(false);
          };
          history = getHistory(confirmation: confirm);
          await history.push('/path');
          await history.push('/path2');
          history.block('prompt');
          expect(history.location.pathname, equals('/path2'));
          sub = history.onChange.listen((_) {
            c2.complete();
          });
          history.go(-2);
          await c2.future;
          expect(c.isCompleted, isTrue);
          expect(history.location.pathname, equals('/path2'));
          await sub.cancel();
        });
      });

      group('goForward', () {
        Completer c;
        Confirmation confirm;
        setUp(() {
          c = new Completer();
          confirm = (String _) async {
            c.complete();
            return new Future.value(true);
          };
        });
        test('waits for confirmation when in blocking mode', () async {
          history = getHistory(confirmation: confirm);
          await history.push('/path');
          await history.push('/path2');
          await history.push('/path3');
          await history.go(-3);
          await history.goForward();
          expect(history.location.pathname, equals('/path'));
          expect(c.isCompleted, isFalse);

          history.block('prompt');
          await history.goForward();
          await c.future;
          expect(history.location.pathname, equals('/path2'));
          expect(c.isCompleted, isTrue);

          history.unblock();
          c = new Completer();
          await history.goForward();
          expect(history.location.pathname, equals('/path3'));
          expect(c.isCompleted, isFalse);
        });

        test('still emits a change when transition is denied', () async {
          var c2 = new Completer();
          confirm = (String _) async {
            c.complete();
            return new Future.value(false);
          };
          history = getHistory(confirmation: confirm);
          await history.push('/path');
          await history.go(-1);
          history.block('prompt');
          expect(history.location.pathname, equals('/'));
          sub = history.onChange.listen((_) {
            c2.complete();
          });
          history.goForward();
          await c2.future;
          expect(c.isCompleted, isTrue);
          expect(history.location.pathname, equals('/'));
          await sub.cancel();
        });

        test('still emits a change when triggered at the end of history',
            () async {
          var c2 = new Completer();
          history = getHistory(confirmation: confirm);
          await history.push('/path');
          history.block('prompt');
          expect(history.location.pathname, equals('/path'));
          sub = history.onChange.listen((_) {
            c2.complete();
          });
          history.goForward();
          await c2.future;
          expect(c.isCompleted, isTrue);
          expect(history.location.pathname, equals('/path'));
          await sub.cancel();
        });
      });

      group('goBack', () {
        Completer c;
        Confirmation confirm;

        setUp(() {
          c = new Completer();
          confirm = (String _) async {
            c.complete();
            return new Future.value(true);
          };
        });

        test('waits for confirmation when in blocking mode', () async {
          history = getHistory(confirmation: confirm);
          await history.push('/path');
          await history.push('/path2');
          await history.push('/path3');
          await history.goBack();
          expect(history.location.pathname, equals('/path2'));
          expect(c.isCompleted, isFalse);

          history.block('prompt');
          await history.goBack();
          expect(history.location.pathname, equals('/path'));
          expect(c.isCompleted, isTrue);

          history.unblock();
          c = new Completer();
          await history.goBack();
          expect(history.location.pathname, equals('/'));
          expect(c.isCompleted, isFalse);
        });

        test('still emits a change when transition is denied', () async {
          var c2 = new Completer();
          confirm = (String _) async {
            c.complete();
            return new Future.value(false);
          };
          history = getHistory(confirmation: confirm);
          await history.push('/path');
          history.block('prompt');
          expect(history.location.pathname, equals('/path'));
          sub = history.onChange.listen((_) {
            c2.complete();
          });
          history.goBack();
          await c2.future;
          expect(c.isCompleted, isTrue);
          expect(history.location.pathname, equals('/path'));
          await sub.cancel();
        });

        test('still emits a change when triggered at the start of history',
            () async {
          var c2 = new Completer();
          history = getHistory(confirmation: confirm);
          await history.push('/path');
          await history.goBack();
          history.block('prompt');
          expect(history.location.pathname, equals('/'));
          sub = history.onChange.listen((_) {
            c2.complete();
          });
          history.goBack();
          await c2.future;
          expect(c.isCompleted, isTrue);
          expect(history.location.pathname, equals('/'));
          await sub.cancel();
        });
      });

      group('block', () {
        test('sets isBlocking correctly', () {
          history = getHistory();
          expect(history.isBlocking, isFalse);
          history.block('test');
          expect(history.isBlocking, isTrue);
        });

        test('resets isBlocking when set to null', () {
          history = getHistory();
          expect(history.isBlocking, isFalse);
          history.block('test');
          expect(history.isBlocking, isTrue);
          history.block(null);
          expect(history.isBlocking, isFalse);
        });

        group('forces prompt to be triggered on transitions', () {
          Completer c;
          Prompt check;

          setUp(() {
            history = getHistory();
            c = new Completer();
            check = (Location _, Action __) async {
              c.complete();
              return new Future.value('prompt');
            };
          });

          test('push', () async {
            await history.push('/test');
            expect(c.isCompleted, isFalse);

            history.block(check);
            await history.push('/test');
            expect(c.isCompleted, isTrue);
          });

          test('replace', () async {
            await history.replace('/test');
            expect(c.isCompleted, isFalse);

            history.block(check);
            await history.replace('/test');
            expect(c.isCompleted, isTrue);
          });

          test('go', () async {
            await history.push('/test');
            await history.go(-1);
            expect(c.isCompleted, isFalse);

            history.block(check);
            await history.go(1);
            expect(c.isCompleted, isTrue);
          });

          test('goForward', () async {
            await history.push('/test');
            await history.go(-1);
            await history.goForward();
            expect(c.isCompleted, isFalse);

            history.block(check);
            await history.go(-1);
            c = new Completer();
            await history.goForward();
            expect(c.isCompleted, isTrue);
          });

          test('goBack', () async {
            await history.push('/test');
            await history.goBack();
            expect(c.isCompleted, isFalse);

            history.block(check);
            await history.go(1);
            c = new Completer();
            await history.goBack();
            expect(c.isCompleted, isTrue);
          });
        });
      });

      group('unblock', () {
        test('has no action when already non-blocking', () {
          history = getHistory();
          expect(history.isBlocking, isFalse);
          history.unblock();
          expect(history.isBlocking, isFalse);
        });

        test('resets isBlocking', () {
          history = getHistory();
          expect(history.isBlocking, isFalse);
          history.block('test');
          expect(history.isBlocking, isTrue);
          history.unblock();
          expect(history.isBlocking, isFalse);
        });

        group('removes prompt from being triggered on', () {
          Completer c;
          Prompt check;

          setUp(() {
            history = getHistory();
            check = (Location _, Action __) async {
              c.complete();
              return new Future.value('prompt');
            };
            c = new Completer();
            history.block(check);
          });

          test('push', () async {
            await history.push('/test');
            await c.future;
            expect(c.isCompleted, isTrue);

            c = new Completer();
            history.unblock();
            await history.push('/test');
            expect(c.isCompleted, isFalse);
          });

          test('replace', () async {
            await history.replace('/test');
            await c.future;
            expect(c.isCompleted, isTrue);

            c = new Completer();
            history.unblock();
            await history.replace('/test');
            expect(c.isCompleted, isFalse);
          });

          test('go', () async {
            await history.push('/test');
            c = new Completer();
            await history.go(-1);
            await c.future;
            expect(c.isCompleted, isTrue);

            c = new Completer();
            history.unblock();
            await history.go(1);
            expect(c.isCompleted, isFalse);
          });

          test('goForward', () async {
            await history.push('/test');
            c = new Completer();
            await history.go(-1);
            c = new Completer();
            await history.goForward();
            await c.future;
            expect(c.isCompleted, isTrue);

            c = new Completer();
            history.unblock();
            await history.go(-1);
            await history.goForward();
            expect(c.isCompleted, isFalse);
          });

          test('goBack', () async {
            await history.push('/test');
            c = new Completer();
            await history.goBack();
            await c.future;
            expect(c.isCompleted, isTrue);

            c = new Completer();
            history.unblock();
            await history.go(1);
            await history.goBack();
            expect(c.isCompleted, isFalse);
          });
        });
      });
    };
