import 'dart:html' as html;

import 'path_utils.dart' show addLeadingSlash, stripLeading, stripLeadingSlash;
import 'utils.dart' show HashType;

import '../location.dart';

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
