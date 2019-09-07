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
import 'dart:math';

import 'history.dart';
import 'location.dart';
import 'transition_manager.dart';
import '../utils/utils.dart' show Action, Confirmation, validatePath;

/// Mixin contains [MemoryHistory] specific definitions
abstract class MemoryMixin {
  /// Get the index of the current [Location]
  int get index;

  /// Get the array of entries stored in this [MemoryHistory]
  Iterable<Location> get entries;

  /// Checks if traveling [n] entries forward/backward is possible
  ///
  /// [n] functions similarly to [History.go()] -- a change relative to the
  /// current page, where the direction is determined by the sign of [n].
  bool canGo(int n);
}

/// Extension of [History] that stores all data in-memory
///
/// This class extends all functionality of the base [History] class and adds
/// extra functionality only supported in this variant.
class MemoryHistory extends History with MemoryMixin {
  Action _action;
  int _index;
  final Confirmation _getConfirmation;
  final int _keyLength;
  final Random _r;
  List<Location> _entries;
  Location _location;
  TransitionManager<MemoryHistory> _transitionManager;

  /// Construct a [MemoryHistory]
  ///
  /// Factory constructor takes the following parameters:
  /// * [initialEntries] - List of [String]s or [Location]s that this [History] will start with
  /// * [initialIndex] - The starting index of this [History]
  /// * [keyLength] - The length of keys generated for [Locations] when changes occur
  /// * [getConfirmation] - A [Confirmation] to use during blocking mode.
  MemoryHistory(
      {Iterable<dynamic> initialEntries,
      int initialIndex = 0,
      int keyLength = 6,
      Confirmation getConfirmation})
      : _keyLength = keyLength,
        _getConfirmation = getConfirmation,
        _r = Random() {
    initialEntries ??= [Location(pathname: '/')];
    _entries = initialEntries
        .where((i) => i is String || i is Location)
        .map((e) => (e is String)
            ? Location(pathname: e, key: _createKey())
            : Location.copy(e as Location,
                key: (e as Location).key ?? _createKey()))
        .toList();
    _index = initialIndex.clamp(0, _entries.length - 1).toInt();
    _transitionManager = TransitionManager<MemoryHistory>();
    _location = _entries[index];
    _action = Action.pop;
  }

  @override
  int get index => _index;

  @override
  Iterable<Location> get entries => _entries;

  @override
  int get length => _entries.length;

  @override
  Location get location => _location;

  @override
  Action get action => _action;

  @override
  bool get isBlocking => _transitionManager.prompt != null;

  @override
  Stream<MemoryHistory> get onChange => _transitionManager.stream;

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

    // If confirmed, update state and notify listeners
    var nextIndex = _index + 1;
    if (_entries.length > nextIndex) {
      _entries = _entries.sublist(0, nextIndex)..add(nextLocation);
    } else {
      _entries.add(nextLocation);
    }
    _index = nextIndex;
    _location = nextLocation;
    _action = nextAction;
    _transitionManager.notify(this);
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

    // If confirmed, update state and notify listeners
    _entries[_index] = nextLocation;
    _location = nextLocation;
    _action = nextAction;
    _transitionManager.notify(this);
  }

  @override
  bool canGo(int n) {
    var testIndex = _index + n;
    return testIndex >= 0 && testIndex < _entries.length;
  }

  @override
  Future<Null> go(int n) async {
    // Compute next location and action
    var nextIndex = (_index + n).clamp(0, _entries.length - 1).toInt();
    var nextAction = Action.pop;
    var nextLocation = _entries[nextIndex];

    // Await Confirmation
    bool ok = await _transitionManager.confirmTransitionTo(
        nextLocation, nextAction, _getConfirmation);
    if (ok) {
      // If confirmed, update state and notify listeners
      _index = nextIndex;
      _location = nextLocation;
      _action = nextAction;
      _transitionManager.notify(this);
    } else {
      // Mimic browser behavior of DOM histories by causing a render after a cancelled pop.
      _transitionManager.notify(this);
    }
  }

  @override
  void block(dynamic prompt) => _transitionManager.prompt = prompt;

  @override
  void unblock() => _transitionManager.prompt = null;

  String _createKey() => _r
      .nextInt((1 << 31) - 1)
      .toRadixString(36)
      .padRight(_keyLength)
      .substring(0, _keyLength);
}
