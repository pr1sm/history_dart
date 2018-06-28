import 'dart:async';

import 'location.dart';
import 'utils/utils.dart' show Action, Confirmation, getPrompt;

class TransitionManager<T> extends Stream<T> {
  dynamic _prompt = null;

  StreamController<T> _controller = new StreamController<T>.broadcast();

  dynamic get prompt => _prompt;

  void set prompt(nextPrompt) {
    if (_prompt != null) {
      print('WARNING: A history supports only one prompt at a time');
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
        return true;
      }
      return getConfirmation(result);
    } else {
      return true;
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
