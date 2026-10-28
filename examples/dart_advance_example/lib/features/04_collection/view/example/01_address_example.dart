part of '../collection_view.dart';

final class _AddressExample {
  TopicExample build() {
    const addresses = [Address('İş'), Address('Annemler')];
    final book = AddressBook();
    String? error;
    try {
      book.defaultAddressWrong(addresses);
    } on StateError catch (e) {
      error = e.message;
    }
    return TopicExample(
      title: 'Varsayılan adres: firstWhere değil firstWhereOrNull',
      negative: _AddressPreview(error: error),
      positive: _AddressPreview(address: book.defaultAddress(addresses)),
    );
  }
}

final class _AddressPreview extends StatelessWidget {
  const _AddressPreview({this.address, this.error});

  final Address? address;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (error case final error?) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.error_outline, color: colors.error),
        title: const Text('Ödeme ekranı açılamadı'),
        subtitle: Text('StateError: $error'),
      );
    }
    if (address case final address?) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.home_outlined),
        title: Text(address.title),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.location_off_outlined),
          title: Text('Varsayılan teslimat adresin yok'),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Adres ekle'),
        ),
      ],
    );
  }
}
