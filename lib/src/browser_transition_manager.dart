import 'dart:async';
import 'dart:html';

import 'browser_history.dart';
import 'transition_manager.dart';

typedef HashChangeHandler = Function(Event e);
typedef PopStateChangeHandler = Function(Event e);

class BrowserTransitionManager<T extends BrowserHistory>
    extends TransitionManager<T> {
  int _listenerCount = 0;
  HashChangeHandler _hashChangeHandler;
  PopStateChangeHandler _popStateChangeHandler;
  bool _needsHashChangeHandler;

  BrowserTransitionManager(
      {HashChangeHandler hashChangeHandler,
      PopStateChangeHandler popStateChangeHandler,
      bool needsHashChangeHandler = false})
      : super() {
    _hashChangeHandler = hashChangeHandler;
    _popStateChangeHandler = popStateChangeHandler;
    _needsHashChangeHandler = needsHashChangeHandler;
  }

  @override
  void set prompt(nextPrompt) {
    if (prompt == null && nextPrompt != null) {
      _checkDomListeners(1);
    } else if (prompt != null && nextPrompt == null) {
      _checkDomListeners(-1);
    }
    super.prompt = nextPrompt;
  }

  @override
  StreamSubscription<T> listen(void onData(T transition),
      {Function onError, void onDone(), bool cancelOnError}) {
    var toWrap = super.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
    return new _BrowserStreamSubscription(toWrap, onCancel: _onCancel);
  }

  void _checkDomListeners(int delta) {
    _listenerCount += delta;
    if (_listenerCount == 1) {
      window.addEventListener('popstate', _popStateChangeHandler);
      if (_needsHashChangeHandler) {
        window.addEventListener('hashchange', _hashChangeHandler);
      }
    } else if (_listenerCount == 0) {
      window.removeEventListener('popstate', _popStateChangeHandler);
      if (_needsHashChangeHandler) {
        window.removeEventListener('hashchange', _hashChangeHandler);
      }
    }
  }

  void _onCancel() {
    _checkDomListeners(-1);
  }
}

class _BrowserStreamSubscription<T> extends StreamSubscription<T> {
  final StreamSubscription<T> wrapped;
  final void Function() onCancel;

  _BrowserStreamSubscription(this.wrapped, {this.onCancel});

  @override
  Future cancel() {
    if (onCancel != null) {
      onCancel();
    }
    return wrapped.cancel();
  }

  @override
  void onData(void handleData(T data)) => wrapped.onData(handleData);

  @override
  void onError(Function handleError) => wrapped.onError(handleError);

  @override
  void onDone(void handleDone()) => wrapped.onDone(handleDone);

  @override
  void pause([Future resumeSignal]) => wrapped.pause(resumeSignal);

  @override
  void resume() => wrapped.resume();

  @override
  bool get isPaused => wrapped.isPaused;

  @override
  Future<E> asFuture<E>([E value]) => wrapped.asFuture(value);
}
