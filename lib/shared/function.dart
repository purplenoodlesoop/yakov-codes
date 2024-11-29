import 'package:intl/intl.dart';

Comparator<T> compareOn<T, E extends Comparable<E>>(
  E Function(T value) select, {
  bool reversed = false,
}) =>
    (a, b) => select(reversed ? b : a).compareTo(select(reversed ? a : b));

final formatDate = DateFormat.yMMMMd().format;
