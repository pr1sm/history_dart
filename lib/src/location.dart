import 'package:quiver/core.dart';

class Location {
  final String pathname;
  final String hash;
  final String key;
  final String search;
  final dynamic state;

  Location(
      {String pathname = '/',
      String hash = '',
      String key = null,
      String search = '',
      dynamic state = null})
      : this.pathname = pathname,
        this.hash = hash,
        this.key = key,
        this.search = search,
        this.state = state;

  Location.copy(
    Location other, {
    String pathname,
    String hash,
    String key,
    String search,
    dynamic state,
  })
      : this.pathname = pathname ?? other.pathname,
        this.hash = hash ?? other.hash,
        this.key = key ?? other.key,
        this.search = search ?? other.search,
        this.state = state ?? other.state;

  Location.fromMap(Map<String, dynamic> map)
      : this.pathname = map['pathname'],
        this.hash = map['hash'],
        this.key = map['key'],
        this.search = map['search'],
        this.state = map['state'];

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
