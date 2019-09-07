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

/// Add a leading [prefix] to [path] if it isn't already there
String addLeading(String path, String prefix) =>
    path.startsWith(prefix) ? path : '${prefix}${path}';

/// Remove a leading [prefix] from [path] if it is there
String stripLeading(String path, String prefix) =>
    path.startsWith(prefix) ? path.substring(prefix.length) : path;

/// Add the leading slash ('/') to [path] if it isn't already there
///
/// This is a convenience method for [addLeading]
String addLeadingSlash(String path) => addLeading(path, '/');

/// Remove leading slash ('/') from [path] if it is there
///
/// This is a convenience method for [stripLeading]
String stripLeadingSlash(String path) => stripLeading(path, '/');

/// Check if [path] has [prefix] as the basename
bool hasBasename(String path, String prefix) =>
    RegExp('^${prefix}(\\/|\\?|#|\$)', caseSensitive: false).hasMatch(path);

/// Remove [prefix] as basename from [path] if it exists
String stripBasename(String path, String prefix) =>
    hasBasename(path, prefix) ? path.substring(prefix.length) : path;

/// Remove trailing slash from [path] if it exists
String stripTrailingSlash(String path) =>
    path.endsWith('/') ? path.substring(0, path.length - 1) : path;
