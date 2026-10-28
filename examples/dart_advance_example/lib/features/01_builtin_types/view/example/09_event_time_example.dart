part of '../builtin_types_view.dart';

final class _EventTimeExample {
  TopicExample build() {
    const iso = '2026-11-02T17:30:00Z';
    final event = EventTime();
    return TopicExample(
      title: "API saati UTC: toLocal'i unutma",
      negative: _EventTimePreview(time: event.label(event.startWrong(iso))),
      positive: _EventTimePreview(time: event.label(event.start(iso))),
    );
  }
}

final class _EventTimePreview extends StatelessWidget {
  const _EventTimePreview({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event),
      title: const Text('Açık hava konseri · Harbiye'),
      subtitle: const Text('2 Kasım Pazartesi'),
      trailing: Text(time, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
