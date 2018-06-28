import 'dart:html';

import 'utils.dart';

/// Check if dom is available for use
bool get canUseDom => (window != null &&
    window.document != null &&
    window.document.createElement != null);

/// Confirmation using [Window.confirm]
///
/// This is a utility method to represent a [Confirmation] when using the DOM.
Confirmation get getConfirmation => (String message) => window.confirm(message);

/// Check if browser supports history
///
/// Taken from npm history package:
/// https://github.com/ReactTraining/history/blob/master/modules/DOMUtils.js
bool get supportsHistory {
  final ua = window.navigator.userAgent;
  if ((ua.indexOf('Android 2.') != -1 || ua.indexOf('Android 4.0') != -1) &&
      ua.indexOf('Mobile Safari') != -1 &&
      ua.indexOf('Chrome') == -1 &&
      ua.indexOf('Windows Phone') == -1) {
    return false;
  }
  return window.history != null && window.history.pushState != null;
}

/// Check if Browser supports [PopStateEvent] on hash change
bool get supportsPopStateOnHashChange =>
    window.navigator.userAgent.indexOf('Trident') == -1;

/// Check if [Window.go] can be called without reloading when using hash
bool get supportsGoWithoutReloadUsingHash =>
    window.navigator.userAgent.indexOf('Firefox') == -1;

/// Check if [event] is an extra [PopStateEvent]
///
/// On Mobile Chrome, a [PopStateEvent] is triggered with an empty state when
/// the back button is clicked. Check if [event] is this type of event.
bool isExtraneousPopStateEvent(event) =>
    event.state == null && window.navigator.userAgent.indexOf('CriOS') == -1;
