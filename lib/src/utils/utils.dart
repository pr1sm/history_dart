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

import 'dart:async' show Future;

import '../core/location.dart';

/// The type of History transition
///
/// Represents the valid transitions that can change the History list:
/// * PUSH - add a entry to the list
/// * REPLACE - replace the current entry in the list with a entry
/// * POP - Remove the current entry from the list and go to the previous one
enum Action { push, replace, pop }

/// Type of hash added to the Hash History
///
/// Represents the character patterns that are inserted between a [Location]s
/// basename and path. This is only used with HashHistory
/// * SLASH (default) - use '#/' (e.g. '#/home')
/// * NOSLASH - use '#' (e.g. '#home')
/// * HASHBANG - use '#!/' (e.g. '#!/home')
enum HashType { slash, noSlash, hashbang }

/// How the PopStateEvent handler should behave
///
/// Represents the way in which BrowserHistory should handle the
/// PopStateEvent. This is used to prevent double confirmations and
/// other syncing issues that occur between BrowserHistory and the
/// window's history.
enum PopMode { normal, force, forceAndNotify }

/// Confirm History Transition given a [prompt]
///
/// When a History is in blocking mode, this is used to determine whether or
/// not a transition should be allowed.
typedef Future<bool> Confirmation(String prompt);

/// Produce a prompt message given [location] and [action]
///
/// This method is used to conditionally determine:
/// 1) Whether or not a prompt is needed
/// 2) What prompt message should be used
///
/// When a History is in blocking mode, this may be passed to a [Confirmation]
typedef Future<String> Prompt(Location location, Action action);

/// Get String value of [prompt]
///
/// This serves as a helper method to convert [prompt] to a String regardless
/// of whether [prompt] is already a String or a [Prompt].
///
/// When [prompt] is a [String], it is returned. When [prompt] is a [Prompt],
/// [location] and [action] are passed to it and the prompt is awaited until
/// it produces its result.
///
/// This method also validates [prompt] and throws an [ArgumentError] when
/// [prompt] is not a [String] or [Prompt].
Future<String> getPrompt(
    dynamic prompt, Location location, Action action) async {
  if (prompt is String) {
    return Future.value(prompt);
  }

  if (prompt is Prompt) {
    return await prompt(location, action);
  }

  throw ArgumentError.value(prompt, 'validatePrompt',
      'prompt has an invalid type! Valid types are Prompt or String');
}

/// Validate [path] as [String] or [Location]
///
/// This is a convenience method to validate [path] for use in History.push and
/// History.replace.
void validatePath(dynamic path) {
  if (path is! String && path is! Location) {
    throw ArgumentError.value(path,
        'Error: path (${path.runtimeType}) is not a valid type (expected String or Location)');
  }
}
