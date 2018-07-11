import 'dart:html';

import 'package:mockito/mockito.dart';

class MockHtmlWindow extends Mock implements Window {}

class MockHtmlHistory extends Mock implements History {}

class MockHtmlLocation extends Mock implements Location {}

class MockHtmlDocument extends Mock implements Document {}

class MockHtmlNavigator extends Mock implements Navigator {}

class MockHtmlPopStateEvent extends Mock implements PopStateEvent {}
