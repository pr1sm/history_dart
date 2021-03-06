@TestOn('browser')
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:history/src/utils/hash_utils.dart';
import 'package:history/src/utils/utils.dart';

import '../mocks/html_mocks.dart' show MockHtmlLocation;

void main() {
  group('HashUtils', () {
    group('EncoderDecoder', () {
      test('constructs', () {
        EncoderDecoder ed = EncoderDecoder(null, null);
        expect(ed, isNotNull);
      });

      test('encodePath is wired properly', () async {
        Completer c = Completer();
        var encoder = (input) {
          c.complete();
          return 'pong';
        };
        EncoderDecoder ed = EncoderDecoder(encoder, null);
        var encoded = ed.encodePath('ping');
        await c.future;
        expect(encoded, equals('pong'));
      });

      test('decodePath is wired properly', () async {
        Completer c = Completer();
        var decoder = (input) {
          c.complete();
          return 'pong';
        };
        EncoderDecoder ed = EncoderDecoder(null, decoder);
        var encoded = ed.decodePath('ping');
        await c.future;
        expect(encoded, equals('pong'));
      });
    });

    group('HashPathCoders', () {
      EncoderDecoder ed;
      group('hashbang', () {
        setUp(() {
          ed = HashPathCoders[HashType.hashbang];
        });

        test('encodes when path starts with "!"', () {
          var path = '!test';
          expect(ed.encodePath(path), equals(path));
        });

        test('encodes when path starts with "!/"', () {
          var path = '!/test';
          expect(ed.encodePath(path), equals(path));
        });

        test('encodes when path doesn\'t start with "!"', () {
          var path = 'test';
          expect(ed.encodePath(path), equals('!/${path}'));
        });

        test('decodes when path starts with "!"', () {
          var path = '!/test';
          expect(ed.decodePath(path), equals('/test'));
        });

        test('decodes when path doesn\' start with "!"', () {
          var path = '/test';
          expect(ed.decodePath(path), equals(path));
        });
      });

      group('noSlash', () {
        setUp(() {
          ed = HashPathCoders[HashType.noSlash];
        });

        test('encodes when path starts with "/"', () {
          var path = 'test';
          expect(ed.encodePath('/${path}'), equals(path));
        });

        test('encodes when path doesn\'t start with "/"', () {
          var path = 'test';
          expect(ed.encodePath(path), equals(path));
        });

        test('decodes when path starts with "/"', () {
          var path = 'test';
          expect(ed.decodePath('/${path}'), equals('/${path}'));
        });

        test('decodes when path doesn\'t start with "/"', () {
          var path = 'test';
          expect(ed.decodePath(path), equals('/${path}'));
        });
      });

      group('slash', () {
        setUp(() {
          ed = HashPathCoders[HashType.slash];
        });

        test('encodes when path starts with "/"', () {
          var path = 'test';
          expect(ed.encodePath('/${path}'), equals('/${path}'));
        });

        test('encodes when path doesn\'t start with "/"', () {
          var path = 'test';
          expect(ed.encodePath(path), equals('/${path}'));
        });

        test('decodes when path starts with "/"', () {
          var path = 'test';
          expect(ed.decodePath('/${path}'), equals('/${path}'));
        });

        test('decodes when path doesn\'t start with "/"', () {
          var path = 'test';
          expect(ed.decodePath(path), equals('/${path}'));
        });
      });
    });

    group('convert', () {
      MockHtmlLocation mockLocation;

      setUp(() {
        mockLocation = MockHtmlLocation();
      });

      tearDown(() {
        reset(mockLocation);
      });

      test('converts with just pathname', () {
        when(mockLocation.pathname).thenReturn('testpath');
        when(mockLocation.hash).thenReturn('');
        when(mockLocation.search).thenReturn('');
        var convertLoc = convert(mockLocation);
        expect(convertLoc.pathname, equals('testpath'));
      });

      test('converts with just hash', () {
        when(mockLocation.pathname).thenReturn('');
        when(mockLocation.hash).thenReturn('testhash');
        when(mockLocation.search).thenReturn('');
        var convertLoc = convert(mockLocation);
        expect(convertLoc.hash, equals('testhash'));
      });

      test('converts with just search', () {
        when(mockLocation.pathname).thenReturn('');
        when(mockLocation.hash).thenReturn('');
        when(mockLocation.search).thenReturn('testsearch');
        var convertLoc = convert(mockLocation);
        expect(convertLoc.search, equals('testsearch'));
      });

      test('converts with all', () {
        when(mockLocation.pathname).thenReturn('testpath');
        when(mockLocation.hash).thenReturn('testhash');
        when(mockLocation.search).thenReturn('testsearch');
        var convertLoc = convert(mockLocation);
        expect(convertLoc.pathname, equals('testpath'));
        expect(convertLoc.hash, equals('testhash'));
        expect(convertLoc.search, equals('testsearch'));
      });
    });
  });
}
