import 'dart:async';

import 'package:dart_advance_example/features/home/model/home_topic.dart';
import 'package:dart_advance_example/features/home/view/home_keys.dart';
import 'package:flutter/material.dart';

part 'mixin/home_view_mixin.dart';
part 'widget/_home_button.dart';

final class HomeView extends StatefulWidget {
  const HomeView({required this.topics, super.key});

  final List<HomeTopic> topics;

  @override
  State<HomeView> createState() => _HomeViewState();
}

final class _HomeViewState extends State<HomeView> with HomeViewMixin {
  static const double _listPadding = 16;
  static const double _itemGap = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dart Advance')),
      body: widget.topics.isEmpty
          ? const Center(key: HomeKeys.empty, child: Text('No topics yet'))
          : ListView.separated(
              key: HomeKeys.list,
              padding: const EdgeInsets.all(_listPadding),
              itemCount: widget.topics.length,
              separatorBuilder: (_, _) => const SizedBox(height: _itemGap),
              itemBuilder: (_, index) {
                final topic = widget.topics[index];
                return _HomeButton(
                  topic: topic,
                  onPressed: () => openTopic(topic),
                );
              },
            ),
    );
  }
}
