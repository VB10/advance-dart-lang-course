import 'package:dart_advance_example/features/03_class_design/model/cart_line.dart';
import 'package:dart_advance_example/features/03_class_design/model/chat_controller.dart';
import 'package:dart_advance_example/features/03_class_design/model/coupon_total.dart';
import 'package:dart_advance_example/features/03_class_design/model/invoice_item.dart';
import 'package:dart_advance_example/features/03_class_design/model/order_repository.dart';
import 'package:dart_advance_example/features/03_class_design/model/order_store.dart';
import 'package:dart_advance_example/features/03_class_design/model/pay_button.dart';
import 'package:dart_advance_example/features/03_class_design/model/payment_messages.dart';
import 'package:dart_advance_example/features/03_class_design/model/playlist_history.dart';
import 'package:dart_advance_example/features/home/model/topic_example.dart';
import 'package:dart_advance_example/features/home/view/topic_examples_view.dart';
import 'package:flutter/material.dart';

part 'class_design_examples.dart';
part 'example/01_04_modifier_examples.dart';
part 'example/05_immutable_example.dart';
part 'example/06_use_result_example.dart';
part 'example/07_protected_example.dart';
part 'example/08_must_call_super_example.dart';

final class ClassDesignView extends StatelessWidget {
  const ClassDesignView({super.key});

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    return TopicExamplesView(
      title: '03  Class tasarımı',
      examples: ClassDesignExamples().build(),
    );
  }
}
