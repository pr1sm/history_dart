@TestOn('browser')
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:history/src/utils/dom_utils.dart';

import '../mocks.dart';

void main() {
  group('DomUtils', () {
    DomUtils domUtils;

    group('canUseDom', () {
      test('is false when document is null', () {
        MockWindow mockWindow = new MockWindow();
        expect(mockWindow.document, isNull);
        domUtils = new DomUtils(windowImpl: mockWindow);
        expect(domUtils.canUseDom, isFalse);
      });

      test('is true when using html window', () {
        domUtils = new DomUtils();
        expect(domUtils.canUseDom, isTrue);
      });
    });

    group('getConfirmation', () {
      test('is false when not confirmed', () async {
        MockWindow mockWindow = new MockWindow();
        when(mockWindow.confirm()).thenReturn(false);
        when(mockWindow.confirm(typed(any))).thenReturn(false);
        domUtils = new DomUtils(windowImpl: mockWindow);
        expect(await domUtils.getConfirmation(null), isFalse);
        expect(await domUtils.getConfirmation(''), isFalse);
        expect(await domUtils.getConfirmation('message'), isFalse);
      });

      test('is true when confirmed', () async {
        MockWindow mockWindow = new MockWindow();
        when(mockWindow.confirm()).thenReturn(true);
        when(mockWindow.confirm(typed(any))).thenReturn(true);
        domUtils = new DomUtils(windowImpl: mockWindow);
        expect(await domUtils.getConfirmation(null), isTrue);
        expect(await domUtils.getConfirmation(''), isTrue);
        expect(await domUtils.getConfirmation('message'), isTrue);
      });
    });

    group('supportsHistory', () {
      MockNavigator mockNav;
      MockWindow mockWindow;

      setUpAll(() {
        mockWindow = new MockWindow();
        mockNav = new MockNavigator();
        MockHistory mockHistory = new MockHistory();
        when(mockWindow.history).thenReturn(mockHistory);
        when(mockWindow.navigator).thenReturn(mockNav);
        domUtils = new DomUtils(windowImpl: mockWindow);
      });

      void checkSupportHistory(String ua, {bool result = true}) {
        when(mockNav.userAgent).thenReturn(ua);
        expect(domUtils.supportsHistory, result ? isTrue : isFalse);
      }

      group('when testing UserAgent String', () {
        group('fails when', () {
          test(
              'Android 2.2 and Mobile Safari',
              () => checkSupportHistory('Android 2.2 Mobile Safari',
                  result: false));
          test(
              'Android 2.3 and Mobile Safari',
              () => checkSupportHistory('Android 2.3 Mobile Safari',
                  result: false));
          test(
              'Android 4.0 and Mobile Safari',
              () => checkSupportHistory('Android 4.0 Mobile Safari',
                  result: false));
        });

        group('succeeds when', () {
          test('Chrome', () => checkSupportHistory('Chrome', result: true));
          test('Windows Phone',
              () => checkSupportHistory('Windows Phone', result: true));
        });
      });

      group('when using example UserAgents', () {
        test(
            'is true for Firefox (desktop)',
            () => checkSupportHistory(
                'Mozilla/5.0 (Macintosh; Intel Mac OS X x.y; rv:42.0) Gecko/20100101 Firefox/42.0',
                result: true));
        test(
            'is true for Firefox (mobile)',
            () => checkSupportHistory(
                'Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0',
                result: true));
        test(
            'is true for Firefox (tablet)',
            () => checkSupportHistory(
                'Mozilla/5.0 (Android 4.4; Tablet; rv:41.0) Gecko/41.0 Firefox/41.0',
                result: true));
        test(
            'is true for Chrome (desktop)',
            () => checkSupportHistory(
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36',
                result: true));
        test(
            'is true for Chrome (iOS)',
            () => checkSupportHistory(
                'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1',
                result: true));
        test(
            'is true for Chrome (Android Mobile)',
            () => checkSupportHistory(
                'Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Mobile Safari/535.19',
                result: true));
        test(
            'is true for Chrome (Android Tablet)',
            () => checkSupportHistory(
                'Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Safari/535.19',
                result: true));
        test(
            'is true for Opera',
            () => checkSupportHistory(
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41',
                result: true));
        test(
            'is true for Safari (macOS)',
            () => checkSupportHistory(
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.1 Safari/605.1.15',
                result: true));
        test(
            'is true for Safari (iOS)',
            () => checkSupportHistory(
                'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
                result: true));
        test(
            'is true for Edge',
            () => checkSupportHistory(
                'Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.10136',
                result: true));
        test(
            'is true for Windows Phone (IE9)',
            () => checkSupportHistory(
                'Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)',
                result: true));
      });
    });

    group('supportsPopStateOnHashChange', () {
      MockNavigator mockNav;
      MockWindow mockWindow;

      setUpAll(() {
        mockWindow = new MockWindow();
        mockNav = new MockNavigator();
        MockHistory mockHistory = new MockHistory();
        when(mockWindow.history).thenReturn(mockHistory);
        when(mockWindow.navigator).thenReturn(mockNav);
        domUtils = new DomUtils(windowImpl: mockWindow);
      });

      void checkPopStateOnHashChange(String ua, {bool result = true}) {
        when(mockNav.userAgent).thenReturn(ua);
        expect(
            domUtils.supportsPopStateOnHashChange, result ? isTrue : isFalse);
      }

      test('fails when using "Trident"',
          () => checkPopStateOnHashChange('Trident', result: false));
      test('succeeds when not using "Trident"',
          () => checkPopStateOnHashChange('Firefox', result: true));

      group('when using example UserAgents', () {
        test(
            'is true for Firefox (desktop)',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (Macintosh; Intel Mac OS X x.y; rv:42.0) Gecko/20100101 Firefox/42.0',
                result: true));
        test(
            'is true for Firefox (mobile)',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0',
                result: true));
        test(
            'is true for Firefox (tablet)',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (Android 4.4; Tablet; rv:41.0) Gecko/41.0 Firefox/41.0',
                result: true));
        test(
            'is true for Chrome (desktop)',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36',
                result: true));
        test(
            'is true for Chrome (iOS)',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1',
                result: true));
        test(
            'is true for Chrome (Android Mobile)',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Mobile Safari/535.19',
                result: true));
        test(
            'is true for Chrome (Android Tablet)',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Safari/535.19',
                result: true));
        test(
            'is true for Opera',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41',
                result: true));
        test(
            'is true for Safari (macOS)',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.1 Safari/605.1.15',
                result: true));
        test(
            'is true for Safari (iOS)',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
                result: true));
        test(
            'is true for Edge',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.10136',
                result: true));
        test(
            'is false for Windows Phone (IE9)',
            () => checkPopStateOnHashChange(
                'Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)',
                result: false));
      });
    });

    group('supportsGoWithoutReloadUsingHash', () {
      MockNavigator mockNav;
      MockWindow mockWindow;

      setUpAll(() {
        mockWindow = new MockWindow();
        mockNav = new MockNavigator();
        MockHistory mockHistory = new MockHistory();
        when(mockWindow.history).thenReturn(mockHistory);
        when(mockWindow.navigator).thenReturn(mockNav);
        domUtils = new DomUtils(windowImpl: mockWindow);
      });

      void checkGoWithoutReloadUsingHash(String ua, {bool result = true}) {
        when(mockNav.userAgent).thenReturn(ua);
        expect(domUtils.supportsGoWithoutReloadUsingHash,
            result ? isTrue : isFalse);
      }

      test('fails when using "Firefox"',
          () => checkGoWithoutReloadUsingHash('Firefox', result: false));
      test('succeeds when not using "Firefox"',
          () => checkGoWithoutReloadUsingHash('Safari', result: true));

      group('when using example UserAgents', () {
        test(
            'is false for Firefox (desktop)',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (Macintosh; Intel Mac OS X x.y; rv:42.0) Gecko/20100101 Firefox/42.0',
                result: false));
        test(
            'is false for Firefox (mobile)',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (Android 4.4; Mobile; rv:41.0) Gecko/41.0 Firefox/41.0',
                result: false));
        test(
            'is false for Firefox (tablet)',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (Android 4.4; Tablet; rv:41.0) Gecko/41.0 Firefox/41.0',
                result: false));
        test(
            'is true for Chrome (desktop)',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36',
                result: true));
        test(
            'is true for Chrome (iOS)',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1',
                result: true));
        test(
            'is true for Chrome (Android Mobile)',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Mobile Safari/535.19',
                result: true));
        test(
            'is true for Chrome (Android Tablet)',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Safari/535.19',
                result: true));
        test(
            'is true for Opera',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41',
                result: true));
        test(
            'is true for Safari (macOS)',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.1 Safari/605.1.15',
                result: true));
        test(
            'is true for Safari (iOS)',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
                result: true));
        test(
            'is true for Edge',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.10136',
                result: true));
        test(
            'is true for Windows Phone (IE9)',
            () => checkGoWithoutReloadUsingHash(
                'Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)',
                result: true));
      });
    });

    group('isExtraneousPopStateEvent', () {
      MockNavigator mockNav;
      MockWindow mockWindow;

      setUpAll(() {
        mockWindow = new MockWindow();
        mockNav = new MockNavigator();
        MockHistory mockHistory = new MockHistory();
        when(mockWindow.history).thenReturn(mockHistory);
        when(mockWindow.navigator).thenReturn(mockNav);
        domUtils = new DomUtils(windowImpl: mockWindow);
      });

      test('fails when event state is not null', () {
        MockPopStateEvent mockEvent = new MockPopStateEvent();
        when(mockNav.userAgent).thenReturn('Mobile');
        when(mockEvent.state).thenReturn('Hello!');
        expect(domUtils.isExtraneousPopStateEvent(mockEvent), isFalse);
      });

      test('fails when UA contains "CriOS"', () {
        MockPopStateEvent mockEvent = new MockPopStateEvent();
        when(mockNav.userAgent).thenReturn('CriOS');
        expect(domUtils.isExtraneousPopStateEvent(mockEvent), isFalse);
      });

      test('fails when event state is not null AND UA contains "CriOS"', () {
        MockPopStateEvent mockEvent = new MockPopStateEvent();
        when(mockNav.userAgent).thenReturn('CriOS');
        when(mockEvent.state).thenReturn({});
        expect(domUtils.isExtraneousPopStateEvent(mockEvent), isFalse);
      });

      test('succeeds when event state is null AND UA doesn\'t contain "CriOS"',
          () {
        MockPopStateEvent mockEvent = new MockPopStateEvent();
        when(mockNav.userAgent).thenReturn('Mobile');
        expect(domUtils.isExtraneousPopStateEvent(mockEvent), isTrue);
      });
    });
  });
}
