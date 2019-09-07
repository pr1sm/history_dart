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
import '../utils/utils.dart' show Action, Confirmation, getPrompt;

class TransitionManager<T> {
  dynamic _prompt;

  StreamController<T> _controller = StreamController<T>.broadcast();

  Stream<T> get stream => _controller.stream;

  dynamic get prompt => _prompt;

  set prompt(dynamic nextPrompt) {
    if (_prompt != null && nextPrompt != null) {
      print(
          'WARNING: A history supports only one prompt at a time! Current Prompt will be overridden');
    }

    _prompt = nextPrompt;
  }

  Future<bool> confirmTransitionTo(
      Location location, Action action, Confirmation getConfirmation) async {
    if (_prompt != null) {
      final result = await getPrompt(_prompt, location, action);
      if (getConfirmation == null) {
        print(
            'WARNING: In order to use a prompt message, a non-null Confirmation method is needed!');
        return Future.value(true);
      }
      return getConfirmation(result);
    }
    return Future.value(true);
  }

  void notify(T transition) {
    if (transition != null) {
      _controller.add(transition);
    }
  }
}
