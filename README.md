[![Build Status](https://travis-ci.com/pr1sm/history_dart.svg?branch=master)](https://travis-ci.com/pr1sm/history_dart)
[![codecov](https://codecov.io/gh/pr1sm/history_dart/branch/master/graph/badge.svg)](https://codecov.io/gh/pr1sm/history_dart)

# History

`history` lets you manage session history in any environment. It uses a subset of the HTML5 session history API and brings it to the VM and Browsers that don't support session History manipulation. `history` abstracts away the differences in environments using a minimal API. This lets you easily change the history stack, navigate to different locations in your app, confirm navigation changes using custom prompts, and persist any custom state you want between sessions. 

## Usage

`history` provides 3 variants to use based on your environment:

- `MemoryHistory` - For use in non-DOM environments such as the dart vm. All session information is stored in memory. This variant can be used in the browser if needed.
- `BrowserHistory` - For use in modern browsers that support the HTML5 session history API. session information is stored using the browser's history API, allowing history manipulation from other sources to be synced with this `history`.
- `HashHistory` - For use in legacy browsers. Relies on the hash-based paths and syncs with the browsers `hashchange` events. Custom states are not supported.

To use `history`, simply import and go!
```dart
// For use in Browser
import 'package:history/history.dart';
// For use in VM
// import 'package:history/vm.dart'; 

const history = new BrowserHistory();

// Listen for changes
const sub = history.onChange.listen((updatedHistory) {
  const location = updatedHistory.location;
  print('Transitioned to ${location.path} with action ${updatedHistory.action}!');
  print('State associated with this location: ${location.state}');
});

// Manipulate the history
history.push('/first');
history.push('/second', 'with a state');
history.replace('/third', {'with': 'a', 'state': 'object'});
history.goBack();
history.goForward();
history.go(-1);

// Block transitions until they are confirmed by the user
history.block('Are you sure you want to navigate?');

// This call waits for a user confirmation before continuing
history.push('/confirmed');

// Use a more complex Prompt for more flexibilty
history.block((Location l, Action a) {
  if (l.path == '/logout') {
    return 'Logging out will cause you to lose all unsaved data!'
  } else if (action == Action.pop) {
    return 'Are you sure you want to go back?';
  }
  return 'Are you sure you want to navigate?';
});

// Prints different prompts based on the transition
history.goBack();
history.push('/logout');

// Return to non-blocking mode
history.unblock();

// Stop listening
sub.cancel();
```

## Inspiration

This project is largely based on [`history`](https://www.npmjs.com/package/history), an npm package provided by [React Training](https://reacttraining.com/)
