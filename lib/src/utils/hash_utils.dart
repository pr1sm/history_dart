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

import 'dart:html' as html;

import 'path_utils.dart' show addLeadingSlash, stripLeading, stripLeadingSlash;
import 'utils.dart' show HashType;

import '../core/location.dart';

/// Container for Encode/Decode methods
///
/// This is a helper class to order encode/decode
/// transformations of paths. This is used [HashPathCoders]
/// to properly transform paths based on a [HashType].
class EncoderDecoder {
  final String Function(String) encodePath;
  final String Function(String) decodePath;

  EncoderDecoder(this.encodePath, this.decodePath);
}

/// Map of [EncoderDecoder]s by [HashType]
final HashPathCoders = {
  HashType.hashbang: new EncoderDecoder(
      (path) => path.startsWith('!') ? path : '!/${stripLeadingSlash(path)}',
      (path) => stripLeading(path, '!')),
  HashType.noSlash: new EncoderDecoder(stripLeadingSlash, addLeadingSlash),
  HashType.slash: new EncoderDecoder(addLeadingSlash, addLeadingSlash),
};

/// Convert [html.Location] to [Location]
Location convert(html.Location location) => new Location(
    pathname: location.pathname, hash: location.hash, search: location.search);
