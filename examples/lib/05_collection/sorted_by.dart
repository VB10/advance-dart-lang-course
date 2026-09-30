import 'package:collection/collection.dart';

import 'group_by.dart';

/// Returns a new list; core `List.sort` sorts in place and returns `void`.
List<Sale> byAmount(Iterable<Sale> sales) => sales.sortedBy((sale) => sale.amount);

List<String> naturalOrder(Iterable<String> names) => names.sorted(compareNatural);
