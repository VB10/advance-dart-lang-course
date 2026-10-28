part of '../home_view.dart';

final class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.topic, required this.onPressed});

  final HomeTopic topic;
  final VoidCallback onPressed;

  static const double _verticalPadding = 16;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      key: HomeKeys.topic(topic.number),
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
      ),
      child: Text('${topic.number.toString().padLeft(2, '0')}  ${topic.title}'),
    );
  }
}
