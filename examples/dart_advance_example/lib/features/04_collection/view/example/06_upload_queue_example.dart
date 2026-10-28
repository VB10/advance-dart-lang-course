part of '../collection_view.dart';

final class _UploadQueueExample {
  TopicExample build() {
    const uploads = [
      Upload('Ürün fotoğrafı 1', priority: 2),
      Upload('Ürün fotoğrafı 2', priority: 2),
      Upload('Ürün fotoğrafı 3', priority: 2),
      Upload('Kimlik ön yüz', priority: 0),
    ];
    final queue = UploadQueue();
    return TopicExample(
      title: 'Önce kimlik: PriorityQueue',
      negative: _UploadQueuePreview(names: queue.orderWrong(uploads)),
      positive: _UploadQueuePreview(names: queue.order(uploads)),
    );
  }
}

final class _UploadQueuePreview extends StatelessWidget {
  const _UploadQueuePreview({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (index, name) in names.indexed)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(radius: 12, child: Text('${index + 1}')),
            title: Text(name),
            trailing: index == 0
                ? const Icon(Icons.cloud_upload_outlined)
                : const Text('Sırada'),
          ),
      ],
    );
  }
}
