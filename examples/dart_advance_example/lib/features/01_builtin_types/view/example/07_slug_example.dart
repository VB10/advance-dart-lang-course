part of '../builtin_types_view.dart';

final class _SlugExample {
  TopicExample build() {
    const title = 'Öne Çıkan Ürünler';
    final slug = CategorySlug();
    return TopicExample(
      title: 'Paylaşım linki: Türkçe harfi silme, çevir',
      negative: _SlugPreview(title: title, slug: slug.slugWrong(title)),
      positive: _SlugPreview(title: title, slug: slug.slug(title)),
    );
  }
}

final class _SlugPreview extends StatelessWidget {
  const _SlugPreview({required this.title, required this.slug});

  final String title;
  final String slug;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.share),
      title: Text(title),
      subtitle: Text('magaza.app/kategori/$slug'),
      trailing: const Icon(Icons.copy),
    );
  }
}
