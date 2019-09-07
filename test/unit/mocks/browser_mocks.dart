import 'dart:html';

import 'package:mockito/mockito.dart';

import 'html_mocks.dart';

class MockBrowserHtmlWindow extends MockHtmlWindow {
  MockHtmlDocument mockDocument;
  MockHtmlNavigator mockNavigator;
  MockBrowserHtmlHistory mockHistory;
  bool mockPrint;

  MockBrowserHtmlWindow({this.mockPrint = false}) {
    mockNavigator = MockHtmlNavigator();
    when(mockNavigator.userAgent).thenReturn(
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36');
    mockDocument = MockHtmlDocument();
    mockHistory = MockBrowserHtmlHistory(mockPrint: mockPrint);
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

class MockBrowserHtmlHistory extends MockHtmlHistory {
  int mockIndex;
  bool mockPrint;
  bool mockErrorOnState;
  bool mockNullOnState;
  bool mockUsePopState;
  List<MockBrowserHtmlLocation> mockLocations;

  MockBrowserHtmlHistory(
      {this.mockPrint = false,
      this.mockErrorOnState = false,
      this.mockNullOnState = false,
      this.mockUsePopState = true}) {
    mockIndex = 0;
    mockLocations = [MockBrowserHtmlLocation(this, mockPrint: mockPrint)];
  }

  MockBrowserHtmlLocation get mockLocation {
    if (mockPrint) {
      print('mock get mockLocation at index: ${mockIndex}');
    }
    return mockLocations[mockIndex];
  }

  void mockOnReplace(MockBrowserHtmlLocation location) {
    if (mockPrint) {
      print('mock on replace ${location.href}');
    }
    mockLocations[mockIndex] = location;
    if (mockUsePopState) {
      window.dispatchEvent(PopStateEvent('popstate', {'state': state}));
    } else {
      window.dispatchEvent(HashChangeEvent('hashchange'));
    }
  }

  void mockOnPush(MockBrowserHtmlLocation location) {
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
    if (mockUsePopState) {
      window.dispatchEvent(PopStateEvent('popstate', {'state': state}));
    } else {
      window.dispatchEvent(HashChangeEvent('hashchange'));
    }
  }

  @override
  dynamic get state {
    if (mockErrorOnState) {
      throw StateError('expected error');
    }
    if (mockNullOnState) {
      return null;
    }
    MockBrowserHtmlLocation mockLocation = mockLocations[mockIndex];
    return {
      'key': mockLocation.mockKey,
      'state': mockLocation.mockState,
    };
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
    if (mockUsePopState) {
      window.dispatchEvent(PopStateEvent('popstate', {'state': state}));
    } else {
      window.dispatchEvent(HashChangeEvent('hashchange'));
    }
  }

  @override
  void pushState(dynamic data, String title, String url) {
    final searchIndex = url.indexOf('?');
    final hashIndex = url.indexOf('#');
    var newMockHash = hashIndex == -1 ? '' : url.substring(hashIndex + 1);
    var newMockSearch = searchIndex == -1
        ? ''
        : url.substring(searchIndex + 1, hashIndex >= 0 ? hashIndex : null);
    var newMockPath = url.substring(
        0, searchIndex >= 0 ? searchIndex : hashIndex >= 0 ? hashIndex : null);
    var newMockKey = (data is Map) ? data['key'] : data.key;
    var newMockState = (data is Map) ? data['state'] : data.state;

    MockBrowserHtmlLocation newLocation =
        MockBrowserHtmlLocation(this, mockPrint: mockPrint)
          ..mockPath = newMockPath
          ..mockHash = newMockHash
          ..mockSearch = newMockSearch
          ..mockKey = newMockKey.toString()
          ..mockState = newMockState;
    if (mockPrint) {
      print(
          'mock pushState (push) ${mockLocation.href} => ${newLocation.href}');
    }
    mockOnPush(newLocation);
  }

  @override
  void replaceState(dynamic data, String title, String url) {
    final searchIndex = url.indexOf('?');
    final hashIndex = url.indexOf('#');
    var newMockHash = hashIndex == -1 ? '' : url.substring(hashIndex + 1);
    var newMockSearch = searchIndex == -1
        ? ''
        : url.substring(searchIndex + 1, hashIndex >= 0 ? hashIndex : null);
    var newMockPath = url.substring(
        0, searchIndex >= 0 ? searchIndex : hashIndex >= 0 ? hashIndex : null);
    var newMockKey = (data is Map) ? data['key'] : data.key;
    var newMockState = (data is Map) ? data['state'] : data.state;

    MockBrowserHtmlLocation newLocation =
        MockBrowserHtmlLocation(this, mockPrint: mockPrint)
          ..mockPath = newMockPath
          ..mockHash = newMockHash
          ..mockSearch = newMockSearch
          ..mockKey = newMockKey.toString()
          ..mockState = newMockState;
    if (mockPrint) {
      print(
          'mock replaceState (replace) ${mockLocation.href} => ${newLocation.href}');
    }
    mockOnReplace(newLocation);
  }
}

class MockBrowserHtmlLocation extends Mock implements Location {
  bool mockPrint;
  String mockPath = '/';
  String mockHash = '';
  String mockSearch = '';
  String mockKey;
  String mockTitle;
  dynamic mockState;
  MockBrowserHtmlHistory mockHistory;

  MockBrowserHtmlLocation(this.mockHistory, {this.mockPrint = false});

  @override
  String get href =>
      '${mockPath}${mockSearch.isNotEmpty ? '?' : ''}${mockSearch}${mockHash.isNotEmpty ? '#' : ''}${mockHash}';

  @override
  set href(String newHref) {
    final searchIndex = newHref.indexOf('?');
    final hashIndex = newHref.indexOf('#');
    var newMockHash = hashIndex == -1 ? '' : newHref.substring(hashIndex + 1);
    var newMockSearch = searchIndex == -1
        ? ''
        : newHref.substring(searchIndex + 1, hashIndex >= 0 ? hashIndex : null);
    var newMockPath = newHref.substring(
        0, searchIndex >= 0 ? searchIndex : hashIndex >= 0 ? hashIndex : null);

    MockBrowserHtmlLocation newLocation =
        MockBrowserHtmlLocation(mockHistory, mockPrint: mockPrint)
          ..mockPath = newMockPath
          ..mockHash = newMockHash
          ..mockSearch = newMockSearch;
    if (mockPrint) {
      print('mock href set (push) ${href} => ${newLocation.href}');
    }
    mockHistory.mockOnPush(newLocation);
  }

  @override
  String get hash => mockHash;

  @override
  set hash(String newHash) {
    MockBrowserHtmlLocation newLocation = MockBrowserHtmlLocation(mockHistory)
      ..mockPath = mockPath
      ..mockHash = newHash
      ..mockSearch = mockSearch;
    if (mockPrint) {
      print('mock hash set (push) ${href} => ${newLocation.href}');
    }
    mockHistory.mockOnPush(newLocation);
  }

  @override
  String get pathname => mockPath;

  @override
  set pathname(String newPath) {
    MockBrowserHtmlLocation newLocation = MockBrowserHtmlLocation(mockHistory)
      ..mockPath = newPath
      ..mockHash = mockHash
      ..mockSearch = mockSearch;
    if (mockPrint) {
      print('mock pathname set (push) ${href} => ${newLocation.href}');
    }
    mockHistory.mockOnPush(newLocation);
  }

  @override
  String get search => mockSearch;

  @override
  set search(String newSearch) {
    MockBrowserHtmlLocation newLocation = MockBrowserHtmlLocation(mockHistory)
      ..mockPath = mockPath
      ..mockHash = mockHash
      ..mockSearch = newSearch;
    if (mockPrint) {
      print('mock search set (push) ${href} => ${newLocation.href}');
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
