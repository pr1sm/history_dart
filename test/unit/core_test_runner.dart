@TestOn('browser || vm')
import 'package:test/test.dart';

import 'core/location_test.dart' as location_test;
import 'core/memory_history_test.dart' as memory_history_test;
import 'core/transition_manager_test.dart' as transition_manager_test;

void main() {
  location_test.main();
  memory_history_test.main();
  transition_manager_test.main();
}
