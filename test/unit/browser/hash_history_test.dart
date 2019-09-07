@TestOn('browser')
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:history/src/browser/hash_history.dart';
import 'package:history/src/utils/utils.dart' show Confirmation, HashType;

import '../mocks/hash_mocks.dart';
import '../mocks/html_mocks.dart';

import '../core/history_test_core.dart';

void main() {
  group('HashHistory', () {
    Confirmation autoConfirm = (_) => Future.value(true);

    group('constructor', () {
      test('constructs correctly when dom is available', () {
        var window = MockHashHtmlWindow();
        HashHistory(window: window);
      });

      test('fails to construct when dom is unavailable', () {
        var window = MockHtmlWindow();
        try {
          HashHistory(window: window);
        } on StateError catch (_) {
          return;
        }
        fail(
            'HashHistory constructor should throw a state error when dom is unavailable');
      });
    });

    group(
        'core:',
        testCoreHistory(({Confirmation confirmation}) {
          var window = MockHashHtmlWindow();
          return HashHistory(
              getConfirmation: confirmation ?? autoConfirm, window: window);
        }, supportsState: false));

    group('HashMixin', () {
      test('hashType responds correctly after construction', () {
        var window = MockHashHtmlWindow();
        var hashHistory = HashHistory(window: window);
        expect(hashHistory.hashType, equals(HashType.slash));
        hashHistory = HashHistory(window: window, hashType: HashType.hashbang);
        expect(hashHistory.hashType, equals(HashType.hashbang));
        hashHistory = HashHistory(window: window, hashType: HashType.slash);
        expect(hashHistory.hashType, equals(HashType.slash));
        hashHistory = HashHistory(window: window, hashType: HashType.noSlash);
        expect(hashHistory.hashType, equals(HashType.noSlash));
      });

      test('go prints warning message when hash reloading is not supported',
          () async {
        var mockHtmlWindow = MockHashHtmlWindow();
        var mockNav = mockHtmlWindow.mockNavigator;
        when(mockNav.userAgent).thenReturn('Firefox');
        var hashHistory = HashHistory(window: mockHtmlWindow);
        await hashHistory.go(0);
      });

      test(
          'getting location prints warning message when basename is different from path',
          () {
        var mockHtmlWindow = MockHashHtmlWindow();
        var hashHistory =
            HashHistory(basename: '/base', window: mockHtmlWindow);
        expect(hashHistory.location.path, isNot(startsWith('/base')));
      });

      test('correct hash type encoding on hash change', () async {
        var mockHtmlWindow = MockHashHtmlWindow();
        var hashHistory = HashHistory(window: mockHtmlWindow);
        var update = hashHistory.onChange.first;

        mockHtmlWindow.mockHistory.mockLocation.href = '#hash';

        var check = await update;
        expect(check.location.path, isNot(equals('#hash')));
        expect(check.location.path, equals('/hash'));
      });
    });
  });
}
