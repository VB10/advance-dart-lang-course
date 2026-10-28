part of '../builtin_types_view.dart';

final class _CountdownExample {
  TopicExample build() {
    final countdown = ResendCountdown();
    const seconds = [150, 125];
    return TopicExample(
      title: 'Geri sayım: ~/ ve %',
      negative: _ResendPreview(
        labels: seconds.map(countdown.labelWrong).toList(),
      ),
      positive: _ResendPreview(labels: seconds.map(countdown.label).toList()),
    );
  }
}

final class _ResendPreview extends StatelessWidget {
  const _ResendPreview({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: BuiltinTypesView._gap,
      children: [
        for (final label in labels)
          OutlinedButton(
            onPressed: null,
            child: Text('Kodu tekrar gönder ($label)'),
          ),
      ],
    );
  }
}
