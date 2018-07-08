import 'dart:async';
import 'dart:html' as html;
import 'dart:math';

import 'history.dart';
import 'location.dart';
import 'transition_manager.dart';
import 'hash_transition_manager.dart';
import 'utils/dom_utils.dart' show DomUtils;
import 'utils/hash_utils.dart' show EncoderDecoder, HashPathCoders, convert;
import 'utils/path_utils.dart'
    show addLeadingSlash, stripTrailingSlash, hasBasename, stripBasename;
import 'utils/utils.dart' show Action, Confirmation, HashType, validatePath;

/// Mixin contains [HashHistory] specific definitions
abstract class HashMixin {
  /// Character pattern that will be used for the hash
  ///
  /// (See [HashType] for more info)
  HashType get hashType;
}

/// Extension of [History] that supports Legacy Browsers
///
/// This class extends all functionality of the base [History] class and adds
/// extra functionality only supported in this variant.
class HashHistory extends History with BasenameMixin, HashMixin {
  HashType _hashType;
  String _basename;
  Location _location;
  Action _action;
  Confirmation _getConfirmation;
  EncoderDecoder _ed;

  bool _forceNextPop = false;
  String _ignorePath = null;

  List<String> _allPaths;

  html.History _globalHistory = html.window.history;
  TransitionManager<HashHistory> _transitionManager;
  final DomUtils _domUtils = new DomUtils();

  /// Construct a new [HashHistory]
  ///
  /// Factory constructor takes the following parameters:
  /// * [basename] - The base of all paths for this [HashHistory]
  /// * [hashType] - The type of charater pattern to insert as the hash for paths
  /// * [getConfirmation] - A [Confirmation] to use during blocking mode.
  HashHistory(
      {String basename = '',
      HashType hashType = HashType.slash,
      Confirmation getConfirmation}) {
    if (!_domUtils.canUseDom) {
      throw new StateError('Hash History needs a DOM');
    }

    _basename =
        (basename != null) ? stripTrailingSlash(addLeadingSlash(basename)) : '';
    _hashType = hashType ?? HashType.slash;
    _getConfirmation = getConfirmation ?? _domUtils.getConfirmation;
    _ed = HashPathCoders[_hashType];

    final path = _hashPath;
    final encodedPath = _ed.encodePath(path);
    if (path != encodedPath) {
      _replaceHashPath(encodedPath);
    }

    _location = _domLocation;
    _action = Action.pop;
    _allPaths = [_domLocation.path];

    _transitionManager = new HashTransitionManager<HashHistory>(
        hashChangeHandler: _handleHashChange);
  }

  @override
  Action get action => _action;

  @override
  bool get isBlocking => _transitionManager.prompt != null;

  @override
  HashType get hashType => _hashType;

  @override
  int get length => _globalHistory.length;

  @override
  Location get location => _location;

  @override
  String get basename => _basename;

  @override
  Stream<HashHistory> get onChange => _transitionManager.stream;

  @override
  Future<Null> push(dynamic path, [dynamic state]) async {
    validatePath(path);
    if (state != null) {
      print('WARNING: HashHistory does not support state; it will be ignored');
    }

    // Compute next location and action
    Location nextLocation = (path is String)
        ? new Location(pathname: path)
        : new Location.copy(path);
    var nextAction = Action.push;
    nextLocation.relateTo(_location);

    bool ok = await _transitionManager.confirmTransitionTo(
        nextLocation, nextAction, _getConfirmation);
    if (!ok) {
      return;
    }

    final nextPath = nextLocation.path;
    final encodedPath = _ed.encodePath(basename + nextPath);
    var hashChanged = _hashPath != encodedPath;

    if (hashChanged) {
      // We can't tell if hashchange was caused by a push, so we force a
      // notify here and ignore the HashChangeEvent. the caveat here is that
      // other histories will view this as a pop.
      _ignorePath = nextPath;
      _pushHashPath(encodedPath);

      var prevIndex = _allPaths.lastIndexOf(_location.path);
      _allPaths = _allPaths.sublist(0, prevIndex == -1 ? 0 : prevIndex + 1)
        ..add(nextPath);

      _transitionManager.notify(this);
    } else {
      print(
          'WARNING: Hash History cannot Push the same path; a new entry will NOT be added to the history stack');
      // TODO: should we notify listeners in this case?
    }
  }

  @override
  Future<Null> replace(dynamic path, [dynamic state]) async {
    validatePath(path);
    if (state != null) {
      print('WARNING: HashHistory does not support state; it will be ignored');
    }

    // Compute next location and action
    Location nextLocation = (path is String)
        ? new Location(pathname: path)
        : new Location.copy(path);
    var nextAction = Action.replace;
    nextLocation.relateTo(_location);

    bool ok = await _transitionManager.confirmTransitionTo(
        nextLocation, nextAction, _getConfirmation);
    if (!ok) {
      return;
    }

    final nextPath = nextLocation.path;
    final encodedPath = _ed.encodePath(basename + nextPath);
    var hashChanged = _hashPath != encodedPath;

    if (hashChanged) {
      // We can't tell if hashchange was caused by a push, so we force a
      // notify here and ignore the HashChangeEvent. the caveat here is that
      // other histories will view this as a pop.
      _ignorePath = nextPath;
      _replaceHashPath(encodedPath);
    }

    var prevIndex = _allPaths.lastIndexOf(_location.path);
    if (prevIndex != -1) {
      _allPaths[prevIndex] = nextPath;
    }

    _transitionManager.notify(this);
  }

  @override
  Future<Null> go(int n) async {
    if (!_domUtils.supportsGoWithoutReloadUsingHash) {
      print(
          'WARNING: Hash History go(n) causes a full page reload in the browser');
    }
    _globalHistory.go(n);
  }

  @override
  void block(dynamic prompt) => _transitionManager.prompt = prompt;

  @override
  void unblock() => _transitionManager.prompt = null;

  Location get _domLocation {
    var path = _ed.decodePath(_hashPath);

    if (basename != null && !hasBasename(path, basename)) {
      print(
          'WARNING: You are attempting to use a basename on a page whose URL path does not begin with the basename. Expected path "${path}" to begin with basename "${basename}".');
    }

    if (basename != null) {
      path = stripBasename(path, basename);
    }

    return new Location(pathname: path);
  }

  String get _hashPath {
    // We can't use window.location.hash here because it's not
    // consistent across browsers -- Firefox will pre-decode it
    final href = html.window.location.href;
    final hashIndex = href.indexOf('#');
    return hashIndex == -1 ? '' : href.substring(hashIndex + 1);
  }

  void _pushHashPath(String path) {
    html.window.location.hash = path;
  }

  void _replaceHashPath(String path) {
    final hashIndex = html.window.location.href.indexOf('#');
    html.window.location.replace(
        '${html.window.location.href.substring(0, hashIndex >= 0 ? hashIndex : 0)}#${path}');
  }

  _handleHashChange(html.Event e) async {
    final path = _hashPath;
    final encodedPath = _ed.encodePath(path);

    if (path != encodedPath) {
      // ensure we have properly encoded path
      _replaceHashPath(encodedPath);
    } else {
      var location = _domLocation;
      var prevLocation = convert(html.window.location);

      if (!_forceNextPop && location == prevLocation) {
        return; // not all hash changes are location changes
      }

      if (_ignorePath == location.path) {
        return; // Ignore this change; we've already notified listeners in push/replace
      }

      _ignorePath = null;

      await _handlePop(location);
    }
  }

  Future<Null> _handlePop(Location location) async {
    if (_forceNextPop) {
      _forceNextPop = false;
      _transitionManager.notify(this);
    } else {
      var action = Action.pop;
      bool ok = await _transitionManager.confirmTransitionTo(
          location, action, _getConfirmation);
      if (ok) {
        _transitionManager.notify(this);
      } else {
        _revertPop(location);
      }
    }
  }

  void _revertPop(Location fromLocation) {
    var toLocation = _location; // convert(html.window.location);

    var toIndex = max(_allPaths.lastIndexOf(toLocation.path), 0);
    var fromIndex = max(_allPaths.lastIndexOf(fromLocation.path), 0);
    var delta = toIndex - fromIndex;
    if (delta != 0) {
      _forceNextPop = true;
      go(delta);
    }
  }
}
