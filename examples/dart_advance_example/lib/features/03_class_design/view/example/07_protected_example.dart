part of '../class_design_view.dart';

final class _ProtectedExample {
  TopicExample build() {
    final button = PayButton();
    final wrong = PaymentStore();
    button.onTapWrong(wrong);
    final right = PaymentStore();
    button.onTap(right, cardAccepted: false);
    return TopicExample(
      title: '@protected: reddedilen kart "Ödendi"',
      negative: _PaymentPreview(status: wrong.state),
      positive: _PaymentPreview(status: right.state),
    );
  }
}

final class _PaymentPreview extends StatelessWidget {
  const _PaymentPreview({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, color, text) = switch (status) {
      PaymentStatus.paid => (
        Icons.verified,
        colors.primary,
        'Ödendi · Sipariş hazırlanıyor',
      ),
      PaymentStatus.declined => (
        Icons.credit_card_off,
        colors.error,
        'Kart reddedildi',
      ),
      PaymentStatus.waiting => (
        Icons.hourglass_empty,
        colors.outline,
        'Ödeme bekleniyor',
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.credit_card),
          title: Text('•••• 4242'),
          subtitle: Text('Banka: yetersiz bakiye'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color),
          title: Text(text),
        ),
      ],
    );
  }
}
