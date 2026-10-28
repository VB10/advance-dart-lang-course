typedef OrderIdAlias = int;
typedef CustomerIdAlias = int;

extension type const OrderId(int value) {}

extension type const CustomerId(int value) {}

/// Fatura ekranında sipariş ve müşteri numarasıyla fatura başlığı üreten servis.
final class InvoiceService {
  // Olumsuz: alias yalnız isimdir; iki ID de `int`, yer değişince de derlenir → numaralar karışır.
  String invoiceWrong(OrderIdAlias orderId, CustomerIdAlias customerId) =>
      'Sipariş #$orderId, müşteri #$customerId';

  // Olumlu: extension type ayrı tiptir; yer değişirse analyzer derlemeyi reddeder.
  String invoice(OrderId orderId, CustomerId customerId) =>
      'Sipariş #${orderId.value}, müşteri #${customerId.value}';
}
