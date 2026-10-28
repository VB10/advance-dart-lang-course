/// Doğrulama kodu ekranında "Tekrar gönder" butonundaki geri sayım metni.
final class ResendCountdown {
  // Olumsuz: `/` double verir, round yukarı yuvarlar, saniye doldurulmaz → 150 sn '3:30', 125 sn '2:5'.
  String labelWrong(int seconds) => '${(seconds / 60).round()}:${seconds % 60}';

  // Olumlu: `~/ 60` tam dakika, `% 60` kalan saniye, padLeft iki hane → '2:30', '2:05'.
  String label(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}
