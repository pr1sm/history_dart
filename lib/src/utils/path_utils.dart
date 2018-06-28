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
