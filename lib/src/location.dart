import 'package:quiver/core.dart' show hashObjects;

/// Abstraction of Location class
/// 
/// This class is a subset of the HTML5 Location class that allows 
/// support of a Location class without relying on the browser.
class Location {
  /// The path fragment of the [Location]
  /// 
  /// This is the initial portion of the [Location] that starts with a '/' and 
  /// contains the rest of the location until the [hash] or [search] portions start
  final String pathname;

  /// The hash fragment of the [Location]
  /// 
  /// This is the portion of the [Location] that starts with a '#' and 
  /// contains the rest of the location until the [search] portion starts.
  final String hash;

  /// A unique string representing this [Location]
  final String key;

  /// The search fragment of the [Location]
  /// 
  /// This is the portion of the [Location] that starts with a '?' and 
  /// contains a string of query parameters.
  final String search;

  /// Extra data associated with the [Location] that does not reside in the String representation
  /// 
  /// This object can contain any extraneous information not contained in the other variables. This can 
  /// be used to pass data along with the [Location] that may be too complex to represent as a string.
  final dynamic state;

  /// Construct a [Location].
  /// 
  /// This constructor allows partial [Location] construction, providing default values for the rest.
  Location(
      {this.pathname = '/',
      this.hash = '',
      this.key = null,
      this.search = '',
      this.state = null});

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

  @override
  bool operator ==(l) => l is Location &&
          l.pathname == pathname &&
          l.search == search &&
          l.hash == hash &&
          l.key == key &&
          l.state == null
      ? state == null
      : l.state.hashCode == state.hashCode;

  @override
  int get hashCode => hashObjects([pathname, search, hash, key, state]);
}
