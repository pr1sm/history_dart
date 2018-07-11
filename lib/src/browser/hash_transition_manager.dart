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
    _controller = new StreamController<T>.broadcast(
        onCancel: _onControllerCancel, onListen: _onControllerListen);
  }

  bool get listeningToWindowEvents => _domCheck != 0;

  @override
  Stream<T> get stream => _controller.stream;

  @override
  void set prompt(nextPrompt) {
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
    int nextDomCheck = (_domCheck + delta).clamp(0, 2);
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
