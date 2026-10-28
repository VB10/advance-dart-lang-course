part of 'collection_view.dart';

/// Pages of the collection topic, in order; each card lives in `example/`.
final class CollectionExamples {
  List<TopicExample> build() => [
    _AddressExample().build(),
    _OrderHistoryExample().build(),
    _FilterExample().build(),
    _ProductGridExample().build(),
    _PriceSortExample().build(),
    _UploadQueueExample().build(),
    _CartHistoryExample().build(),
  ];
}
