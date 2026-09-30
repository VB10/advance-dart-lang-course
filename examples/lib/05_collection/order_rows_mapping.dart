import 'package:collection/collection.dart';

typedef OrderRow = ({String customer, String orderId, int totalMinor});

Map<String, List<OrderRow>> rowsByCustomer(Iterable<OrderRow> rows) => {
  for (final MapEntry(:key, :value) in rows.groupListsBy((row) => row.customer).entries)
    key: value.sortedBy<num>((row) => -row.totalMinor),
};
