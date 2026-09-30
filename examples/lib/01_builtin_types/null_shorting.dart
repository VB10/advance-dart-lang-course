final class Address {
  const Address(this.city);
  final String city;
}

final class Customer {
  const Customer(this.address);
  final Address address;
}

int? cityLength(Customer? customer) => customer?.address.city.length; // One `?.` is enough.
