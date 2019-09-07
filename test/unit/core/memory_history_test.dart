@TestOn('browser || vm')
import 'dart:async';

import 'package:test/test.dart';

import 'package:history/src/core/memory_history.dart';
import 'package:history/src/utils/utils.dart' show Action, Confirmation;

import '../mocks/mocks.dart' show MockLocation;
import 'history_test_core.dart';

void main() {
  group('MemoryHistory', () {
    group('constructor', () {
      test('constructs with no parameters', () {
        var mh = MemoryHistory();
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
        var initialEntries = ['/test', MockLocation(), Object()];
        var mh = MemoryHistory(initialEntries: initialEntries);
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
        var mh = MemoryHistory(initialEntries: initialEntries, initialIndex: 1);
        expect(mh.index, equals(1));
        expect(mh.entries.isNotEmpty, isTrue);
        expect(mh.length, equals(2));
        expect(mh.action, equals(Action.pop));
        expect(mh.location, isNotNull);
        expect(mh.location.path, equals('/test'));
        expect(mh.isBlocking, isFalse);
        expect(mh.onChange, isNotNull);

        mh = MemoryHistory(initialEntries: initialEntries, initialIndex: 2);
        expect(mh.index, equals(1));
        expect(mh.entries.isNotEmpty, isTrue);
        expect(mh.length, equals(2));
        expect(mh.action, equals(Action.pop));
        expect(mh.location, isNotNull);
        expect(mh.location.path, equals('/test'));
        expect(mh.location.key.length, equals(6));
        expect(mh.isBlocking, isFalse);
        expect(mh.onChange, isNotNull);

        mh = MemoryHistory(initialEntries: initialEntries, initialIndex: 0);
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
        var mh = MemoryHistory(keyLength: 12);
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
        var c = Completer();
        Confirmation confirm = (String _) async {
          c.complete();
          return Future.value(true);
        };
        var mh = MemoryHistory(getConfirmation: confirm);
        mh.block('temp');
        await mh.push('/test');
        expect(c.isCompleted, true);
      });
    });

    group(
        'core:',
        testCoreHistory(({Confirmation confirmation}) =>
            MemoryHistory(getConfirmation: confirmation)));

    group('MemoryMixin', () {
      MemoryHistory mh;

      setUp(() {
        mh = MemoryHistory();
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
