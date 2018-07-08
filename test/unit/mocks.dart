import 'package:mockito/mockito.dart';

import 'package:history/src/history.dart';
import 'package:history/src/location.dart';
import 'package:history/src/memory_history.dart';

class MockHistory extends Mock implements History {}

class MockLocation extends Mock implements Location {}

class MockMemoryHistory extends Mock implements MemoryHistory {}
