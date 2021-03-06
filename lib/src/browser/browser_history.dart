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

import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import '../core/history.dart';
import '../core/location.dart';
import 'browser_transition_manager.dart';
import '../utils/dom_utils.dart' show DomUtils;
import '../utils/path_utils.dart'
    show stripTrailingSlash, addLeadingSlash, hasBasename, stripBasename;
import '../utils/utils.dart' show Action, Confirmation, PopMode, validatePath;

/// Mixin contains [BrowserHistory] specific definitions
abstract class BrowserMixin {
  /// If changes to this will force a Browser page refresh
  bool get willForceRefresh;
}

/// Extension of [History] that proxies calls to the Browser
///
/// This class includes extends all functionality of the base [History] class and adds
/// extra functionality only supported in this variant.
class BrowserHistory extends History with BrowserMixin, BasenameMixin {
  String _basename;
  BrowserTransitionManager<BrowserHistory> _transitionManager;
  Action _action;
  Location _location;
  PopMode _popMode;
  List<String> _allKeys;
  DomUtils _domUtils;
  html.History _globalHistory;
  html.Window _window;
  Completer _popHandlerCompleter;
  Confirmation _getConfirmation;

  final bool _forceRefresh;
  final Random _r = Random();
  final int _keyLength;

  BrowserHistory(
      {String basename = '',
      bool forcedRefresh = false,
      int keyLength = 6,
      Confirmation getConfirmation,
      html.Window window})
      : _forceRefresh = forcedRefresh,
        _getConfirmation = getConfirmation,
        _keyLength = keyLength {
    _window = window ?? html.window;
    _domUtils = DomUtils(windowImpl: _window);
    if (!_domUtils.canUseDom) {
      throw StateError('Browser History needs a DOM');
    }
    _getConfirmation ??= _domUtils.getConfirmation;
    _globalHistory = _window.history;
    _basename =
        basename != null ? stripTrailingSlash(addLeadingSlash(basename)) : '';
    _popMode = PopMode.normal;

    _location = _domLocation(_historyState);
    _action = Action.pop;
    _allKeys = [_location.key];

    _transitionManager = BrowserTransitionManager(
        popStateChangeHandler: _handlePopState,
        hashChangeHandler: _handleHashChange,
        needsHashChangeHandler: !_domUtils.supportsPopStateOnHashChange);
  }

  @override
  bool get willForceRefresh => _forceRefresh;

  @override
  String get basename => _basename;

  @override
  int get length => _globalHistory.length;

  @override
  Location get location => _location;

  @override
  Action get action => _action;

  @override
  bool get isBlocking => _transitionManager.prompt != null;

  @override
  Stream<BrowserHistory> get onChange => _transitionManager.stream;

  @override
  Future<Null> push(dynamic path, [dynamic state]) async {
    // Validate arguments
    validatePath(path);
    if (path is Location && path.state != null && state != null) {
      print(
          'WARNING: You should avoid adding the 2nd argument (state) when the 1st argument is a "Location" with a defined state; 2nd argument state will be ignored');
    }

    // Compute next location and action
    Location nextLocation = (path is String)
        ? Location(pathname: path, state: state, key: _createKey())
        : Location.copy((path as Location),
            key: _createKey(), state: path.state ?? state);
    var nextAction = Action.push;
    nextLocation.relateTo(_location);

    // Await Confirmation
    var ok = await _transitionManager.confirmTransitionTo(
        nextLocation, nextAction, _getConfirmation);
    if (!ok) {
      return;
    }

    var href = _href(nextLocation);

    if (_domUtils.supportsHistory) {
      if (_transitionManager.listeningToWindowEvents) {
        _popMode = PopMode.force;
      }
      _globalHistory.pushState(
          {'key': nextLocation.key, 'state': nextLocation.state}, null, href);

      if (_forceRefresh) {
        _window.location.href = href;
      } else {
        var prevIndex = _allKeys.indexOf(_location.key);
        _allKeys = _allKeys.sublist(0, prevIndex == -1 ? 0 : prevIndex + 1)
          ..add(nextLocation.key);
        _location = nextLocation;
        _action = nextAction;
        _transitionManager.notify(this);
      }
    } else {
      if (state != null) {
        print(
            'WARNING: Browser history cannot push state in browsers that do not support HTML5 history');
      }
      _window.location.href = href;
    }
  }

  @override
  Future<Null> replace(dynamic path, [dynamic state]) async {
    // Validate arguments
    validatePath(path);
    if (path is Location && path.state != null && state != null) {
      print(
          'WARNING: You should avoid adding the 2nd argument (state) when the 1st argument is a "Location" with a defined state; 2nd argument state will be ignored');
    }

    // Compute next location and action
    Location nextLocation = (path is String)
        ? Location(pathname: path, state: state, key: _createKey())
        : Location.copy((path as Location),
            key: _createKey(), state: path.state ?? state);
    var nextAction = Action.replace;
    nextLocation.relateTo(_location);

    // Await Confirmation
    var ok = await _transitionManager.confirmTransitionTo(
        nextLocation, nextAction, _getConfirmation);
    if (!ok) {
      return;
    }

    var href = _href(nextLocation);

    if (_domUtils.supportsHistory) {
      if (_transitionManager.listeningToWindowEvents) {
        _popMode = PopMode.force;
      }
      _globalHistory.replaceState(
          {'key': nextLocation.key, 'state': nextLocation.state}, null, href);

      if (_forceRefresh) {
        _window.location.href = href;
      } else {
        var prevIndex = _allKeys.indexOf(_location.key);
        if (prevIndex != -1) {
          _allKeys[prevIndex] = location.key;
        }
        _location = nextLocation;
        _action = nextAction;
        _transitionManager.notify(this);
      }
    } else {
      if (state == null) {
        print(
            'WARNING: Browser history cannot push state in browsers that do not support HTML5 history');
      }
      _window.location.replace(href);
    }
  }

  @override
  Future<Null> go(int n) async {
    if (_transitionManager.listeningToWindowEvents) {
      _popHandlerCompleter = Completer();
      _globalHistory.go(n);
      await _popHandlerCompleter.future;
      _popHandlerCompleter = null;
    } else {
      _globalHistory.go(n);
      await _handlePop(_domLocation(_historyState));
    }
  }

  @override
  void block(dynamic prompt) => _transitionManager.prompt = prompt;

  @override
  void unblock() => _transitionManager.prompt = null;

  dynamic get _historyState {
    try {
      return _window.history.state ?? {};
    } catch (e) {
      return {};
    }
  }

  String _href(Location location) => basename + location.path;

  Location _domLocation(dynamic historyState) {
    historyState ??= {};
    var key = historyState['key'];
    var state = historyState['state'];

    var pathname = _window.location.pathname;
    var search = _window.location.search;
    var hash = _window.location.hash;

    // var path = pathname + search + hash;
    var path = pathname +
        (search.isNotEmpty ? '?${search}' : '') +
        (hash.isNotEmpty ? '#${hash}' : '');

    if (basename != null && !hasBasename(path, basename)) {
      print(
          'WARNING: You are attempting to use a basename on a page whose URL path does not begin with the basename. Expected path "${path}" to begin with "${basename}"');
    }

    if (basename != null) {
      path = stripBasename(path, basename);
    }

    return Location(pathname: path, state: state, key: key.toString());
  }

  Future<Null> _handlePopState(html.Event event) async {
    var popStateEvent = event as html.PopStateEvent;
    if (_domUtils.isExtraneousPopStateEvent(popStateEvent)) return;

    await _handlePop(_domLocation(popStateEvent.state));
  }

  Future<Null> _handleHashChange(e) async =>
      await _handlePop(_domLocation(_historyState));

  Future<Null> _handlePop(Location location) async {
    if (_popMode == PopMode.force) {
      _popMode = PopMode.normal;
    } else if (_popMode == PopMode.forceAndNotify) {
      _popMode = PopMode.normal;
      _transitionManager.notify(this);
    } else {
      var action = Action.pop;
      bool ok = await _transitionManager.confirmTransitionTo(
          location, action, _getConfirmation);
      if (ok) {
        _location = location;
        _action = action;
        _transitionManager.notify(this);
      } else {
        _revertPop(location);
      }
    }
    if (_popHandlerCompleter != null && !_popHandlerCompleter.isCompleted) {
      _popHandlerCompleter.complete();
    }
  }

  void _revertPop(Location fromLocation) {
    var toLocation = _location;

    var toIndex = max(_allKeys.indexOf(toLocation.key), 0);
    var fromIndex = max(_allKeys.indexOf(fromLocation.key), 0);
    var delta = toIndex - fromIndex;
    if (delta != 0) {
      _popMode = PopMode.forceAndNotify;
      go(delta);
    }
  }

  String _createKey() => _r
      .nextInt((1 << 31) - 1)
      .toRadixString(36)
      .padRight(_keyLength)
      .substring(0, _keyLength);
}
