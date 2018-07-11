import 'package:mockito/mockito.dart';

import 'package:history/src/browser/browser_history.dart';
import 'package:history/src/browser/hash_history.dart';

class MockBrowserHistory extends Mock implements BrowserHistory {}

class MockHashHistory extends Mock implements HashHistory {}
