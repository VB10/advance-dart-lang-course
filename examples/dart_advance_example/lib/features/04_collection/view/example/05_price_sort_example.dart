part of '../collection_view.dart';

final class _PriceSortExample {
  TopicExample build() {
    const products = [
      Product('Kupa', 19.9),
      Product('Defter', 19.5),
      Product('Kalem', 12.0),
    ];
    final sort = PriceSort();
    return TopicExample(
      title: 'Fiyata göre artan: sortedBy',
      negative: _PriceSortPreview(products: sort.ascendingWrong(products)),
      positive: _PriceSortPreview(products: sort.ascending(products)),
    );
  }
}

final class _PriceSortPreview extends StatelessWidget {
  const _PriceSortPreview({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            avatar: Icon(Icons.arrow_upward, size: 16),
            label: Text('Fiyat: artan'),
          ),
        ),
        for (final product in products)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(product.name),
            trailing: Text(
              '${product.price.toStringAsFixed(2).replaceAll('.', ',')} ₺',
            ),
          ),
      ],
    );
  }
}
