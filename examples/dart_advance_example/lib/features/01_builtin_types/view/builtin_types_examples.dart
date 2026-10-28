part of 'builtin_types_view.dart';

/// Pages of the built-in types topic, in order; each card lives in `example/`.
final class BuiltinTypesExamples {
  List<TopicExample> build() => [
    _PriceExample().build(),
    _GalleryExample().build(),
    _CountdownExample().build(),
    _StoreMapExample().build(),
    _DimensionExample().build(),
    _ChatExample().build(),
    _SlugExample().build(),
    _PinCacheExample().build(),
    _EventTimeExample().build(),
    _FilterSheetExample().build(),
    _BrandGridExample().build(),
    _ProductSortExample().build(),
    _LocateButtonExample().build(),
  ];
}
