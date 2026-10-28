part of 'class_design_view.dart';

/// Pages of the class design topic, in order: modifiers 1–4, annotations 5–8.
final class ClassDesignExamples {
  List<TopicExample> build() => [
    ..._ModifierExamples().build(),
    _ImmutableExample().build(),
    _UseResultExample().build(),
    _ProtectedExample().build(),
    _MustCallSuperExample().build(),
  ];
}
