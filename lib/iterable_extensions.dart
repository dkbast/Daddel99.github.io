// lib/utils/iterable_extensions.dart

// das ist eigentlich teil des dart sdk bzw des package collection
// hier würde ich empfehlen direkt package:collection/iterable_extensions.dart zu nutzen
// https://api.flutter.dev/flutter/package-collection_collection/IterableExtension.html
extension IterableExtensions<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
