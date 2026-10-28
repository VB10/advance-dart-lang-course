// Düzelt: /dartadvance Projemde süreyi dakika:saniye ya da saat:dakika yazan yerleri bul. / ile
//    bölüp round/toInt yapanları ve padLeft'siz % kullananları ~/, % ve padLeft(2, '0') ile
//    düzelt, 125 sn girdisiyle test yaz.
// Üret: /dartadvance Bana doğrulama kodu ekranı için "Kodu tekrar gönder (m:ss)" metnini üreten
//    bir geri sayım sınıfı yaz.

/// OTP screen: remaining time on the "resend code" button.
final class ResendCountdown {
  // ✗ `/` is a double and round lifts 2.5 minutes to 3; seconds are not padded.
  String labelWrong(int seconds) => '${(seconds / 60).round()}:${seconds % 60}'; // 150: 3:30

  String label(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'; // 150: 2:30, 125: 2:05
}
