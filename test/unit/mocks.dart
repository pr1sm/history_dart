import 'package:mockito/mockito.dart';

import 'package:history/src/core/history.dart';
import 'package:history/src/core/location.dart';
import 'package:history/src/core/memory_history.dart';

class MockHistory extends Mock implements History {}

class MockLocation extends Mock implements Location {}

class MockMemoryHistory extends Mock implements MemoryHistory {}
