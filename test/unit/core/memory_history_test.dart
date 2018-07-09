@TestOn('browser || vm')
import 'dart:async';

import 'package:test/test.dart';

import 'package:history/src/core/location.dart';
import 'package:history/src/core/memory_history.dart';
import 'package:history/src/utils/utils.dart' show Action, Confirmation, Prompt;

import 'mocks.dart' show MockLocation;

void main() {
  group('MemoryHistory', () {
    group('constructor', () {
      test('constructs with no parameters', () {
        MemoryHistory mh = new MemoryHistory();
        expect(mh.index, equals(0));
        expect(mh.entries.isNotEmpty, isTrue);
        expect(mh.length, equals(1));
        expect(mh.action, equals(Action.pop));
        expect(mh.location, isNotNull);
        expect(mh.location.path, equals('/'));
        expect(mh.isBlocking, isFalse);
        expect(mh.onChange, isNotNull);
      });

      test('constructs with initial enties', () {
        var initialEntries = ['/test', new MockLocation(), new Object()];
        MemoryHistory mh = new MemoryHistory(initialEntries: initialEntries);
        expect(mh.index, equals(0));
        expect(mh.entries.isNotEmpty, isTrue);
        expect(mh.length, equals(2));
        expect(mh.action, equals(Action.pop));
        expect(mh.location, isNotNull);
        expect(mh.location.path, equals('/test'));
        expect(mh.isBlocking, isFalse);
        expect(mh.onChange, isNotNull);
      });

      test('constructs with initial index', () {
        var initialEntries = ['/', '/test'];
        MemoryHistory mh =
            new MemoryHistory(initialEntries: initialEntries, initialIndex: 1);
        expect(mh.index, equals(1));
        expect(mh.entries.isNotEmpty, isTrue);
        expect(mh.length, equals(2));
        expect(mh.action, equals(Action.pop));
        expect(mh.location, isNotNull);
        expect(mh.location.path, equals('/test'));
        expect(mh.isBlocking, isFalse);
        expect(mh.onChange, isNotNull);

        mh = new MemoryHistory(initialEntries: initialEntries, initialIndex: 2);
        expect(mh.index, equals(1));
        expect(mh.entries.isNotEmpty, isTrue);
        expect(mh.length, equals(2));
        expect(mh.action, equals(Action.pop));
        expect(mh.location, isNotNull);
        expect(mh.location.path, equals('/test'));
        expect(mh.location.key.length, equals(6));
        expect(mh.isBlocking, isFalse);
        expect(mh.onChange, isNotNull);

        mh = new MemoryHistory(initialEntries: initialEntries, initialIndex: 0);
        expect(mh.index, equals(0));
        expect(mh.entries.isNotEmpty, isTrue);
        expect(mh.length, equals(2));
        expect(mh.action, equals(Action.pop));
        expect(mh.location, isNotNull);
        expect(mh.location.path, equals('/'));
        expect(mh.location.key.length, equals(6));
        expect(mh.isBlocking, isFalse);
        expect(mh.onChange, isNotNull);
      });

      test('constructs with key length', () {
        MemoryHistory mh = new MemoryHistory(keyLength: 12);
        expect(mh.index, equals(0));
        expect(mh.entries.isNotEmpty, isTrue);
        expect(mh.length, equals(1));
        expect(mh.action, equals(Action.pop));
        expect(mh.location, isNotNull);
        expect(mh.location.path, equals('/'));
        expect(mh.location.key.length, equals(12));
        expect(mh.isBlocking, isFalse);
        expect(mh.onChange, isNotNull);
      });

      test('constructs with confirmation', () async {
        Completer c = new Completer();
        Confirmation confirm = (_) async {
          c.complete();
          return new Future.value(true);
        };
        MemoryHistory mh = new MemoryHistory(getConfirmation: confirm);
        mh.block('temp');
        mh.push('/test');
        await c.future;
      });
    });

    group('core:', () {
      MemoryHistory mh;

      setUp(() {
        mh = new MemoryHistory();
      });

      group('length correctly responds to', () {
        test('push', () async {
          expect(mh.length, equals(1));
          await mh.push('/test');
          expect(mh.length, equals(2));
          await mh.push('/test2');
          expect(mh.length, equals(3));
        });

        test('replace', () async {
          expect(mh.length, equals(1));
          await mh.replace('/test');
          expect(mh.length, equals(1));
          await mh.push('/test2');
          expect(mh.length, equals(2));
          await mh.replace('/test3');
          expect(mh.length, equals(2));
        });

        test('go', () async {
          expect(mh.length, equals(1));
          await mh.push('/test');
          expect(mh.length, equals(2));
          await mh.push('/test2');
          expect(mh.length, equals(3));
          await mh.go(-2);
          expect(mh.length, equals(3));
          await mh.go(2);
          expect(mh.length, equals(3));
          await mh.go(-1);
          expect(mh.length, equals(3));
          await mh.go(1);
          expect(mh.length, equals(3));
          await mh.go(0);
          expect(mh.length, equals(3));
        });

        test('goForward', () async {
          expect(mh.length, equals(1));
          await mh.push('/test');
          expect(mh.length, equals(2));
          await mh.push('/test2');
          expect(mh.length, equals(3));
          await mh.go(-2);
          expect(mh.length, equals(3));
          await mh.goForward();
          expect(mh.length, equals(3));
          await mh.goForward();
          expect(mh.length, equals(3));
        });

        test('goBack', () async {
          expect(mh.length, equals(1));
          await mh.push('/test');
          expect(mh.length, equals(2));
          await mh.push('/test2');
          expect(mh.length, equals(3));
          await mh.goBack();
          expect(mh.length, equals(3));
          await mh.goBack();
          expect(mh.length, equals(3));
        });
      });

      group('location correctly responds to', () {
        test('push', () async {
          expect(mh.location.path, equals('/'));
          await mh.push('/test');
          expect(mh.location.path, equals('/test'));
          await mh.push('/test2');
          expect(mh.location.path, equals('/test2'));
        });

        test('replace', () async {
          expect(mh.location.path, equals('/'));
          await mh.replace('/test3');
          expect(mh.location.path, equals('/test3'));
        });

        test('go', () async {
          expect(mh.location.path, equals('/'));
          await mh.push('/test');
          expect(mh.location.path, equals('/test'));
          await mh.push('/test2');
          expect(mh.location.path, equals('/test2'));
          await mh.go(-2);
          expect(mh.location.path, equals('/'));
        });

        test('goForward', () async {
          expect(mh.location.path, equals('/'));
          await mh.push('/test');
          expect(mh.location.path, equals('/test'));
          await mh.push('/test2');
          expect(mh.location.path, equals('/test2'));
          await mh.go(-2);
          expect(mh.location.path, equals('/'));
          await mh.goForward();
          expect(mh.location.path, equals('/test'));
          await mh.goForward();
          expect(mh.location.path, equals('/test2'));
          await mh.goForward();
          expect(mh.location.path, equals('/test2'));
        });

        test('goBack', () async {
          expect(mh.location.path, equals('/'));
          await mh.push('/test');
          expect(mh.location.path, equals('/test'));
          await mh.push('/test2');
          expect(mh.location.path, equals('/test2'));
          await mh.goBack();
          expect(mh.location.path, equals('/test'));
          await mh.goBack();
          expect(mh.location.path, equals('/'));
          await mh.goBack();
          expect(mh.location.path, equals('/'));
        });
      });

      group('action correctly responds to', () {
        test('push', () async {
          expect(mh.action, equals(Action.pop));
          await mh.push('/test');
          expect(mh.action, equals(Action.push));
          await mh.push('/test2');
          expect(mh.action, equals(Action.push));
        });

        test('replace', () async {
          expect(mh.action, equals(Action.pop));
          await mh.replace('/test3');
          expect(mh.action, equals(Action.replace));
        });

        test('go', () async {
          expect(mh.action, equals(Action.pop));
          await mh.push('/test');
          expect(mh.action, equals(Action.push));
          await mh.push('/test2');
          expect(mh.action, equals(Action.push));
          await mh.go(-2);
          expect(mh.action, equals(Action.pop));
        });

        test('goForward', () async {
          expect(mh.action, equals(Action.pop));
          await mh.push('/test');
          expect(mh.action, equals(Action.push));
          await mh.push('/test2');
          expect(mh.action, equals(Action.push));
          await mh.go(-2);
          expect(mh.action, equals(Action.pop));
          await mh.goForward();
          expect(mh.action, equals(Action.pop));
          await mh.goForward();
          expect(mh.action, equals(Action.pop));
          await mh.goForward();
          expect(mh.action, equals(Action.pop));
        });

        test('goBack', () async {
          expect(mh.action, equals(Action.pop));
          await mh.push('/test');
          expect(mh.action, equals(Action.push));
          await mh.push('/test2');
          expect(mh.action, equals(Action.push));
          await mh.goBack();
          expect(mh.action, equals(Action.pop));
          await mh.goBack();
          expect(mh.action, equals(Action.pop));
          await mh.goBack();
          expect(mh.action, equals(Action.pop));
        });
      });

      group('isBlocking correctly responds to', () {
        test('block', () {
          expect(mh.isBlocking, isFalse);
          mh.block(null);
          expect(mh.isBlocking, isFalse);
          mh.block((_, __) async => new Future.value('prompt'));
          expect(mh.isBlocking, isTrue);
          mh.block(null);
          expect(mh.isBlocking, isFalse);
        });

        test('unblock', () {
          expect(mh.isBlocking, isFalse);
          mh.unblock();
          expect(mh.isBlocking, isFalse);
          mh.block((_, __) async => new Future.value('prompt'));
          expect(mh.isBlocking, isTrue);
          mh.unblock();
          expect(mh.isBlocking, isFalse);
        });
      });

      group('onChange', () {
        group('notifies after', () {
          StreamSubscription sub;
          Completer c;

          setUp(() {
            c = new Completer();
            sub = mh.onChange.listen((h) {
              expect(h, equals(mh));
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
            mh.push('/path');
            await c.future;
            expect(mh.length, equals(2));
            expect(mh.location.pathname, equals('/path'));
            expect(mh.action, equals(Action.push));
          });

          test('replace', () async {
            mh.replace('/path');
            await c.future;
            expect(mh.length, equals(1));
            expect(mh.location.pathname, equals('/path'));
            expect(mh.action, equals(Action.replace));
          });

          test('go', () async {
            sub.cancel();
            await mh.push('/path');
            await mh.push('/path2');
            sub = mh.onChange.listen((h) {
              expect(h, equals(mh));
              c.complete();
            });
            mh.go(-2);
            await c.future;
            expect(mh.length, equals(3));
            expect(mh.location.pathname, equals('/'));
            expect(mh.action, equals(Action.pop));
          });

          test('goForward', () async {
            sub.cancel();
            await mh.push('/path');
            await mh.go(-1);
            sub = mh.onChange.listen((h) {
              expect(h, equals(mh));
              c.complete();
            });
            mh.goForward();
            await c.future;
            expect(mh.length, equals(2));
            expect(mh.location.pathname, equals('/path'));
            expect(mh.action, equals(Action.pop));
          });

          test('goBack', () async {
            sub.cancel();
            await mh.push('/path');
            sub = mh.onChange.listen((h) {
              expect(h, equals(mh));
              c.complete();
            });
            mh.goBack();
            await c.future;
            expect(mh.length, equals(2));
            expect(mh.location.pathname, equals('/'));
            expect(mh.action, equals(Action.pop));
          });
        });

        test('waits for confirmation when in blocking mode', () async {
          Completer c = new Completer();
          Completer confirmed = new Completer();
          Confirmation confirm = (_) async {
            confirmed.complete();
            expect(c.isCompleted, isFalse);
            return new Future.value(true);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          StreamSubscription sub = mh.onChange.listen((_) {
            c.complete();
          });
          mh.block('prompt');
          mh.push('/path');
          await confirmed.future;
          expect(c.isCompleted, isFalse);
          await c.future;
          sub.cancel();
        });
      });

      group('push', () {
        test('works when using a String', () async {
          expect(mh.length, equals(1));
          expect(mh.location.pathname, equals('/'));
          await mh.push('/path');
          expect(mh.length, equals(2));
          expect(mh.location.pathname, equals('/path'));
        });

        test('works when using a Location', () async {
          expect(mh.length, equals(1));
          expect(mh.location.pathname, equals('/'));
          Location next = new Location(pathname: '/path', key: 'key');
          await mh.push(next);
          expect(mh.length, equals(2));
          expect(mh.location, isNot(equals(next)));
          expect(mh.location.key, isNot(equals(next.key)));
          expect(mh.location.pathname, equals(next.pathname));
        });

        test('waits for confirmation when in blocking mode', () async {
          Completer c = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(true);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          await mh.push('/path');
          expect(c.isCompleted, isFalse);

          mh.block('prompt');
          await mh.push('/path2');
          expect(c.isCompleted, isTrue);

          mh.unblock();
          c = new Completer();
          await mh.push('/path3');
          expect(c.isCompleted, isFalse);
        });

        test('does nothing when transition is denied', () async {
          Completer c = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(false);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          mh.block('prompt');
          await mh.push('/path');
          expect(c.isCompleted, isTrue);
          expect(mh.length, equals(1));
          expect(mh.location.pathname, isNot(equals('/path')));
        });

        test('state is added when provided', () async {
          await mh.push('/path', 'state');
          expect(mh.location.state, equals('state'));
          await mh.push('/path2');
          expect(mh.location.state, isNull);
        });

        test(
            'uses Location.state when state is both provided in Location and by parameter',
            () async {
          Location next =
              new Location(pathname: '/path', state: 'locationstate');
          await mh.push(next, 'parameterstate');
          expect(mh.location.state, equals('locationstate'));
        });
      });

      group('replace', () {
        test('works when using a String', () async {
          expect(mh.length, equals(1));
          expect(mh.location.pathname, equals('/'));
          await mh.replace('/path');
          expect(mh.length, equals(1));
          expect(mh.location.pathname, equals('/path'));
        });

        test('works when using a Location', () async {
          expect(mh.length, equals(1));
          expect(mh.location.pathname, equals('/'));
          Location next = new Location(pathname: '/path', key: 'key');
          await mh.replace(next);
          expect(mh.length, equals(1));
          expect(mh.location, isNot(equals(next)));
          expect(mh.location.key, isNot(equals(next.key)));
          expect(mh.location.pathname, equals(next.pathname));
        });

        test('waits for confirmation when in blocking mode', () async {
          Completer c = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(true);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          await mh.replace('/path');
          expect(c.isCompleted, isFalse);

          mh.block('prompt');
          await mh.replace('/path2');
          expect(c.isCompleted, isTrue);

          mh.unblock();
          c = new Completer();
          await mh.replace('/path3');
          expect(c.isCompleted, isFalse);
        });

        test('does nothing when transition is denied', () async {
          Completer c = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(false);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          mh.block('prompt');
          await mh.replace('/path');
          expect(c.isCompleted, isTrue);
          expect(mh.length, equals(1));
          expect(mh.location.pathname, isNot(equals('/path')));
        });

        test('state is added when provided', () async {
          await mh.replace('/path', 'state');
          expect(mh.location.state, equals('state'));
          await mh.replace('/path2');
          expect(mh.location.state, isNull);
        });

        test(
            'uses Location.state when state is both provided in Location and by parameter',
            () async {
          Location next =
              new Location(pathname: '/path', state: 'locationstate');
          await mh.replace(next, 'parameterstate');
          expect(mh.location.state, equals('locationstate'));
        });
      });

      group('go', () {
        test('works with 0', () async {
          expect(mh.length, equals(1));
          expect(mh.index, equals(0));
          await mh.go(0);
          expect(mh.length, equals(1));
          expect(mh.index, equals(0));
        });

        test('works with negative deltas', () async {
          await mh.push('/path');
          await mh.push('/path2');
          expect(mh.length, equals(3));
          expect(mh.index, equals(2));
          await mh.go(-2);
          expect(mh.length, equals(3));
          expect(mh.index, equals(0));
        });

        test('works with positive deltas', () async {
          await mh.push('/path');
          await mh.push('/path2');
          expect(mh.length, equals(3));
          expect(mh.index, equals(2));
          await mh.go(-2);
          expect(mh.length, equals(3));
          expect(mh.index, equals(0));
          await mh.go(2);
          expect(mh.length, equals(3));
          expect(mh.index, equals(2));
        });

        test('waits for confirmation when in blocking mode', () async {
          Completer c = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(true);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          await mh.push('/path');
          await mh.push('/path2');
          await mh.push('/path3');
          await mh.go(-3);
          expect(c.isCompleted, isFalse);

          mh.block('prompt');
          await mh.go(2);
          expect(c.isCompleted, isTrue);

          mh.unblock();
          c = new Completer();
          await mh.go(-1);
          expect(c.isCompleted, isFalse);
        });

        test('still emits a change when transition is denied', () async {
          Completer c = new Completer();
          Completer c2 = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(false);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          await mh.push('/path');
          await mh.push('/path2');
          mh.block('prompt');
          expect(mh.index, equals(2));
          StreamSubscription sub = mh.onChange.listen((_) {
            c2.complete();
          });
          mh.go(-2);
          await c2.future;
          expect(c.isCompleted, isTrue);
          expect(mh.index, equals(2));
          expect(mh.location.pathname, equals('/path2'));
          sub.cancel();
        });
      });

      group('goForward', () {
        test('waits for confirmation when in blocking mode', () async {
          Completer c = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(true);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          await mh.push('/path');
          await mh.push('/path2');
          await mh.push('/path3');
          await mh.go(-3);
          await mh.goForward();
          expect(mh.index, equals(1));
          expect(c.isCompleted, isFalse);

          mh.block('prompt');
          await mh.goForward();
          expect(mh.index, equals(2));
          expect(c.isCompleted, isTrue);

          mh.unblock();
          c = new Completer();
          await mh.goForward();
          expect(mh.index, equals(3));
          expect(c.isCompleted, isFalse);
        });

        test('still emits a change when transition is denied', () async {
          Completer c = new Completer();
          Completer c2 = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(false);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          await mh.push('/path');
          await mh.go(-1);
          mh.block('prompt');
          expect(mh.index, equals(0));
          StreamSubscription sub = mh.onChange.listen((_) {
            c2.complete();
          });
          mh.goForward();
          await c2.future;
          expect(c.isCompleted, isTrue);
          expect(mh.index, equals(0));
          expect(mh.location.pathname, equals('/'));
          sub.cancel();
        });

        test('still emits a change when triggered at the end of history',
            () async {
          Completer c = new Completer();
          Completer c2 = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(true);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          await mh.push('/path');
          mh.block('prompt');
          expect(mh.index, equals(1));
          StreamSubscription sub = mh.onChange.listen((_) {
            c2.complete();
          });
          mh.goForward();
          await c2.future;
          expect(c.isCompleted, isTrue);
          expect(mh.index, equals(1));
          expect(mh.location.pathname, equals('/path'));
          sub.cancel();
        });
      });

      group('goBack', () {
        test('waits for confirmation when in blocking mode', () async {
          Completer c = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(true);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          await mh.push('/path');
          await mh.push('/path2');
          await mh.push('/path3');
          await mh.goBack();
          expect(mh.index, equals(2));
          expect(c.isCompleted, isFalse);

          mh.block('prompt');
          await mh.goBack();
          expect(mh.index, equals(1));
          expect(c.isCompleted, isTrue);

          mh.unblock();
          c = new Completer();
          await mh.goBack();
          expect(mh.index, equals(0));
          expect(c.isCompleted, isFalse);
        });

        test('still emits a change when transition is denied', () async {
          Completer c = new Completer();
          Completer c2 = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(false);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          await mh.push('/path');
          mh.block('prompt');
          expect(mh.index, equals(1));
          StreamSubscription sub = mh.onChange.listen((_) {
            c2.complete();
          });
          mh.goBack();
          await c2.future;
          expect(c.isCompleted, isTrue);
          expect(mh.index, equals(1));
          expect(mh.location.pathname, equals('/path'));
          sub.cancel();
        });

        test('still emits a change when triggered at the start of history',
            () async {
          Completer c = new Completer();
          Completer c2 = new Completer();
          Confirmation confirm = (_) async {
            c.complete();
            return new Future.value(true);
          };
          mh = new MemoryHistory(getConfirmation: confirm);
          await mh.push('/path');
          await mh.goBack();
          mh.block('prompt');
          expect(mh.index, equals(0));
          StreamSubscription sub = mh.onChange.listen((_) {
            c2.complete();
          });
          mh.goBack();
          await c2.future;
          expect(c.isCompleted, isTrue);
          expect(mh.index, equals(0));
          expect(mh.location.pathname, equals('/'));
          sub.cancel();
        });
      });

      group('block', () {
        test('sets isBlocking correctly', () {
          expect(mh.isBlocking, isFalse);
          mh.block('test');
          expect(mh.isBlocking, isTrue);
        });

        test('resets isBlocking when set to null', () {
          expect(mh.isBlocking, isFalse);
          mh.block('test');
          expect(mh.isBlocking, isTrue);
          mh.block(null);
          expect(mh.isBlocking, isFalse);
        });

        group('forces prompt to be triggered on transitions', () {
          Completer c;
          Prompt check;

          setUp(() {
            check = (_, __) async {
              c.complete();
              return new Future.value('prompt');
            };
            c = new Completer();
          });

          test('push', () async {
            await mh.push('/test');
            expect(c.isCompleted, isFalse);

            mh.block(check);
            await mh.push('/test');
            expect(c.isCompleted, isTrue);
          });

          test('replace', () async {
            await mh.replace('/test');
            expect(c.isCompleted, isFalse);

            mh.block(check);
            await mh.replace('/test');
            expect(c.isCompleted, isTrue);
          });

          test('go', () async {
            await mh.push('/test');
            await mh.go(-1);
            expect(c.isCompleted, isFalse);

            mh.block(check);
            await mh.go(1);
            expect(c.isCompleted, isTrue);
          });

          test('goForward', () async {
            await mh.push('/test');
            await mh.go(-1);
            await mh.goForward();
            expect(c.isCompleted, isFalse);

            mh.block(check);
            await mh.go(-1);
            c = new Completer();
            await mh.goForward();
            expect(c.isCompleted, isTrue);
          });

          test('goBack', () async {
            await mh.push('/test');
            await mh.goBack();
            expect(c.isCompleted, isFalse);

            mh.block(check);
            await mh.go(1);
            c = new Completer();
            await mh.goBack();
            expect(c.isCompleted, isTrue);
          });
        });
      });

      group('unblock', () {
        test('has no action when already non-blocking', () {
          expect(mh.isBlocking, isFalse);
          mh.unblock();
          expect(mh.isBlocking, isFalse);
        });

        test('resets isBlocking', () {
          expect(mh.isBlocking, isFalse);
          mh.block('test');
          expect(mh.isBlocking, isTrue);
          mh.unblock();
          expect(mh.isBlocking, isFalse);
        });

        group('removes prompt from being triggered on', () {
          Completer c;
          Prompt check;

          setUp(() {
            check = (_, __) async {
              c.complete();
              return new Future.value('prompt');
            };
            c = new Completer();
            mh.block(check);
          });

          test('push', () async {
            await mh.push('/test');
            expect(c.isCompleted, isTrue);

            c = new Completer();
            mh.unblock();
            await mh.push('/test');
            expect(c.isCompleted, isFalse);
          });

          test('replace', () async {
            await mh.replace('/test');
            expect(c.isCompleted, isTrue);

            c = new Completer();
            mh.unblock();
            await mh.replace('/test');
            expect(c.isCompleted, isFalse);
          });

          test('go', () async {
            await mh.push('/test');
            c = new Completer();
            await mh.go(-1);
            expect(c.isCompleted, isTrue);

            c = new Completer();
            mh.unblock();
            await mh.go(1);
            expect(c.isCompleted, isFalse);
          });

          test('goForward', () async {
            await mh.push('/test');
            c = new Completer();
            await mh.go(-1);
            c = new Completer();
            await mh.goForward();
            expect(c.isCompleted, isTrue);

            c = new Completer();
            mh.unblock();
            await mh.go(-1);
            await mh.goForward();
            expect(c.isCompleted, isFalse);
          });

          test('goBack', () async {
            await mh.push('/test');
            c = new Completer();
            await mh.goBack();
            expect(c.isCompleted, isTrue);

            c = new Completer();
            mh.unblock();
            await mh.go(1);
            await mh.goBack();
            expect(c.isCompleted, isFalse);
          });
        });
      });
    });

    group('MemoryMixin', () {
      MemoryHistory mh;

      setUp(() {
        mh = new MemoryHistory();
      });

      group('index correctly responds to', () {
        test('push', () async {
          expect(mh.index, equals(0));
          await mh.push('/path');
          expect(mh.index, equals(1));
          await mh.push('/path2');
          expect(mh.index, equals(2));
        });

        test('replace', () async {
          expect(mh.index, equals(0));
          await mh.replace('/path');
          expect(mh.index, equals(0));
          await mh.push('/path2');
          expect(mh.index, equals(1));
          await mh.replace('/path3');
          expect(mh.index, equals(1));
        });

        test('go', () async {
          expect(mh.index, equals(0));
          await mh.push('/path');
          await mh.push('/path2');
          await mh.push('/path3');
          expect(mh.index, equals(3));
          await mh.go(-3);
          expect(mh.index, equals(0));
          await mh.go(2);
          expect(mh.index, equals(2));
          await mh.go(-1);
          expect(mh.index, equals(1));
          await mh.go(5);
          expect(mh.index, equals(3));
          await mh.go(-20);
          expect(mh.index, equals(0));
        });

        test('goForward', () async {
          expect(mh.index, equals(0));
          await mh.push('/path');
          await mh.push('/path2');
          await mh.push('/path3');
          await mh.go(-3);
          expect(mh.index, equals(0));
          await mh.goForward();
          expect(mh.index, equals(1));
          await mh.goForward();
          expect(mh.index, equals(2));
          await mh.goForward();
          expect(mh.index, equals(3));
          await mh.goForward();
          expect(mh.index, equals(3));
        });

        test('goBack', () async {
          expect(mh.index, equals(0));
          await mh.push('/path');
          await mh.push('/path2');
          await mh.push('/path3');
          expect(mh.index, equals(3));
          await mh.goBack();
          expect(mh.index, equals(2));
          await mh.goBack();
          expect(mh.index, equals(1));
          await mh.goBack();
          expect(mh.index, equals(0));
          await mh.goBack();
          expect(mh.index, equals(0));
        });
      });

      group('entries correctly responds to', () {
        test('push', () async {
          var expected = ['/'];
          var entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
          await mh.push('/path');
          expected.add('/path');
          entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
        });

        test('replace', () async {
          var expected = ['/'];
          var entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
          await mh.replace('/replace');
          expected = ['/replace'];
          entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
        });

        test('go', () async {
          await mh.push('/path');
          var expected = ['/', '/path'];
          var entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
          await mh.go(-1);
          entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
          await mh.go(1);
          entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
        });

        test('goForward', () async {
          await mh.push('/path');
          await mh.go(-1);
          var expected = ['/', '/path'];
          var entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
          await mh.goForward();
          entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
          await mh.goForward();
          entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
        });

        test('goBack', () async {
          await mh.push('/path');
          var expected = ['/', '/path'];
          var entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
          await mh.goBack();
          entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
          await mh.goBack();
          entryMap = mh.entries.map((l) => l.pathname);
          expect(entryMap, orderedEquals(expected));
        });
      });

      group('canGo', () {
        test('works for valid range', () {
          expect(mh.canGo(0), isTrue);
          expect(mh.canGo(-1), isFalse);
          expect(mh.canGo(1), isFalse);
        });

        test('works as paths are added', () async {
          expect(mh.canGo(0), isTrue);
          expect(mh.canGo(1), isFalse);
          expect(mh.canGo(2), isFalse);
          await mh.push('/path');
          expect(mh.canGo(1), isFalse);
          expect(mh.canGo(-1), isTrue);
          await mh.go(-1);
          expect(mh.canGo(1), isTrue);
          expect(mh.canGo(2), isFalse);
        });

        test('works as paths are removed', () async {
          expect(mh.canGo(0), isTrue);
          expect(mh.canGo(1), isFalse);
          expect(mh.canGo(2), isFalse);
          await mh.push('/path');
          await mh.push('/path2');
          await mh.go(-2);
          expect(mh.canGo(0), isTrue);
          expect(mh.canGo(1), isTrue);
          expect(mh.canGo(2), isTrue);
          await mh.push('/path3');
          await mh.go(-1);
          expect(mh.canGo(0), isTrue);
          expect(mh.canGo(1), isTrue);
          expect(mh.canGo(2), isFalse);
        });
      });
    });
  });
}
