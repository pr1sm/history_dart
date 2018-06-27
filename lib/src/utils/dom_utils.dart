import 'dart:html';

bool get canUseDom => (window != null &&
    window.document != null &&
    window.document.createElement != null);

void getConfirmation({String message, ConfirmationCallback callback}) {
  final confirmed = window.confirm(message);
  if (callback != null) {
    callback(confirmed);
  }
}

/**
 * Take from npm history package:
 * https://github.com/ReactTraining/history/blob/master/modules/DOMUtils.js
 */
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

bool get supportsPopStateOnHashChange =>
    window.navigator.userAgent.indexOf('Trident') == -1;

bool get supportsGoWithoutReloadUsingHash =>
    window.navigator.userAgent.indexOf('Firefox') == -1;

bool isExtraneousPopStateEvent(event) =>
    event.state == null && window.navigator.userAgent.indexOf('CriOS') == -1;
