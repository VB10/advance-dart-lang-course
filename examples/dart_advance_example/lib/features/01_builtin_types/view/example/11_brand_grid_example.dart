part of '../builtin_types_view.dart';

final class _BrandGridExample {
  TopicExample build() {
    const brands = [
      Brand('Nova', 3),
      Brand('Arda', 1),
      Brand('Taslak', 0, visible: false),
      Brand('Mavi', 2),
    ];
    final wrong = BrandPage(brands);
    final wrongCells = [
      for (var i = 0; i < wrong.visibleWrong.length; i++) wrong.visibleWrong[i],
    ];
    final page = BrandPage(brands);
    final cells = [
      for (var i = 0; i < page.visible.length; i++) page.visible[i],
    ];
    return TopicExample(
      title: 'Grid: getter her hücrede yeniden sıralar',
      negative: _BrandGridPreview(brands: wrongCells, sorts: wrong.sorts),
      positive: _BrandGridPreview(brands: cells, sorts: page.sorts),
    );
  }
}

final class _BrandGridPreview extends StatelessWidget {
  const _BrandGridPreview({required this.brands, required this.sorts});

  final List<Brand> brands;
  final int sorts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: BuiltinTypesView._gap,
      children: [
        Wrap(
          spacing: BuiltinTypesView._gap,
          children: [for (final brand in brands) Chip(label: Text(brand.name))],
        ),
        Text('Bu build sırasında liste $sorts kez süzülüp sıralandı'),
      ],
    );
  }
}
