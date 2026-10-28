import 'package:dart_advance_example/features/04_collection/model/address_book.dart';
import 'package:dart_advance_example/features/04_collection/model/cart_history.dart';
import 'package:dart_advance_example/features/04_collection/model/filter_draft.dart';
import 'package:dart_advance_example/features/04_collection/model/order_history.dart';
import 'package:dart_advance_example/features/04_collection/model/price_sort.dart';
import 'package:dart_advance_example/features/04_collection/model/product_grid.dart';
import 'package:dart_advance_example/features/04_collection/model/upload_queue.dart';
import 'package:dart_advance_example/features/home/model/topic_example.dart';
import 'package:dart_advance_example/features/home/view/topic_examples_view.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';

part 'collection_examples.dart';
part 'example/01_address_example.dart';
part 'example/02_order_history_example.dart';
part 'example/03_filter_example.dart';
part 'example/04_product_grid_example.dart';
part 'example/05_price_sort_example.dart';
part 'example/06_upload_queue_example.dart';
part 'example/07_cart_history_example.dart';

final class CollectionView extends StatelessWidget {
  const CollectionView({super.key});

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    return TopicExamplesView(
      title: '04  Collection',
      examples: CollectionExamples().build(),
    );
  }
}
