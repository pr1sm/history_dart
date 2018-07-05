import 'dart:html';

import 'package:mockito/mockito.dart';

class MockWindow extends Mock implements Window {}

class MockHistory extends Mock implements History {}

class MockLocation extends Mock implements Location {}

class MockDocument extends Mock implements Document {}

class MockNavigator extends Mock implements Navigator {}

class MockPopStateEvent extends Mock implements PopStateEvent {}
