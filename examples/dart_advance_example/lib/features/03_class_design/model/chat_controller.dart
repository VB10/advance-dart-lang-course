// Düzelt: /dartadvance Projemde dispose, close, cancel gibi temizlik yapan taban sınıf
//    metotlarını ve override edip super çağırmayan alt sınıfları bul. Tabana @mustCallSuper
//    ekle, ekrandan çıkınca dinleyicinin kapandığını test et.
// Üret: /dartadvance Bana gelen mesajları dinleyen bir sohbet controller'ı yaz; taban sınıf
//    dispose'da aboneliği kapatsın, alt sınıflar super.dispose() çağırmak zorunda olsun.
import 'package:meta/meta.dart';

/// Base controller: listens to incoming messages until dispose.
abstract base class MessageListener {
  bool listening = true;
  int markedRead = 0;

  /// Called by the socket for every incoming message.
  void onMessage() {
    if (listening) markedRead++; // the open chat marks messages as read
  }

  @mustCallSuper
  void dispose() => listening = false;
}

// ✗ Overrides dispose without super: the closed chat keeps marking messages as read.
final class ChatControllerWrong extends MessageListener {
  bool typingCleared = false;

  @override
  // ignore: must_call_super
  void dispose() => typingCleared = true;
}

final class ChatController extends MessageListener {
  bool typingCleared = false;

  @override
  void dispose() {
    typingCleared = true;
    super.dispose();
  }
}
