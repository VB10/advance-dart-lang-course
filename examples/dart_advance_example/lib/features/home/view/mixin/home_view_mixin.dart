part of '../home_view.dart';

mixin HomeViewMixin on State<HomeView> {
  void openTopic(HomeTopic topic) {
    unawaited(
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: topic.builder)),
    );
  }
}
