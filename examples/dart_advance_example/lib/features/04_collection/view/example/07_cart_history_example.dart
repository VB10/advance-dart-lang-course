part of '../collection_view.dart';

final class _CartHistoryExample {
  TopicExample build() {
    final history = CartHistory();
    final (wrongBefore, wrongAfter) = history.addWrong([
      'Kahve',
      'Kupa',
    ], 'Termos');
    final (before, after) = history.add(['Kahve', 'Kupa'].lock, 'Termos');
    return TopicExample(
      title: "Sepette 'Geri al': List değil IList",
      negative: _CartHistoryPreview(after: wrongAfter, undone: wrongBefore),
      positive: _CartHistoryPreview(after: after.unlock, undone: before.unlock),
    );
  }
}

final class _CartHistoryPreview extends StatelessWidget {
  const _CartHistoryPreview({required this.after, required this.undone});

  final List<String> after;

  /// The state "Geri al" goes back to.
  final List<String> undone;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CollectionView._gap,
      children: [
        Text('Termos eklendi', style: style),
        Text('Sepet: ${after.join(', ')}'),
        const Divider(),
        Text("'Geri al' sonrası", style: style),
        Text('Sepet: ${undone.join(', ')}'),
      ],
    );
  }
}
