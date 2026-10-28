import 'dart:convert';

import 'package:dart_advance_example/features/01_builtin_types/model/brand_page.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/category_slug.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/chat_preview.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/dimension_field.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/event_filter_sheet.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/event_time.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/locate_button.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/photo_gallery.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/pin_address_cache.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/product_price.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/product_sort.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/resend_countdown.dart';
import 'package:dart_advance_example/features/01_builtin_types/model/store_location.dart';
import 'package:dart_advance_example/features/home/model/topic_example.dart';
import 'package:dart_advance_example/features/home/view/topic_examples_view.dart';
import 'package:flutter/material.dart';

part 'builtin_types_examples.dart';
part 'example/01_price_example.dart';
part 'example/02_gallery_example.dart';
part 'example/03_countdown_example.dart';
part 'example/04_store_map_example.dart';
part 'example/05_dimension_example.dart';
part 'example/06_chat_example.dart';
part 'example/07_slug_example.dart';
part 'example/08_pin_cache_example.dart';
part 'example/09_event_time_example.dart';
part 'example/10_filter_sheet_example.dart';
part 'example/11_brand_grid_example.dart';
part 'example/12_product_sort_example.dart';
part 'example/13_locate_button_example.dart';

final class BuiltinTypesView extends StatelessWidget {
  const BuiltinTypesView({super.key});

  static const double _gap = 8;
  static const double _thumb = 64;

  @override
  Widget build(BuildContext context) {
    return TopicExamplesView(
      title: '01  Bildiğini sandığın tipler',
      examples: BuiltinTypesExamples().build(),
    );
  }
}
