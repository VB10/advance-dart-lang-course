typedef TransferWrong = String Function(String, String, int);
typedef Transfer = String Function({
  required String from,
  required String to,
  required int cents,
});

/// Havale ekranında gönderen, alıcı ve tutarı çağıran sınıf.
final class TransferScreen {
  // Olumsuz: parametre sırası ters yazılmış fonksiyon da bu typedef'e uyar → havale ters yöne gider.
  String moveWrong(String to, String from, int cents) =>
      '$from → $to: $cents kuruş';
  String sendWrong(TransferWrong run) => run('ali', 'veli', 5000);

  // Olumlu: isimli typedef; fonksiyon from/to/cents adlarıyla eşleşmek zorunda.
  String transfer({
    required String from,
    required String to,
    required int cents,
  }) => '$from → $to: $cents kuruş';
  String send(Transfer run) => run(from: 'ali', to: 'veli', cents: 5000);
}
