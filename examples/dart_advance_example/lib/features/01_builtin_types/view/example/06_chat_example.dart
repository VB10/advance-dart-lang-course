part of '../builtin_types_view.dart';

final class _ChatExample {
  TopicExample build() {
    const chats = [
      (name: 'Aile', message: 'Pazar kahvaltısı 👨‍👩‍👧 sizde mi?'),
      (name: 'Selin', message: 'Tamam, yarın görüşürüz'),
    ];
    final preview = ChatPreview();
    return TopicExample(
      title: 'Mesaj önizlemesi: substring değil characters',
      negative: _ChatPreview(
        chats: [
          for (final chat in chats)
            (name: chat.name, preview: preview.textWrong(chat.message)),
        ],
      ),
      positive: _ChatPreview(
        chats: [
          for (final chat in chats)
            (name: chat.name, preview: preview.text(chat.message)),
        ],
      ),
    );
  }
}

final class _ChatPreview extends StatelessWidget {
  const _ChatPreview({required this.chats});

  final List<({String name, String preview})> chats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final chat in chats)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text(chat.name.characters.first)),
            title: Text(chat.name),
            subtitle: Text(chat.preview, maxLines: 1),
          ),
      ],
    );
  }
}
