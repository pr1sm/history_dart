import '../location.dart';
import 'path_utils.dart';

/// Helper Method to create a [Location]
///
/// This method creates a valid [Location] given the following:
/// * [path] - a path [String] or [Map] of [Location] information
/// * [state] - any extra state info associated with the [Location]
/// * [key] - the key name for the created [Location]
/// * [currentLocation] - an optional existing [Location]
// TODO: Integrate this with location.dart
Location createLocation(dynamic path, dynamic state, String key,
    [Location currentLocation = null]) {
  Location location;

  if (path is String) {
    location = new Location.copy(parsePath(path), state: state, key: key);
  } else {
    location = new Location.fromMap(path);

    final newPathname = location.pathname ?? '';
    final newSearch =
        location.search != null ? addLeading(location.search, '?') : '';
    final newHash = location.hash != null ? addLeading(location.hash, '#') : '';
    final newState = (state != null && location.state == null) ? state : null;

    location = new Location.copy(location,
        pathname: newPathname,
        search: newSearch,
        hash: newHash,
        state: newState,
        key: key);
  }

  try {
    Uri.parse(location.pathname);
  } catch (e) {
    if (e is FormatException) {
      throw new FormatException(
          'Pathname "${location.pathname}" could not be decoded. This is likely caused by an invalid percent-encoding/');
    } else {
      throw e;
    }
  }

  String resolvedPathname = null;
  if (currentLocation != null) {
    if (location.pathname.isEmpty) {
      resolvedPathname = currentLocation.pathname;
    } else if (!location.pathname.startsWith('/')) {
      Uri currUri = Uri.parse(currentLocation.pathname);
      resolvedPathname = currUri.resolve(location.pathname).path;
    }
  } else {
    if (location.pathname.isEmpty) {
      resolvedPathname = '/';
    }
  }

  return new Location.copy(location, pathname: resolvedPathname);
}
