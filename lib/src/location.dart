import 'package:quiver/core.dart' show hashObjects;

import 'utils/path_utils.dart';

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
      String key = null,
      String search = '',
      String state = null}) {
    // Call initialization with given inputs
    _initialize(pathname, hash, key, search, state);
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
  })
      : this(
            pathname: pathname ?? other.pathname,
            hash: hash ?? other.hash,
            key: key ?? other.key,
            search: search ?? other.search,
            state: state ?? other.state);

  /// Construct a [Location] using an existing map
  ///
  /// This is convenience constructor that allows [Location] information stored in a map to
  /// be converted to typed information.
  Location.fromMap(Map<String, dynamic> map)
      : this(
            pathname: map['pathname'],
            hash: map['hash'],
            key: map['key'],
            search: map['search'],
            state: map['state']);

  /// Construct a [Location] relative to [base]
  ///
  /// This should be used as a convenience to easily resolve pathnames that are
  /// relative.
  ///
  /// Example:
  /// ```
  /// Location base = new Location(pathname: '/home/first');
  /// Location relative = new Location.relativeTo(base, pathname: 'second');
  /// print(relative.pathname) // Output: /home/second
  /// ```
  Location.relativeTo(
    Location base, {
    String pathname,
    String hash,
    String key,
    String search,
    dynamic state,
  }) {
    // Call initialization with given inputs
    _initialize(pathname, hash, key, search, state);

    // Resolve pathname if needed...
    String resolvedPathname = null;
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
    _pathname ??= resolvedPathname;
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
    if (hash != '#') {
      path += addLeading(hash, '#');
    }
    if (search != '?') {
      path += addLeading(search, '?');
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
          'WARNING: pathname contains a hash portion and explicit hash was also provided. Defaulting to use explicit hash');
      _hash = hash;
    } else {
      _hash = hash.isNotEmpty ? hash : pathHash;
    }
    _hash = stripLeading(_hash, '#');

    // Check if given pathname contains a search portion and strip it
    int searchIndex = pathname.indexOf('?');
    String pathSearch = '';
    if (searchIndex != -1) {
      search = pathname.substring(searchIndex);
      pathname = pathname.substring(0, searchIndex);
    }

    // Deal with implicit vs explicit search
    if (search.isNotEmpty && pathSearch.isNotEmpty) {
      print(
          'WARNING: pathname contains a search portion and explicit search was also provided. Defaulting to use explicit search');
      _search = search;
    } else {
      _search = search.isNotEmpty ? search : pathSearch;
    }
    _search = stripLeading(_search, '?');

    // Set rest of variables
    _pathname = pathname;
    _key = key;
    _state = state;

    try {
      Uri.parse(_pathname);
    } catch (e) {
      if (e is FormatException) {
        throw new FormatException(
            'Pathname "${_pathname}" could not be decoded. This is likely caused by an invalid percent-encoding/');
      } else {
        throw e;
      }
    }
  }
}
