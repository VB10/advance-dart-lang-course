part of '../builtin_types_view.dart';

final class _GalleryExample {
  TopicExample build() {
    const photos = [
      Icons.chair_outlined,
      Icons.weekend_outlined,
      Icons.bed_outlined,
      Icons.table_restaurant_outlined,
      Icons.light_outlined,
    ];
    const gallery = PhotoGallery(5);
    return TopicExample(
      title: 'İlk fotoğraftan geri: remainder değil %',
      negative: _GalleryPreview(
        photos: photos,
        index: gallery.previousWrong(0),
      ),
      positive: _GalleryPreview(photos: photos, index: gallery.previous(0)),
    );
  }
}

final class _GalleryPreview extends StatelessWidget {
  const _GalleryPreview({required this.photos, required this.index});

  final List<IconData> photos;

  /// The page "geri" lands on from the first photo.
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Widget photo;
    try {
      photo = Icon(photos[index], size: BuiltinTypesView._thumb);
    } on RangeError catch (error) {
      return ListTile(
        leading: Icon(Icons.broken_image, color: colors.error),
        title: const Text('Galeri açılamadı'),
        subtitle: Text('${error.message}: ${error.invalidValue}'),
      );
    }
    return Column(
      children: [
        Container(
          height: BuiltinTypesView._thumb * 2,
          alignment: Alignment.center,
          color: colors.surfaceContainerHighest,
          child: photo,
        ),
        Text('${index + 1} / ${photos.length}'),
      ],
    );
  }
}
