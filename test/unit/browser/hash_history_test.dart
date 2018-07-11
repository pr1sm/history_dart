@TestOn('browser')
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:history/src/browser/hash_history.dart';
import 'package:history/src/utils/utils.dart' show Confirmation, HashType;

import 'html_mocks.dart'
    show MockHtmlNavigator, MockHtmlWindow, MockHtmlWindowNoImpl;

import '../core/history_core_tests.dart';

void main() {
  group('HashHistory', () {
    Confirmation autoConfirm = (_) => new Future.value(true);

    group('constructor', () {
      test('constructs correctly when dom is available', () {
        MockHtmlWindow window = new MockHtmlWindow();
        new HashHistory(window: window);
      });

      test('fails to construct when dom is unavailable', () {
        MockHtmlWindowNoImpl window = new MockHtmlWindowNoImpl();
        try {
          new HashHistory(window: window);
        } on StateError catch (_) {
          return;
        }
        fail(
            'HashHistory constructor should throw a state error when dom is unavailable');
      });
    });

    group(
        'core:',
        testHistoryCore(({Confirmation confirmation}) {
          MockHtmlWindow window = new MockHtmlWindow();
          return new HashHistory(
              getConfirmation: confirmation ?? autoConfirm, window: window);
        }, supportsState: false));

    group('HashMixin', () {
      test('hashType responds correctly after construction', () {
        MockHtmlWindow window = new MockHtmlWindow();
        HashHistory hashHistory = new HashHistory(window: window);
        expect(hashHistory.hashType, equals(HashType.slash));
        hashHistory =
            new HashHistory(window: window, hashType: HashType.hashbang);
        expect(hashHistory.hashType, equals(HashType.hashbang));
        hashHistory = new HashHistory(window: window, hashType: HashType.slash);
        expect(hashHistory.hashType, equals(HashType.slash));
        hashHistory =
            new HashHistory(window: window, hashType: HashType.noSlash);
        expect(hashHistory.hashType, equals(HashType.noSlash));
      });

      test('go prints warning message when hash reloading is not supported',
          () async {
        MockHtmlWindow mockHtmlWindow = new MockHtmlWindow();
        MockHtmlNavigator mockNav = mockHtmlWindow.mockNavigator;
        when(mockNav.userAgent).thenReturn('Firefox');
        HashHistory hashHistory = new HashHistory(window: mockHtmlWindow);
        await hashHistory.go(0);
      });

      test(
          'getting location prints warning message when basename is different from path',
          () {
        MockHtmlWindow mockHtmlWindow = new MockHtmlWindow();
        HashHistory hashHistory =
            new HashHistory(basename: '/base', window: mockHtmlWindow);
        expect(hashHistory.location.path, isNot(startsWith('/base')));
      });

      test('correct hash type encoding on hash change', () async {
        MockHtmlWindow mockHtmlWindow = new MockHtmlWindow();
        HashHistory hashHistory = new HashHistory(window: mockHtmlWindow);
        Future<HashHistory> update = hashHistory.onChange.first;

        mockHtmlWindow.mockHistory.mockLocation.href = '#hash';

        HashHistory check = await update;
        expect(check.location.path, isNot(equals('#hash')));
        expect(check.location.path, equals('/hash'));
      });
    });
  });
}
