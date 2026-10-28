part of '../collection_view.dart';

final class _FilterExample {
  TopicExample build() {
    const categories = ['Elektronik', 'Kitap', 'Oyuncak'];
    final applied = {'Kitap', 'Elektronik'};
    // Kullanıcı sheet'i açtı, Kitap'ı kaldırıp geri seçti: içerik aynı.
    final draft = {'Elektronik', 'Kitap'};
    final filter = FilterDraft();
    return TopicExample(
      title: "Değişiklik yokken 'Uygula': SetEquality",
      negative: _FilterPreview(
        categories: categories,
        selected: draft,
        canApply: filter.canApplyWrong(applied, draft),
      ),
      positive: _FilterPreview(
        categories: categories,
        selected: draft,
        canApply: filter.canApply(applied, draft),
      ),
    );
  }
}

final class _FilterPreview extends StatelessWidget {
  const _FilterPreview({
    required this.categories,
    required this.selected,
    required this.canApply,
  });

  final List<String> categories;
  final Set<String> selected;
  final bool canApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: CollectionView._gap,
      children: [
        Wrap(
          spacing: CollectionView._gap,
          children: [
            for (final category in categories)
              FilterChip(
                label: Text(category),
                selected: selected.contains(category),
                onSelected: (_) {},
              ),
          ],
        ),
        FilledButton(
          onPressed: canApply ? () {} : null,
          child: const Text('Uygula'),
        ),
      ],
    );
  }
}
