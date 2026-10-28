// Düzelt: /dartadvance Projemde firstWhere, singleWhere, lastWhere ve boş olabilecek listede
//    first/last kullanan yerleri bul. firstWhereOrNull (koşulsuzsa dart:core firstOrNull) ile
//    düzelt, boş durum için test yaz.
// Üret: /dartadvance Bana ödeme ekranı için varsayılan teslimat adresini seçen bir sınıf yaz;
//    adres yoksa null dönsün, ekran "Adres ekle" göstersin.
import 'package:collection/collection.dart';

/// A delivery address on the checkout screen.
final class Address {
  const Address(this.title, {this.isDefault = false});

  final String title;
  final bool isDefault;
}

/// Checkout: the user's default delivery address.
final class AddressBook {
  // ✗ firstWhere throws StateError with no match: a new user cannot open checkout.
  Address defaultAddressWrong(List<Address> addresses) =>
      addresses.firstWhere((address) => address.isDefault);

  Address? defaultAddress(List<Address> addresses) =>
      addresses.firstWhereOrNull((address) => address.isDefault); // null → "Adres ekle"
}
