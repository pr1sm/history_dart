import '../location.dart';

/// Add a leading [prefix] to [path] if it isn't already there
addLeading(String path, String prefix) =>
    path.startsWith(prefix) ? path : '${prefix}${path}';

/// Remove a leading [prefix] from [path] if it is there
stripLeading(String path, String prefix) =>
    path.startsWith(prefix) ? path.substring(prefix.length) : path;

/// Add the leading slash ('/') to [path] if it isn't already there
///
/// This is a convenience method for [addLeading]
addLeadingSlash(String path) => addLeading(path, '/');

/// Remove leading slash ('/') from [path] if it is there
///
/// This is a convenience method for [stripLeading]
stripLeadingSlash(String path) => stripLeading(path, '/');

/// Check if [path] has [prefix] as the basename
hasBasename(String path, String prefix) =>
    new RegExp('^${prefix}(\\/|\\?|#|\$)', caseSensitive: false).hasMatch(path);

/// Remove [prefix] as basename from [path] if it exists
stripBasename(String path, String prefix) =>
    hasBasename(path, prefix) ? path.substring(prefix.length) : path;

/// Remove trailing slash from [path] if it exists
stripTrailingSlash(String path) =>
    path.endsWith('/') ? path.substring(0, path.length - 1) : path;

/// Convert [path] from a [String] to a valid [Location]
// TOOD: Integrate with location.dart
Location parsePath(String path) {
  String pathname = path ?? '/';
  String search = '';
  String hash = '';

  final hashIndex = pathname.indexOf('#');
  if (hashIndex != -1) {
    hash = pathname.substring(hashIndex);
    pathname = pathname.substring(0, hashIndex);
  }

  final searchIndex = pathname.indexOf('?');
  if (searchIndex != -1) {
    search = pathname.substring(searchIndex);
    pathname = pathname.substring(0, searchIndex);
  }

  return new Location(pathname: pathname, search: search, hash: hash);
}

/// Convert [location] to a string representation
// TODO: Integrate with location.dart
createPath(Location location) {
  String path = location.pathname;
  if (location.search != '?') {
    path += addLeading(location.search, '?');
  }

  if (location.hash != '#') {
    path += addLeading(location.hash, '#');
  }

  return path;
}
