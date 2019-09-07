import 'dart:html';

import 'package:mockito/mockito.dart';

class MockHtmlWindowBase extends Mock implements WindowBase {}

class MockHtmlWindow extends Mock implements Window {
  WindowBase _opener;

  MockHtmlWindow({WindowBase opener}) {
    _opener = opener ?? new MockHtmlWindowBase();
  }
  @override
  WindowBase get opener => _opener;

  @override
  set opener(WindowBase opener) => _opener = opener;
}

class MockHtmlHistory extends Mock implements History {}

class MockHtmlLocation extends Mock implements Location {}

class MockHtmlDocument extends Mock implements Document {}

class MockHtmlNavigator extends Mock implements Navigator {}

class MockHtmlPopStateEvent extends Mock implements PopStateEvent {}
