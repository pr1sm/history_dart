import 'dart:async';

import 'location.dart';
import 'utils/utils.dart' show Confirmation, ConfirmationCallback;

typedef void ReliqueshPrompt();

class TransitionManager<T> extends Stream<T> {
  dynamic _prompt = null;

  StreamController<T> _controller = new StreamController<T>.broadcast();

  dynamic get prompt => _prompt;

  ReliqueshPrompt setPrompt(nextPrompt) {
    if (_prompt != null) {
      print('WARNING: A history supports only one prompt at a time');
    }

    _prompt = nextPrompt;

    return () {
      if (_prompt == nextPrompt) {
        _prompt = null;
      }
    };
  }

  confirmTransitionTo(Location location, dynamic action,
      Confirmation getConfirmation, ConfirmationCallback callback) {
    if (_prompt != null) {
      final result = (_prompt is Function) ? prompt(location, action) : prompt;

      if (result is String) {
        getConfirmation(result, callback);
      } else {
        callback(result != false);
      }
    } else {
      callback(true);
    }
  }

  @override
  StreamSubscription<T> listen(void onData(T transition),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _controller.stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  void notify(T transition) {
    _controller.add(transition);
  }
}
