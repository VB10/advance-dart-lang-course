part of '../builtin_types_view.dart';

final class _ProductSortExample {
  TopicExample build() {
    final sort = ProductSort();
    final wrongList = ['Zeytinyağı', 'Bal', 'Peynir', 'Ekmek'];
    final wrongAz = sort.alphabeticalWrong(wrongList);
    final list = ['Zeytinyağı', 'Bal', 'Peynir', 'Ekmek'];
    final az = sort.alphabetical(list);
    return TopicExample(
      title: 'Cascade: ..sort aynı listeyi sıralar',
      negative: _ProductSortPreview(
        recommended: wrongList,
        alphabetical: wrongAz,
      ),
      positive: _ProductSortPreview(recommended: list, alphabetical: az),
    );
  }
}

final class _ProductSortPreview extends StatelessWidget {
  const _ProductSortPreview({
    required this.recommended,
    required this.alphabetical,
  });

  final List<String> recommended;
  final List<String> alphabetical;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: BuiltinTypesView._gap,
      children: [
        Text('Önerilen', style: style),
        _Chips(names: recommended),
        Text('A–Z', style: style),
        _Chips(names: alphabetical),
      ],
    );
  }
}

final class _Chips extends StatelessWidget {
  const _Chips({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: BuiltinTypesView._gap,
      children: [for (final name in names) Chip(label: Text(name))],
    );
  }
}
