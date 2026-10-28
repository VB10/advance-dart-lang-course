part of '../class_design_view.dart';

final class _UseResultExample {
  TopicExample build() {
    const total = CheckoutTotal(25000);
    final wrong = CouponField(total)..applyWrong(5000);
    final right = CouponField(total)..apply(5000);
    return TopicExample(
      title: '@useResult: kupon uygulandı, toplam aynı',
      negative: _CouponPreview(field: wrong),
      positive: _CouponPreview(field: right),
    );
  }
}

final class _CouponPreview extends StatelessWidget {
  const _CouponPreview({required this.field});

  final CouponField field;

  String _format(int cents) =>
      '${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')} ₺';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.check_circle, color: colors.primary),
          title: const Text("'YAZ50' kuponu uygulandı"),
          subtitle: const Text('50,00 ₺ indirim'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Ödenecek tutar'),
          trailing: Text(
            _format(field.total.cents),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
