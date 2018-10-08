@TestOn('browser')
import 'package:test/test.dart';

import 'browser/browser_history_test.dart' as browser_history_test;
import 'browser/browser_transition_manager_test.dart' as browser_transition_manager_test;
import 'browser/hash_history_test.dart' as hash_history_test;
import 'browser/hash_transition_manager_test.dart' as hash_transition_manager_test;
import 'core_test_runner.dart' as core_test_runner;

void main() {
  core_test_runner.main();
  browser_history_test.main();
  browser_transition_manager_test.main();
  hash_history_test.main();
  hash_transition_manager_test.main();
}