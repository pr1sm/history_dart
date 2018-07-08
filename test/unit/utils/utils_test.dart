@TestOn('browser || vm')
import 'package:test/test.dart';

import 'package:history/src/core/location.dart';
import 'package:history/src/utils/utils.dart';

void main() {
  group('Utils', () {
    group('getPrompt', () {
      test('resolves when given a string', () async {
        String expected = 'given string';
        String actual = await getPrompt(expected, null, null);
        expect(actual, equals(expected));
      });

      test('resolves when given a Prompt', () async {
        String expected = 'given promt';
        Prompt test = (Location l, Action a) async => expected;
        String actual = await getPrompt(test, null, null);
        expect(actual, equals(expected));
      });

      test('throws error when not a String or Prompt', () {
        Object object = new Object();
        expect(getPrompt(object, null, null), throwsArgumentError);
      });
    });

    group('validatePath', () {
      test('validates when given a String', () {
        String test = 'given string';
        try {
          validatePath(test);
        } catch (e) {
          fail('validate path should not throw for String! ${test}');
        }
      });

      test('validates when given a Location', () {
        Location test = new Location();
        try {
          validatePath(test);
        } catch (e) {
          fail('validate path should not throw for Location! ${test}');
        }
      });

      test('throws error when not a String or Location', () {
        Object test = new Object();
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
