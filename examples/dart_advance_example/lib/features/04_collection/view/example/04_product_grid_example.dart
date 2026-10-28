part of '../collection_view.dart';

final class _ProductGridExample {
  TopicExample build() {
    const products = [
      'Masa',
      'Sandalye',
      'Lamba',
      'Halı',
      'Raf',
      'Ayna',
      'Vazo',
    ];
    final grid = ProductGrid();
    List<List<String>>? wrongRows;
    String? error;
    try {
      wrongRows = grid.rowsWrong(products);
    } on RangeError catch (e) {
      error = '${e.message}: ${e.invalidValue}';
    }
    return TopicExample(
      title: 'Satırda 3 ürün: sublist değil slices',
      negative: _ProductGridPreview(rows: wrongRows, error: error),
      positive: _ProductGridPreview(rows: grid.rows(products)),
    );
  }
}

final class _ProductGridPreview extends StatelessWidget {
  const _ProductGridPreview({this.rows, this.error});

  final List<List<String>>? rows;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (error case final error?) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.grid_off, color: colors.error),
        title: const Text('Ürünler yüklenemedi'),
        subtitle: Text('RangeError: $error'),
      );
    }
    return Column(
      spacing: CollectionView._gap,
      children: [
        for (final row in rows ?? const <List<String>>[])
          Row(
            spacing: CollectionView._gap,
            children: [
              for (var i = 0; i < ProductGrid.perRow; i++)
                Expanded(
                  child: i < row.length
                      ? Container(
                          padding: const EdgeInsets.all(CollectionView._gap),
                          color: colors.surfaceContainerHighest,
                          child: Text(row[i], textAlign: TextAlign.center),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
      ],
    );
  }
}
