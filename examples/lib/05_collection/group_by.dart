import 'package:collection/collection.dart';

typedef Sale = ({String city, String sku, int amount});

Map<String, List<Sale>> salesByCity(Iterable<Sale> sales) =>
    sales.groupListsBy((sale) => sale.city);

Map<String, List<Sale>> salesByCityFunction(Iterable<Sale> sales) =>
    groupBy(sales, (Sale sale) => sale.city);
