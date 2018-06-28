import 'history.dart';

/// Extension of [History] that proxies calls to the Browser
///
/// This class extends all functionality of the base [History] class and adds
/// extra functionality only supported in this variant.
abstract class BrowserHistory extends History with BasenameMixin {
  /// If changes to this will force a Browser page refresh
  bool get willForceRefresh;
}
