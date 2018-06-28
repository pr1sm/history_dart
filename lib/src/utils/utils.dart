import 'dart:async' show Future, FutureOr;
import 'dart:math';

import '../location.dart';

/// Confirm History Transition given a [prompt]
///
/// When a History is in blocking mode, this is used to determine whether or
/// not a transition should be allowed. [prompt] should only be a [String] or
/// a [Prompt].
///
/// Consider using [getPrompt] to determine whether or not [prompt] is
/// valid.
typedef FutureOr<bool> Confirmation(dynamic prompt);

/// Produce a prompt message given [location] and [action]
///
/// This method is used to conditionally determine:
/// 1) Whether or not a prompt is needed
/// 2) What prompt message should be used
///
/// When a History is in blocking mode, this may be passed to a [Confirmation]
typedef FutureOr<String> Prompt(Location location, Action action);

/// Get String value of [prompt]
///
/// This serves as a helper method to convert [prompt] to a String regardless
/// of whether [prompt] is already a String or a [Prompt]. This is useful
/// during the implementation of a [Confirmation] to properly receive a prompt
/// message.
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
    return prompt;
  }

  if (prompt is Prompt) {
    return await prompt(location, action);
  }

  throw new ArgumentError.value(prompt, 'validatePrompt',
      'prompt has an invalid type! Valid types are Prompt or String');
}

/// The type of History transition
///
/// Represents the valid transitions that can change the History list:
/// * PUSH - add a new entry to the list
/// * REPLACE - replace the current entry in the list with a new entry
/// * POP - Remove the current entry from the list and go to the previous one
enum Action { PUSH, REPLACE, POP }

/// Bound [n] with [lowerBound] and [upperBound]
///
/// Utility method to help perform a two-way bound of [n].
T clamp<T>(T n, T lowerBound, T upperBound) =>
    min(max(T, upperBound), lowerBound);
