@TestOn('browser || vm')
import 'package:test/test.dart';

import 'package:history/src/core/location.dart';
import 'package:history/src/utils/utils.dart';

void main() {
  group('Utils', () {
    group('getPrompt', () {
      test('resolves when given a string', () async {
        var expected = 'given string';
        var actual = await getPrompt(expected, null, null);
        expect(actual, equals(expected));
      });

      test('resolves when given a Prompt', () async {
        var expected = 'given promt';
        Prompt test = (Location l, Action a) async => expected;
        var actual = await getPrompt(test, null, null);
        expect(actual, equals(expected));
      });

      test('throws error when not a String or Prompt', () {
        var object = Object();
        expect(getPrompt(object, null, null), throwsArgumentError);
      });
    });

    group('validatePath', () {
      test('validates when given a String', () {
        var test = 'given string';
        try {
          validatePath(test);
        } catch (e) {
          fail('validate path should not throw for String! ${test}');
        }
      });

      test('validates when given a Location', () {
        var test = Location();
        try {
          validatePath(test);
        } catch (e) {
          fail('validate path should not throw for Location! ${test}');
        }
      });

      test('throws error when not a String or Location', () {
        var test = Object();
        try {
          validatePath(test);
        } catch (e) {
          if (e is ArgumentError) {
            return;
          }
          fail(
              'validate path should throw an ArgumentError! instead, threw a ${e}');
        }
        fail('validate path should throw an ArgumentError!');
      });
    });
  });
}
