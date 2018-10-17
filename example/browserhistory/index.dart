import 'dart:html';
import 'dart:math';

import 'package:history/history.dart';

void main() {
  var count = 0;
  var history = new BrowserHistory(basename: '/browserhistory');
  var forward = querySelector('#forward');
  var back = querySelector('#back');
  var replace = querySelector('#replace');
  var prompted = querySelector('#prompted');
  var pageContent = querySelector('#pageContent');

  history.onChange.listen((h) {
    print('transitioned to (${h.location}) using (${h.action})');
    if (h.location.state['prompted'] == true) {
      pageContent.setInnerHtml('''
        <h3>Prompted Transition Confirmed!</h3>
        ''');
    } else {
      pageContent.setInnerHtml('''
        <h3>Current Page Index: ${count}</h3>
        ''');
    }
  });

  forward.onClick.listen((_) {
    count = history.location.state == null
        ? 1
        : int.tryParse(history.location.state['count'].toString()) + 1;
    history.push('/${count}', {'count': count, 'prompted': false});
  });

  back.onClick.listen((_) {
    count = max(
        0,
        history.location.state == null
            ? 0
            : int.tryParse(history.location.state['count'].toString()) - 1);
    history.push('/${count}', {'count': count, 'prompted': false});
  });

  replace.onClick.listen((_) {
    count = 0;
    history.replace('/${count}', {'count': count, 'prompted': false});
  });

  prompted.onClick.listen((_) async {
    count = 0;
    history.block(
        'This is a prompted transition, Press "OK" to contine or "Cancel" to cancel');
    await history.replace('/prompted', {'count': count, 'prompted': true});
    history.unblock();
  });
}
