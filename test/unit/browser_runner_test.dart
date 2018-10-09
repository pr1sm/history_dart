@TestOn('browser')
import 'package:test/test.dart';

import 'browser/browser_history_test.dart' as browser_history_test;
import 'browser/browser_transition_manager_test.dart'
    as browser_transition_manager_test;
import 'browser/hash_history_test.dart' as hash_history_test;
import 'browser/hash_transition_manager_test.dart'
    as hash_transition_manager_test;
import 'utils/dom_utils_test.dart' as dom_utils_test;
import 'utils/hash_utils_test.dart' as hash_utils_test;

void main() {
  browser_history_test.main();
  browser_transition_manager_test.main();
  hash_history_test.main();
  hash_transition_manager_test.main();
  dom_utils_test.main();
  hash_utils_test.main();
}
