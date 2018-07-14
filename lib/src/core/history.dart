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

import 'location.dart';
import '../utils/utils.dart';

abstract class History {
  /// The number of entries in the History list
  int get length;

  /// The current location
  Location get location;

  /// The current action
  Action get action;

  /// Whether or not this [History] is in blocking mode
  bool get isBlocking;

  /// Stream of changes to this [History] list
  Stream<History> get onChange;

  /// Push an entry ([String] or [Location]) on to the History list
  ///
  /// You can optionally add a [state] object to add information about the
  /// entry that doesn't appear in the path.
  ///
  /// This method will throw an [ArgumentError] if anything other than
  /// [String] or [Location] is given to it.
  void push(dynamic path, [dynamic state]);

  /// Replace the current entry with a new one ([String] or [Location]) on to the History list
  ///
  /// You can optionally add a [state] object to add information about the
  /// entry that doesn't appear in the path.
  ///
  /// This method will throw an [ArgumentError] if anything other than
  /// [String] or [Location] is given to it.
  void replace(dynamic path, [dynamic state]);

  /// Travel [n] entries forward or backward on the History list
  ///
  /// The direction of travel is determined by the sign of [n] and the next entry is determined
  /// relative to the current entry.
  /// ```
  /// h.go(0); // This has no effect
  /// h.go(1); // Travel to the next entry on the list
  /// h.go(-1); // Travel to the previous entry on the list
  /// ```
  ///
  /// NOTE: The destination entry is calculated by clamping on the bounds of the list:
  /// ```
  /// // When there is only 1 previous entry on the list,
  /// // The following is logically equivalent
  /// h.go(-1);
  /// h.go(-100);
  ///
  /// // When there is only 1 next entry on the list
  /// // The following is logically equivalent
  /// h.go(1);
  /// h.go(100);
  /// ```
  void go(int n);

  /// Travel to the previous entry on the History list (if it exists)
  ///
  /// This is a convenience method for [go()]
  /// ```
  /// // These are logically equivalent
  /// h.goBack();
  /// h.go(-1);
  /// ```
  ///
  void goBack() => go(-1);

  /// Travel to the next entry on the History list (if it exists)
  ///
  /// This is a convenience method for [go()]
  /// ```
  /// // These are logically equivalent
  /// h.goForward();
  /// h.go(1);
  /// ```
  void goForward() => go(1);

  /// Enable blocking mode with the given [prompt]
  ///
  /// In blocking mode, a [Confirmation] will be called before proceeding with the transition.
  /// This prevents listeners of History transitions from being notified until the [Confirmation]
  /// is handled.
  ///
  /// [prompt] must be a [String] or [Prompt]. Use a [String] to use the same prompt message
  /// for all transitions. This is useful when the same message can be applied to all transitions.
  /// Use a [Prompt] when you want to either enable a prompt conditionally and/or pass different
  /// prompt messages based on the transition.
  ///
  /// If blocking mode is already enabled, this method will update the [prompt] that is used.
  void block(dynamic prompt);

  /// Disable blocking mode
  ///
  /// If blocking mode is enabled, this method will turn that mode off, allowing all transitions
  /// to occur without responding to a [Confirmation]. If blocking mode is already disabled, this
  /// method will have no effect.
  void unblock();
}

/// Mixin for [History] to support adding a prefix to paths
abstract class BasenameMixin {
  /// Prefix added to paths if it isn't already included
  String get basename;
}
