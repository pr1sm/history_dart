import 'dart:async';

import 'location.dart';
import 'utils/utils.dart' show Action, Confirmation, Prompt, getPrompt;

class TransitionManager<T> {
  dynamic _prompt = null;

  StreamController<T> _controller = new StreamController<T>.broadcast();

  Stream<T> get stream => _controller.stream;

  Prompt get prompt => _prompt;

  void set prompt(Prompt nextPrompt) {
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
        return new Future.value(true);
      }
      return getConfirmation(result);
    }
    return new Future.value(true);
  }

  void notify(T transition) {
    if (transition != null) {
      _controller.add(transition);
    }
  }
}
