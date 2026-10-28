part of '../class_design_view.dart';

/// Modifier cards 1–4 (to be redone as real screens).
final class _ModifierExamples {
  List<TopicExample> build() {
    final messages = PaymentMessages();
    const declined = PaymentDeclined('Yetersiz bakiye');

    final first = InvoiceItem('Kalem', 2, 500);
    final second = InvoiceItem('Kalem', 2, 500);

    final wrongRepo = ApiOrderRepository();
    final repo = ApiOrderRepository();
    for (var i = 0; i < 3; i++) {
      wrongRepo.findCustomerWrong('A1');
      repo.findCustomer('A1');
    }

    final wrongHistory = PlaylistHistory()
      ..record('Şarkı eklendi')
      ..record('Başlık değişti');
    final history = PlaylistHistory()
      ..record('Şarkı eklendi')
      ..record('Başlık değişti');
    wrongHistory.entriesWrong.clear();
    var historyResult = '';
    try {
      history.entries.clear();
    } on UnsupportedError {
      historyResult = 'clear reddedildi, ';
    }

    return [
      TopicExample(
        title: '1) sealed + exhaustive switch',
        negative: Text(messages.textWrong(declined)),
        positive: Text(messages.text(declined)),
      ),
      TopicExample(
        title: '2) final',
        negative: Text('${first.sameAsWrong(second)}'),
        positive: Text('${first.sameAs(second)}'),
      ),
      TopicExample(
        title: '3) interface vs base',
        negative: Text('${wrongRepo.fetches} API çağrısı'),
        positive: Text('${repo.fetches} API çağrısı'),
      ),
      TopicExample(
        title: '4) mixin class',
        negative: Text('${wrongHistory.entriesWrong.length} kayıt kaldı'),
        positive: Text('$historyResult${history.entries.length} kayıt kaldı'),
      ),
    ];
  }
}
