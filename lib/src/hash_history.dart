import 'history.dart';
import 'utils/utils.dart';

/// Extension of [History] that supports Legacy Browsers
///
/// This class extends all functionality of the base [History] class and adds
/// extra functionality only supported in this variant.
abstract class HashHistory extends History with BasenameMixin {
  /// Character pattern that will be used for the hash
  ///
  /// (See [HashType] for more info)
  HashType get hashType;
}
