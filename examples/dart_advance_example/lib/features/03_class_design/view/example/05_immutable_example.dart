part of '../class_design_view.dart';

final class _ImmutableExample {
  TopicExample build() {
    final button = QuantityButton();
    final wrong = CartStore(CartLineWrong('Termos', 1), (l) => '${l.quantity}');
    button.increaseWrong(wrong);
    final right = CartStore(
      const CartLine('Termos', 1),
      (l) => '${l.quantity}',
    );
    button.increase(right);
    return TopicExample(
      title: '@immutable: adet + ekrana yansımıyor',
      negative: _QuantityPreview(quantity: wrong.shown),
      positive: _QuantityPreview(quantity: right.shown),
    );
  }
}

final class _QuantityPreview extends StatelessWidget {
  const _QuantityPreview({required this.quantity});

  final String quantity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.local_cafe_outlined),
      title: const Text('Termos'),
      subtitle: const Text("'+' 1 kez basıldı"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IconButton(onPressed: null, icon: Icon(Icons.remove)),
          Text(quantity, style: Theme.of(context).textTheme.titleMedium),
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}
