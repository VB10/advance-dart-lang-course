import 'package:collection/collection.dart';

/// Ödeme ekranında teslimat adresi: kullanıcının varsayılan adresi.
final class Address {
  const Address(this.title, {this.isDefault = false});

  final String title;
  final bool isDefault;
}

final class AddressBook {
  // Olumsuz: firstWhere eşleşme yoksa StateError atar → yeni kullanıcıda ödeme ekranı açılmaz.
  Address defaultAddressWrong(List<Address> addresses) =>
      addresses.firstWhere((address) => address.isDefault);

  // Olumlu: firstWhereOrNull null döner; ekran "Adres ekle" gösterir.
  Address? defaultAddress(List<Address> addresses) =>
      addresses.firstWhereOrNull((address) => address.isDefault);
}
