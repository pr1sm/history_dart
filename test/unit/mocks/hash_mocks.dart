import 'dart:html';

import 'package:mockito/mockito.dart';

import 'html_mocks.dart';

class MockHashHtmlWindow extends MockHtmlWindow {
  MockHtmlDocument mockDocument;
  MockHtmlNavigator mockNavigator;
  MockHashHtmlHistory mockHistory;
  bool mockPrint;

  MockHashHtmlWindow({this.mockPrint = false}) {
    mockNavigator = new MockHtmlNavigator();
    when(mockNavigator.userAgent).thenReturn(
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36');
    mockDocument = new MockHtmlDocument();
    mockHistory = new MockHashHtmlHistory(mockPrint: mockPrint);
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

class MockHashHtmlHistory extends MockHtmlHistory {
  int mockIndex;
  bool mockPrint;
  List<MockHashHtmlLocation> mockLocations;

  MockHashHtmlHistory({this.mockPrint = false}) {
    mockIndex = 0;
    mockLocations = [new MockHashHtmlLocation(this, mockPrint: mockPrint)];
  }

  MockHashHtmlLocation get mockLocation => mockLocations[mockIndex];

  void mockOnReplace(MockHashHtmlLocation location) {
    if (mockPrint) {
      print('mock on replace ${location.href}');
    }
    mockLocations[mockIndex] = location;
    window.dispatchEvent(new HashChangeEvent('hashchange'));
  }

  void mockOnPush(MockHashHtmlLocation location) {
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
    mockIndex = (mockIndex + delta).clamp(0, mockLocations.length - 1).toInt();
    if (mockPrint) {
      print('mock go mockIndex: ${mockIndex}');
    }
    window.dispatchEvent(new HashChangeEvent('hashchange'));
  }
}

class MockHashHtmlLocation extends MockHtmlLocation {
  bool mockPrint;
  String mockPath = '/start';
  String mockHash = '';
  MockHashHtmlHistory mockHistory;

  MockHashHtmlLocation(this.mockHistory, {this.mockPrint = false});

  @override
  String get href => '${mockPath}${mockHash.isNotEmpty ? '#' : ''}${mockHash}';

  @override
  set href(String newHref) {
    final hashIndex = newHref.indexOf('#');
    var newMockHash = hashIndex == -1 ? '' : newHref.substring(hashIndex + 1);
    var newMockPath = newHref.substring(0, hashIndex >= 0 ? hashIndex : null);

    MockHashHtmlLocation newLocation =
        new MockHashHtmlLocation(mockHistory, mockPrint: mockPrint)
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
  set hash(String newHash) {
    MockHashHtmlLocation newLocation = new MockHashHtmlLocation(mockHistory)
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
