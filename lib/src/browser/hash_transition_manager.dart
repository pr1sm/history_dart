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
import 'dart:html';

import 'hash_history.dart';
import '../core/transition_manager.dart';

typedef HashChangeHandler = Function(Event e);

class HashTransitionManager<T extends HashHistory>
    extends TransitionManager<T> {
  int _domCheck;
  HashChangeHandler _hashChangeHandler;

  StreamController<T> _controller;

  HashTransitionManager({HashChangeHandler hashChangeHandler}) : super() {
    _domCheck = 0;
    _hashChangeHandler = hashChangeHandler ?? (_) {};
    _controller = StreamController<T>.broadcast(
        onCancel: _onControllerCancel, onListen: _onControllerListen);
  }

  bool get listeningToWindowEvents => _domCheck != 0;

  @override
  Stream<T> get stream => _controller.stream;

  @override
  set prompt(nextPrompt) {
    if (prompt == null && nextPrompt != null) {
      _handleDomListener(1);
    } else if (prompt != null && nextPrompt == null) {
      _handleDomListener(-1);
    }
    super.prompt = nextPrompt;
  }

  @override
  void notify(T transition) {
    if (transition != null) {
      _controller.add(transition);
    }
  }

  void _handleDomListener(int delta) {
    // no change: do nothing
    if (delta == 0) {
      return;
    }
    int nextDomCheck = (_domCheck + delta).clamp(0, 2).toInt();
    if (_domCheck == 0 && nextDomCheck != 0) {
      window.addEventListener('hashchange', _hashChangeHandler);
    } else if (_domCheck != 0 && nextDomCheck == 0) {
      window.removeEventListener('hashchange', _hashChangeHandler);
    }
    _domCheck = nextDomCheck;
  }

  void _onControllerCancel() => _handleDomListener(-1);

  void _onControllerListen() => _handleDomListener(1);
}
