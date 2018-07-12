@TestOn('browser')
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:history/src/browser/browser_history.dart';
import 'package:history/src/utils/utils.dart' show Confirmation;

import '../mocks/html_mocks.dart' show MockHtmlWindow;
import '../mocks/browser_mocks.dart'
    show MockBrowserHtmlWindow, MockBrowserHtmlHistory;

import '../core/history_test_core.dart';

void main() {
  group('BrowserHistory', () {
    Confirmation autoConfirm = (_) => new Future.value(true);

    group('constructor', () {
      test('constructs correctly when dom is available', () {
        var window = new MockBrowserHtmlWindow();
        new BrowserHistory(window: window);
      });

      test('fails to construct when dom is unavailable', () {
        var window = new MockHtmlWindow();
        try {
          new BrowserHistory(window: window);
        } on StateError catch (_) {
          return;
        }
        fail(
            'Browser History constructor should throw a state error when dom is unavailable!');
      });
    });

    group('core:', testCoreHistory(({Confirmation confirmation}) {
      var window = new MockBrowserHtmlWindow();
      return new BrowserHistory(
          getConfirmation: confirmation ?? autoConfirm, window: window);
    }));

    group('BrowserMixin', () {
      test('handles error on history state gracefully', () {
        var window = new MockBrowserHtmlWindow();
        window.mockHistory = new MockBrowserHtmlHistory(mockErrorOnState: true);
        new BrowserHistory(window: window);
      });

      test('handles null history state gracefully', () async {
        var window = new MockBrowserHtmlWindow();
        var mockNav = window.mockNavigator;
        when(mockNav.userAgent).thenReturn(
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36 CriOS');
        window.mockHistory = new MockBrowserHtmlHistory(mockNullOnState: true);
        var browserHistory = new BrowserHistory(window: window);
        var completer = new Completer();
        var sub = browserHistory.onChange.listen((_) {
          completer.complete();
        });
        await browserHistory.push('/push');
        await completer.future;
        sub.cancel();
      });

      test('window events are still handled when pop state is not supported',
          () async {
        var window = new MockBrowserHtmlWindow();
        window.mockHistory = new MockBrowserHtmlHistory(mockUsePopState: false);
        var mockNav = window.mockNavigator;
        when(mockNav.userAgent).thenReturn(
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36 Trident');
        var browserHistory = new BrowserHistory(window: window);
        var completer = new Completer();
        var sub = browserHistory.onChange.listen((_) {
          completer.complete();
        });
        window.location.href = '/path';
        await completer.future;
        sub.cancel();
        expect(browserHistory.location.pathname, equals('/path'));
      });

      group('forceRefresh', () {
        test('reponds correctly after construction', () {
          var window = new MockBrowserHtmlWindow();
          var browserHistory = new BrowserHistory(window: window);
          expect(browserHistory.willForceRefresh, isFalse);
          browserHistory =
              new BrowserHistory(window: window, forcedRefresh: false);
          expect(browserHistory.willForceRefresh, isFalse);
          browserHistory =
              new BrowserHistory(window: window, forcedRefresh: true);
          expect(browserHistory.willForceRefresh, isTrue);
        });

        test('causes location.href set on push', () async {
          var window = new MockBrowserHtmlWindow();
          var browserHistory =
              new BrowserHistory(window: window, forcedRefresh: true);
          var completer = new Completer();
          var sub = browserHistory.onChange.listen((h) {
            completer.complete();
          });
          await browserHistory.push('/path');
          expect(window.location.href, equals('/path'));
          expect(completer.isCompleted, isFalse);
          sub.cancel();
        });

        test('causes location.href set on replace', () async {
          var window = new MockBrowserHtmlWindow();
          var browserHistory =
              new BrowserHistory(window: window, forcedRefresh: true);
          var completer = new Completer();
          var sub = browserHistory.onChange.listen((h) {
            completer.complete();
          });
          await browserHistory.replace('/path');
          expect(window.location.href, equals('/path'));
          expect(completer.isCompleted, isFalse);
          sub.cancel();
        });
      });

      test(
          'getting location prints warning message when basename is different from path',
          () {
        var mockHtmlWindow = new MockBrowserHtmlWindow();
        var browserHistory =
            new BrowserHistory(basename: '/base', window: mockHtmlWindow);
        expect(browserHistory.location.path, isNot(startsWith('/base')));
      });

      group('when browser doesn\'t support history', () {
        MockBrowserHtmlWindow window;
        BrowserHistory browserHistory;
        Completer completer;
        StreamSubscription sub;

        setUp(() {
          window = new MockBrowserHtmlWindow();
          var mockNav = window.mockNavigator;
          when(mockNav.userAgent).thenReturn('Android 2.2 and Mobile Safari');
          browserHistory =
              new BrowserHistory(window: window, forcedRefresh: true);
          completer = new Completer();
          sub = browserHistory.onChange.listen((h) {
            completer.complete();
          });
        });

        tearDown(() {
          sub.cancel();
        });

        void verifyLocationChange(String expected) {
          expect(window.location.href, equals(expected));
          expect(completer.isCompleted, isFalse);
        }

        test('location.href is set on push', () async {
          await browserHistory.push('/path');
          verifyLocationChange('/path');
        });

        test('location.href is set on replace', () async {
          await browserHistory.replace('/path');
          verifyLocationChange('/path');
        });

        test('warning message is shown when passing state to push', () async {
          await browserHistory.push('/path', 'unsupported');
          verifyLocationChange('/path');
        });

        test('warning message is shown when passing state to replace',
            () async {
          await browserHistory.replace('/path', 'unsupported');
          verifyLocationChange('/path');
        });
      });
    });
  });
}
