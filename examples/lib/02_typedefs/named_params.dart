// Düzelt: /dartadvance Projemde aynı türden konumsal parametreleri olan callback ve typedef
//    tiplerini bul, parametrelere isim ver (`required` isimli), test yaz.
// Üret: /dartadvance Bana havale ekranı için gönderen, alıcı ve kuruş alan isimli bir
//    typedef ve onu kullanan bir fonksiyon yaz.
typedef TransferWrong = String Function(String, String, int);
typedef Transfer = String Function({required String from, required String to, required int cents});

String moveWrong(String to, String from, int cents) => '$from -> $to: $cents'; // Order swapped
String sendWrong(TransferWrong run) => run('ali', 'veli', 5000); // veli -> ali: wrong way

String transfer({required String from, required String to, required int cents}) =>
    '$from -> $to: $cents';
String send(Transfer run) => run(from: 'ali', to: 'veli', cents: 5000); // ali -> veli

// send(moveWrong) is rejected by the analyzer: its parameters are not named from/to/cents.
