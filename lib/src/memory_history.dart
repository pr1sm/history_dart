import 'history.dart';
import 'location.dart';

/// Extension of [History] that stores all data in-memory
///
/// This class extends all functionality of the base [History] class and adds
/// extra functionality only supported in this variant.
abstract class MemoryHistory extends History {
  /// Get the index of the current [Location]
  int get index;

  /// Get the array of entries stored in this [MemoryHistory]
  Iterable<Location> get entries;

  /// Checks if traveling [n] entries forward/backward is possible
  ///
  /// [n] functions similarly to [History.go()] -- a change relative to the
  /// current page, where the direction is determined by the sign of [n].
  bool canGo(n);
}
