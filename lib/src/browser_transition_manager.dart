import 'dart:async';
import 'dart:html';

import 'browser_history.dart';
import 'transition_manager.dart';

typedef HashChangeHandler = Function(Event e);
typedef PopStateChangeHandler = Function(Event e);

class BrowserTransitionManager<T extends BrowserHistory>
    extends TransitionManager<T> {
  bool _needsHashChangeHandler;
  int _domCheck;
  HashChangeHandler _hashChangeHandler;
  PopStateChangeHandler _popStateChangeHandler;
  StreamController<T> _controller;

  BrowserTransitionManager(
      {HashChangeHandler hashChangeHandler,
      PopStateChangeHandler popStateChangeHandler,
      bool needsHashChangeHandler = false})
      : super() {
    _domCheck = 0;
    _hashChangeHandler = hashChangeHandler;
    _popStateChangeHandler = popStateChangeHandler;
    _needsHashChangeHandler = needsHashChangeHandler;
    _controller = new StreamController<T>.broadcast(
        onCancel: _onControllerCancel, onListen: _onControllerListen);
  }

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
    _controller.add(transition);
  }

  void _handleDomListener(int delta) {
    // no change: do nothing
    if (delta == 0) {
      return;
    }
    int nextDomCheck = (_domCheck + delta).clamp(0, 2);
    if (_domCheck == 0 && nextDomCheck != 0) {
      window.addEventListener('popstate', _popStateChangeHandler);
      if (_needsHashChangeHandler) {
        window.addEventListener('hashchange', _hashChangeHandler);
      }
    } else if (_domCheck != 0 && nextDomCheck == 0) {
      window.removeEventListener('popstate', _popStateChangeHandler);
      if (_needsHashChangeHandler) {
        window.removeEventListener('hashchange', _hashChangeHandler);
      }
    }
    _domCheck = nextDomCheck;
  }

  void _onControllerCancel() => _handleDomListener(-1);

  void _onControllerListen() => _handleDomListener(1);
}
