// MIT License
//
// Copyright (c) 2018 Srinivas Dhanwada
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:html';

import 'utils.dart';

class DomUtils {
  final Window _windowImpl;

  DomUtils({Window windowImpl}) : _windowImpl = windowImpl ?? window;

  /// Check if dom is available for use
  bool get canUseDom => (_windowImpl != null &&
      _windowImpl.document != null &&
      _windowImpl.document is Document);

  /// Confirmation using [Window.confirm]
  ///
  /// This is a utility method to represent a [Confirmation] when using the DOM.
  Confirmation get getConfirmation =>
      (String message) async => (message != null && message.isNotEmpty)
          ? _windowImpl.confirm(message)
          : _windowImpl.confirm();

  /// Check if browser supports history
  ///
  /// UserAgent check taken from npm history package:
  /// https://github.com/ReactTraining/history/blob/master/modules/DOMUtils.js
  bool get supportsHistory {
    final ua = _windowImpl.navigator.userAgent;
    if ((ua.contains('Android 2.') || ua.contains('Android 4.0')) &&
        ua.contains('Mobile Safari') &&
        !ua.contains('Chrome') &&
        !ua.contains('Windows Phone')) {
      return false;
    }
    return _windowImpl.history != null && _windowImpl.history is History;
  }

  /// Check if Browser supports [PopStateEvent] on hash change
  bool get supportsPopStateOnHashChange =>
      !_windowImpl.navigator.userAgent.contains('Trident');

  /// Check if [Window.go] can be called without reloading when using hash
  bool get supportsGoWithoutReloadUsingHash =>
      !_windowImpl.navigator.userAgent.contains('Firefox');

  /// Check if [event] is an extra [PopStateEvent]
  ///
  /// On Mobile Chrome, a [PopStateEvent] is triggered with an empty state when
  /// the back button is clicked. Check if [event] is this type of event.
  bool isExtraneousPopStateEvent(PopStateEvent event) =>
      event.state == null && !_windowImpl.navigator.userAgent.contains('CriOS');
}
