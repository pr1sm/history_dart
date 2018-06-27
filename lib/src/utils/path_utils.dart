import '../location.dart';

addLeading(String path, String prefix) =>
    path.startsWith(prefix) ? path : '${prefix}${path}';

stripLeading(String path, String prefix) =>
    path.startsWith(prefix) ? path.substring(prefix.length) : path;

addLeadingSlash(String path) => addLeading(path, '/');

stripLeadingSlash(String path) => stripLeading(path, '/');

hasBasename(String path, String prefix) =>
    new RegExp('^${prefix}(\\/|\\?|#|\$)', caseSensitive: false).hasMatch(path);

stripBasename(String path, String prefix) =>
    hasBasename(path, prefix) ? path.substring(prefix.length) : path;

stripTrailingSlash(String path) =>
    path.endsWith('/') ? path.substring(0, path.length - 1) : path;

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
