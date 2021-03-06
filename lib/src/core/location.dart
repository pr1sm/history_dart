// MIT License
//
// Copyright (c) 2018 Srinivas Dhanwada
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:quiver/core.dart' show hashObjects;

import '../utils/path_utils.dart';

/// Abstraction of Location class
///
/// This class is a subset of the HTML5 Location class that allows
/// support of a Location class without relying on the browser.
class Location {
  String _pathname;
  String _hash;
  String _key;
  String _search;
  dynamic _state;

  /// Construct a [Location].
  ///
  /// This constructor allows partial [Location] construction, providing default values for the rest.
  Location(
      {String pathname = '/',
      String hash = '',
      String key,
      String search = '',
      dynamic state}) {
    // Call initialization with given inputs
    _initialize(pathname ?? '/', hash ?? '', key, search ?? '', state);
  }

  /// Construct a copy of an existing [Location].
  ///
  /// This constructor also allows overriding of individual components, if necessary.
  Location.copy(
    Location other, {
    String pathname,
    String hash,
    String key,
    String search,
    dynamic state,
  }) : this(
            pathname: pathname ?? other.pathname,
            hash: hash ?? other.hash,
            key: key ?? other.key,
            search: search ?? other.search,
            state: state ?? other.state);

  /// Construct a [Location] using an existing map
  ///
  /// This is convenience constructor that allows [Location] information stored in a map to
  /// be converted to typed information.
  Location.fromMap(Map<String, dynamic> map) : this._fromMap(map ?? const {});

  /// Construct a [Location] relative to [base]
  ///
  /// This should be used as a convenience to easily resolve pathnames that are
  /// relative when creating a location.
  ///
  /// See [relateTo] for more information on how this is done.
  Location.relativeTo(
    Location base, {
    String pathname,
    String hash,
    String key,
    String search,
    dynamic state,
  }) {
    // Call initialization with given inputs
    _initialize(pathname ?? '/', hash ?? '', key, search ?? '', state);

    // Resolve pathname if needed...
    relateTo(base);
  }

  /// Custom hashCode implementation
  ///
  /// Create a hash from the components of this [Location]
  @override
  int get hashCode => hashObjects([pathname, search, hash, key, state]);

  /// Custom equality operator
  ///
  /// Check all components of [Location] for equality
  @override
  bool operator ==(l) =>
      l is Location &&
      l.pathname == pathname &&
      l.search == search &&
      l.hash == hash &&
      l.key == key &&
      (l.state == null ? state == null : l.state.hashCode == state.hashCode);

  /// Custom toString implementation
  ///
  /// This should be used for debug purposes
  @override
  String toString() =>
      'Pathname: "${pathname}", Hash: "${hash}", Search: "${search}", Key: "${key}", State: "${state.toString()}"';

  /// Resolve this [Location] relative to [base]
  ///
  /// Attempt to resolve the [pathname] of this [Location] to [base] using uri
  /// resolution. This should be done if [pathname] is a relative path
  ///
  /// Example:
  /// ```
  /// Location base = Location(pathname: '/home/first');
  /// Location relative = Location(pathname: 'second'); // relative path
  /// relative.relateTo(base);
  /// print(relative.pathname) // Output: /home/second
  /// ```
  void relateTo(Location base) {
    String resolvedPathname;
    if (base != null) {
      // Current pathname is empty, use base pathname
      if (_pathname.isEmpty) {
        resolvedPathname = base.pathname;
      } else if (!_pathname.startsWith('/')) {
        // Current pathname is relative, resolve relative to base pathname
        Uri baseUri = Uri.parse(base.pathname);
        resolvedPathname = baseUri.resolve(_pathname).path;
      }
    } else if (_pathname.isEmpty) {
      // Base is null and current pathname is empty, set a default
      resolvedPathname = '/';
    }

    // Use resolved pathname it if isn't null
    _pathname = resolvedPathname ?? _pathname;
  }

  /// The hash fragment of this [Location]
  ///
  /// This is the portion that starts with a '#' and
  /// contains the rest of the location until the [search] portion starts.
  String get hash => _hash;

  /// A unique string representing this [Location]
  String get key => _key;

  /// The String representation of this [Location]
  ///
  /// Combines the [pathname], [hash] and [search] portions of this [Location]
  String get path {
    String path = pathname;
    if (search != '?' && search.isNotEmpty) {
      path += addLeading(search, '?');
    }
    if (hash != '#' && hash.isNotEmpty) {
      path += addLeading(hash, '#');
    }
    return path;
  }

  /// The path fragment of this [Location]
  ///
  /// This is the initial portion that starts with a '/' and
  /// contains the rest of the location until the [hash] or [search] portions start
  String get pathname => _pathname;

  /// The search fragment of this [Location]
  ///
  /// This is the portion that starts with a '?' and
  /// contains a string of query parameters.
  String get search => _search;

  /// Extra data associated with this [Location] that does not reside in its [path]
  ///
  /// This object can contain any extraneous information not contained in the other variables. This can
  /// be used to pass data along with the [Location] that may be too complex to represent as a string.
  dynamic get state => _state;

  Location._fromMap(Map<String, dynamic> map)
      : this(
            pathname: map['pathname'] as String,
            hash: map['hash'] as String,
            key: map['key'] as String,
            search: map['search'] as String,
            state: map['state']);

  void _initialize(
      String pathname, String hash, String key, String search, dynamic state) {
    // Check if given pathname contains a hash portion and strip it
    int hashIndex = pathname.indexOf('#');
    String pathHash = '';
    if (hashIndex != -1) {
      pathHash = pathname.substring(hashIndex);
      pathname = pathname.substring(0, hashIndex);
    }

    // Deal with implicit vs explicit hash
    if (hash.isNotEmpty && pathHash.isNotEmpty) {
      print(
          'WARNING: pathname contains an explicit hash portion and hash parameter was also provided. Defaulting to use hash portion');
      _hash = pathHash;
    } else {
      _hash = hash.isNotEmpty ? hash : pathHash;
    }
    _hash = stripLeading(_hash, '#');

    // Check if given pathname contains a search portion and strip it
    int searchIndex = pathname.indexOf('?');
    String pathSearch = '';
    if (searchIndex != -1) {
      pathSearch = pathname.substring(searchIndex);
      pathname = pathname.substring(0, searchIndex);
    }

    // Deal with implicit vs explicit search
    if (search.isNotEmpty && pathSearch.isNotEmpty) {
      print(
          'WARNING: pathname contains an explicit search portion and search parameter was also provided. Defaulting to use search portion');
      _search = pathSearch;
    } else {
      _search = search.isNotEmpty ? search : pathSearch;
    }
    _search = stripLeading(_search, '?');

    // Set rest of variables
    _pathname = pathname;
    _key = key;
    _state = state;

    try {
      Uri.parse(path);
    } on FormatException catch (_) {
      throw FormatException(
          'Pathname "${_pathname}" could not be decoded. This is likely caused by an invalid percent-encoding.');
    }
  }
}
