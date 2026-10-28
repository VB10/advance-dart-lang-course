part of '../builtin_types_view.dart';

final class _FilterSheetExample {
  TopicExample build() {
    final sheet = EventFilterSheet('tr');
    sheet.titlesWrong; // sheet ilk açıldığında okunur
    sheet.language = 'en';
    return TopicExample(
      title: 'Dil değişti: late final eski değeri tutar',
      negative: _FilterSheetPreview(titles: sheet.titlesWrong),
      positive: _FilterSheetPreview(titles: sheet.titles),
    );
  }
}

final class _FilterSheetPreview extends StatelessWidget {
  const _FilterSheetPreview({required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: BuiltinTypesView._gap,
      children: [
        Text('Filter events', style: Theme.of(context).textTheme.titleSmall),
        Wrap(
          spacing: BuiltinTypesView._gap,
          children: [
            for (final title in titles)
              FilterChip(label: Text(title), onSelected: (_) {}),
          ],
        ),
      ],
    );
  }
}
