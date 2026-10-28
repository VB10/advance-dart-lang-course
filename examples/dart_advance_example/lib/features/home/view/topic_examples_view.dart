import 'package:dart_advance_example/features/home/model/topic_example.dart';
import 'package:flutter/material.dart';

/// Shared topic page: one example per page, swiped left to the next one.
final class TopicExamplesView extends StatefulWidget {
  const TopicExamplesView({
    required this.title,
    required this.examples,
    super.key,
  });

  final String title;
  final List<TopicExample> examples;

  @override
  State<TopicExamplesView> createState() => _TopicExamplesViewState();
}

final class _TopicExamplesViewState extends State<TopicExamplesView> {
  static const double _padding = 16;
  static const Duration _pageDuration = Duration(milliseconds: 250);

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) => _controller.animateToPage(
    page,
    duration: _pageDuration,
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final count = widget.examples.length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: PageView.builder(
        controller: _controller,
        itemCount: count,
        onPageChanged: (page) => setState(() => _page = page),
        itemBuilder: (_, index) =>
            _ExamplePage(example: widget.examples[index]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _padding),
          child: Row(
            children: [
              IconButton(
                onPressed: _page > 0 ? () => _goTo(_page - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${_page + 1} / $count',
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: _page < count - 1 ? () => _goTo(_page + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ExamplePage extends StatelessWidget {
  const _ExamplePage({required this.example});

  final TopicExample example;

  static const double _padding = 16;
  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(_padding),
      children: [
        Text(example.title, style: theme.textTheme.titleLarge),
        const SizedBox(height: _gap),
        _Side(label: 'Olumsuz', color: scheme.error, child: example.negative),
        const SizedBox(height: _gap),
        _Side(label: 'Olumlu', color: scheme.primary, child: example.positive),
      ],
    );
  }
}

final class _Side extends StatelessWidget {
  const _Side({required this.label, required this.color, required this.child});

  final String label;
  final Color color;
  final Widget child;

  static const double _padding = 12;
  static const double _radius = 12;
  static const double _border = 2;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: _border),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: _padding,
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
