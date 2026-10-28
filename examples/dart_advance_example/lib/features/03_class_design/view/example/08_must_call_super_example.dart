part of '../class_design_view.dart';

final class _MustCallSuperExample {
  TopicExample build() {
    final wrong = ChatControllerWrong()..dispose();
    final right = ChatController()..dispose();
    for (var i = 0; i < 3; i++) {
      wrong.onMessage();
      right.onMessage();
    }
    return TopicExample(
      title: '@mustCallSuper: kapalı sohbet mesajı okuyor',
      negative: _ChatListPreview(unread: 3 - wrong.markedRead),
      positive: _ChatListPreview(unread: 3 - right.markedRead),
    );
  }
}

final class _ChatListPreview extends StatelessWidget {
  const _ChatListPreview({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: ClassDesignView._gap,
      children: [
        const Text('Sohbetten çıkıldı, 3 yeni mesaj geldi'),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(child: Text('S')),
          title: const Text('Selin'),
          subtitle: Text(unread == 0 ? 'Görüldü' : 'Yeni mesaj'),
          trailing: unread == 0
              ? const Icon(Icons.done_all)
              : Badge(label: Text('$unread')),
        ),
      ],
    );
  }
}
