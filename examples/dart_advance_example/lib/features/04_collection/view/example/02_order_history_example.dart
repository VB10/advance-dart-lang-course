part of '../collection_view.dart';

final class _OrderHistoryExample {
  TopicExample build() {
    const orders = [
      Order('#1042', 'Ekim'),
      Order('#0987', 'Eylül'),
      Order('#1051', 'Ekim'),
    ];
    final history = OrderHistory();
    return TopicExample(
      title: 'Ay başlıkları: groupBy',
      negative: _OrderHistoryPreview(sections: history.sectionsWrong(orders)),
      positive: _OrderHistoryPreview(sections: history.sections(orders)),
    );
  }
}

final class _OrderHistoryPreview extends StatelessWidget {
  const _OrderHistoryPreview({required this.sections});

  final List<(String, List<Order>)> sections;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (month, orders) in sections) ...[
          Text(month, style: style),
          for (final order in orders)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text('Sipariş ${order.no}'),
            ),
        ],
      ],
    );
  }
}
