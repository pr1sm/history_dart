import 'dart:html';

import 'package:mockito/mockito.dart';

import 'package:history/src/browser/browser_history.dart';
import 'package:history/src/browser/hash_history.dart';

class MockHtmlWindow extends Mock implements Window {
  MockHtmlDocument mockDocument;
  MockHtmlNavigator mockNavigator;
  _MockHtmlHistory mockHistory;
  bool mockPrint;

  MockHtmlWindow({this.mockPrint = false}) {
    mockNavigator = new MockHtmlNavigator();
    when(mockNavigator.userAgent).thenReturn(
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36');
    mockDocument = new MockHtmlDocument();
    mockHistory = new _MockHtmlHistory(mockPrint: mockPrint);
  }

  @override
  History get history => mockHistory;

  @override
  Location get location => mockHistory.mockLocation;

  @override
  Document get document => mockDocument;

  @override
  Navigator get navigator => mockNavigator;
}

class _MockHtmlHistory extends Mock implements History {
  int mockIndex;
  bool mockPrint;
  List<Location> mockLocations;

  _MockHtmlHistory({this.mockPrint = false}) {
    mockIndex = 0;
    mockLocations = [new _MockHtmlLocation(this, mockPrint: mockPrint)];
  }

  _MockHtmlLocation get mockLocation => mockLocations[mockIndex];

  void mockOnReplace(_MockHtmlLocation location) {
    if (mockPrint) {
      print('mock on replace ${location.href}');
    }
    mockLocations[mockIndex] = location;
    window.dispatchEvent(new HashChangeEvent('hashchange'));
  }

  void mockOnPush(_MockHtmlLocation location) {
    if (mockPrint) {
      print('mock on push ${location.href}');
    }
    var nextIndex = mockIndex + 1;
    if (mockLocations.length > nextIndex) {
      mockLocations = mockLocations.sublist(0, nextIndex)..add(location);
    } else {
      mockLocations.add(location);
    }
    mockIndex = nextIndex;
    window.dispatchEvent(new HashChangeEvent('hashchange'));
  }

  @override
  int get length => mockLocations.length;

  @override
  void go([int delta]) {
    if (mockPrint) {
      print('mock go delta: ${delta}');
    }
    delta ??= 0;
    mockIndex = (mockIndex + delta).clamp(0, mockLocations.length - 1);
    if (mockPrint) {
      print('mock go mockIndex: ${mockIndex}');
    }
    window.dispatchEvent(new HashChangeEvent('hashchange'));
  }
}

class _MockHtmlLocation extends Mock implements Location {
  bool mockPrint;
  String mockPath = '/start';
  String mockHash = '';
  _MockHtmlHistory mockHistory;

  _MockHtmlLocation(this.mockHistory, {this.mockPrint = false});

  @override
  String get href => '${mockPath}${mockHash.isNotEmpty ? '#' : ''}${mockHash}';

  @override
  void set href(String newHref) {
    final hashIndex = newHref.indexOf('#');
    String newMockHash =
        hashIndex == -1 ? '' : newHref.substring(hashIndex + 1);
    String newMockPath =
        newHref.substring(0, hashIndex >= 0 ? hashIndex : null);

    _MockHtmlLocation newLocation =
        new _MockHtmlLocation(mockHistory, mockPrint: mockPrint)
          ..mockPath = newMockPath
          ..mockHash = newMockHash;
    if (mockPrint) {
      print('mock href set (push) ${href} => ${newLocation.href}');
    }
    mockHistory.mockOnPush(newLocation);
  }

  @override
  String get hash => mockHash;

  @override
  void set hash(String newHash) {
    _MockHtmlLocation newLocation = new _MockHtmlLocation(mockHistory)
      ..mockPath = mockPath
      ..mockHash = newHash;
    if (mockPrint) {
      print('mock hash set (push) ${href} => ${newLocation.href}');
    }
    mockHistory.mockOnPush(newLocation);
  }

  @override
  void replace(String url) {
    final oldHref = href;
    final hashIndex = url.indexOf('#');
    mockHash = hashIndex == -1 ? '' : url.substring(hashIndex + 1);
    mockPath = url.substring(0, hashIndex >= 0 ? hashIndex : null);

    if (mockPrint) {
      print('mock replace: ${oldHref} => ${href}');
    }
    mockHistory.mockOnReplace(this);
  }
}

class MockHtmlWindowNoImpl extends Mock implements Window {}

class MockHtmlHistory extends Mock implements History {}

class MockHtmlLocation extends Mock implements Location {}

class MockHtmlDocument extends Mock implements Document {}

class MockHtmlNavigator extends Mock implements Navigator {}

class MockHtmlPopStateEvent extends Mock implements PopStateEvent {}

class MockBrowserHistory extends Mock implements BrowserHistory {}

class MocKHashHistory extends Mock implements HashHistory {}
