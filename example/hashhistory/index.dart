import 'dart:html';
import 'dart:math';

import 'package:history/history.dart';

void main() {
  var count = 0;
  var history = new HashHistory();
  var forward = querySelector('#forward');
  var back = querySelector('#back');
  var replace = querySelector('#replace');
  var prompted = querySelector('#prompted');
  var pageContent = querySelector('#pageContent');

  history.onChange.listen((h) {
    print('transitioned to (${h.location}) using (${h.action})');
    if (h.isBlocking) {
      h.unblock();
      pageContent.setInnerHtml('''
        <h3>Prompted Transition Confirmed!</h3>
        ''');
    } else {
      var countStr = h.location.pathname;
      countStr = countStr.length < 1 ? '0' : countStr.substring(1);
      count = int.tryParse(countStr) ?? 0;
      pageContent.setInnerHtml('''
        <h3>Current Page Index: ${count}</h3>
        ''');
    }
  });

  forward.onClick.listen((_) {
    count += 1;
    history.push('/${count}', {'count': count, 'prompted': false});
  });

  back.onClick.listen((_) {
    count = max(0, count - 1);
    history.push('/${count}');
  });

  replace.onClick.listen((_) {
    count = 0;
    history.replace('/${count}');
  });

  prompted.onClick.listen((_) async {
    count = 0;
    history.block(
        'This is a prompted transition, Press "OK" to contine or "Cancel" to cancel');
    await history.replace('/prompted');
    if (history.action != Action.replace) {
      history.unblock();
    }
  });
}
