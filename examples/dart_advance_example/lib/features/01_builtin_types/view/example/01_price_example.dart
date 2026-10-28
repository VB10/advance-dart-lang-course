part of '../builtin_types_view.dart';

final class _PriceExample {
  TopicExample build() {
    final price = ProductPrice();
    return TopicExample(
      title: 'Fiyat: double değil kuruş int',
      negative: _PricePreview(
        price: price.labelWrong(24999.9),
        oldPrice: price.labelWrong(29999),
      ),
      positive: _PricePreview(
        price: price.label(2499990),
        oldPrice: price.label(2999900),
      ),
    );
  }
}

final class _PricePreview extends StatelessWidget {
  const _PricePreview({required this.price, required this.oldPrice});

  final String price;
  final String oldPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: BuiltinTypesView._gap,
      children: [
        Container(
          width: BuiltinTypesView._thumb,
          height: BuiltinTypesView._thumb,
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.chair_outlined),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Üçlü kanepe'),
            Text(price, style: theme.textTheme.titleMedium),
            Text(
              oldPrice,
              style: const TextStyle(decoration: TextDecoration.lineThrough),
            ),
          ],
        ),
      ],
    );
  }
}
