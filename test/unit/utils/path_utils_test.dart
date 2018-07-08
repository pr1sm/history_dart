@TestOn('browser || vm')

import 'package:test/test.dart';

import 'package:history/src/utils/path_utils.dart';

void main() {
  group('Path Utils', () {
    group('addLeading', () {
      test('works correctly with no character prefix',
          () => expect(addLeading('test', ''), equals('test')));
      test('works correctly with no character path',
          () => expect(addLeading('', 'prefix'), equals('prefix')));

      group('correctly inserts a', () {
        test('single-character prefix',
            () => expect(addLeading('test', 'a'), equals('atest')));
        test('multi-character prefix',
            () => expect(addLeading('test', 'agood'), equals('agoodtest')));
        test('prefix longer than path',
            () => expect(addLeading('long', 'longer'), equals('longerlong')));
      });

      group('correctly does not insert a', () {
        test('single-character prefix',
            () => expect(addLeading('test', 't'), equals('test')));
        test('multi-character prefix',
            () => expect(addLeading('test', 'test'), equals('test')));
      });
    });

    group('stripLeading', () {
      test('works correctly with empty prefix',
          () => expect(stripLeading('test', ''), equals('test')));
      test('works correctly with empty path',
          () => expect(stripLeading('', 'test'), equals('')));

      group('correctly strips a', () {
        test('single-character prefix',
            () => expect(stripLeading('atest', 'a'), equals('test')));
        test('multi-character prefix',
            () => expect(stripLeading('agoodtest', 'agood'), equals('test')));
      });

      group('correctly does not strip a', () {
        test('single-character prefix',
            () => expect(stripLeading('test', 'a'), equals('test')));
        test(
            'multi-character prefix',
            () => expect(
                stripLeading('agoodtest', 'isgood'), equals('agoodtest')));
        test('perfix longer than path',
            () => expect(stripLeading('long', 'longer'), equals('long')));
      });
    });

    group('addLeadingSlash works correctly with ', () {
      test('empty path', () => expect(addLeadingSlash(''), equals('/')));
      test('\'/\' in path',
          () => expect(addLeadingSlash('/test'), equals('/test')));
      test('\'/\' not in path',
          () => expect(addLeadingSlash('test'), equals('/test')));
    });

    group('stripLeadingSlash works correctly with', () {
      test('empty path', () => expect(stripLeadingSlash(''), equals('')));
      test('\'/\' in path',
          () => expect(stripLeadingSlash('/test'), equals('test')));
      test('\'/\' no in path',
          () => expect(stripLeadingSlash('test'), equals('test')));
    });

    group('stripTrailingSlash works correctly with', () {
      test('empty path', () => expect(stripTrailingSlash(''), equals('')));
      test('\'/\' in path',
          () => expect(stripTrailingSlash('test/'), equals('test')));
      test('\'/\' no in path',
          () => expect(stripTrailingSlash('test'), equals('test')));
    });

    group('hasBasename', () {
      group('fails for', () {
        test('empty path', () => expect(hasBasename('', 'test'), isFalse));
        test('empty prefix with non-empty basename',
            () => expect(hasBasename('path/', ''), isFalse));
        test('non-equal basenames (short prefix)',
            () => expect(hasBasename('path/', 'pa'), isFalse));
        test('non-equal basenames (long prefix)',
            () => expect(hasBasename('path/', 'pathLongPrefix'), isFalse));
      });

      group('succeeds for', () {
        test('empty prefix with empty basename',
            () => expect(hasBasename('/path', ''), isTrue));
        test('basename only path',
            () => expect(hasBasename('basename', 'basename'), isTrue));
        test('basename with slash',
            () => expect(hasBasename('my/path', 'my'), isTrue));
        test('basename with search',
            () => expect(hasBasename('my?path', 'my'), isTrue));
        test('basename with hash',
            () => expect(hasBasename('my#path', 'my'), isTrue));
        test('basename with slash and search',
            () => expect(hasBasename('my/path?search', 'my'), isTrue));
        test('basename with search and hash',
            () => expect(hasBasename('my?search#hash', 'my'), isTrue));
        test('basename with slash and hash',
            () => expect(hasBasename('my/path#hash', 'my'), isTrue));
        test('basename with all components',
            () => expect(hasBasename('my/path?search#hash', 'my'), isTrue));
      });
    });

    group('stripBasename', () {
      group('does not strip for', () {
        test('empty path', () => expect(stripBasename('', 'test'), equals('')));
        test('empty prefix with non-empty basename',
            () => expect(stripBasename('path/', ''), equals('path/')));
        test('non-equal basenames (short prefix)',
            () => expect(stripBasename('path/', 'pa'), equals('path/')));
        test(
            'non-equal basenames (long prefix)',
            () => expect(
                stripBasename('path/', 'pathLongPrefix'), equals('path/')));
      });

      group('strips for', () {
        test('empty prefix with empty basename',
            () => expect(stripBasename('/path', ''), equals('/path')));
        test('basename only path',
            () => expect(stripBasename('basename', 'basename'), equals('')));
        test('basename with slash',
            () => expect(stripBasename('my/path', 'my'), equals('/path')));
        test('basename with search',
            () => expect(stripBasename('my?path', 'my'), equals('?path')));
        test('basename with hash',
            () => expect(stripBasename('my#path', 'my'), equals('#path')));
        test(
            'basename with slash and search',
            () => expect(
                stripBasename('my/path?search', 'my'), equals('/path?search')));
        test(
            'basename with search and hash',
            () => expect(
                stripBasename('my?search#hash', 'my'), equals('?search#hash')));
        test(
            'basename with slash and hash',
            () => expect(
                stripBasename('my/path#hash', 'my'), equals('/path#hash')));
        test(
            'basename with all components',
            () => expect(stripBasename('my/path?search#hash', 'my'),
                equals('/path?search#hash')));
      });
    });
  });
}
