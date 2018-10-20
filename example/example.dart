import 'dart:async';

import 'package:history/vm.dart';

Future<Null> main() async {
  Confirmation confirmation = (_) => new Future.value(true);

  MemoryHistory history = new MemoryHistory(getConfirmation: confirmation);

  // Listen for changes
  var sub = history.onChange.listen((updatedHistory) {
    var location = updatedHistory.location;
    print(
        'Transitioned to ${location.path} with action ${updatedHistory.action}!');
    print('State associated with this location: ${location.state}');
  });

  // Manipulate the history
  await history.push('/first');
  await history.push('/second', 'with a state');
  await history.replace('/third', {'with': 'a', 'state': 'object'});
  await history.goBack();
  await history.goForward();
  await history.go(-1);

  // Block transitions until they are confirmed by the user
  history.block('Are you sure you want to navigate?');

  // This call waits for a user confirmation before continuing
  history.push('/confirmed');

  // Use a more complex Prompt for more flexibilty
  Prompt prompt = (Location l, Action a) {
    if (l.path == '/logout') {
      return Future.value(
          'Logging out will cause you to lose all unsaved data!');
    } else if (a == Action.pop) {
      return Future.value('Are you sure you want to go back?');
    }
    return Future.value('Are you sure you want to navigate?');
  };
  history.block(prompt);

  // Prints different prompts based on the transition
  await history.goBack();
  await history.push('/logout');

  // Return to non-blocking mode
  history.unblock();

  // Stop listening
  sub.cancel();
}
