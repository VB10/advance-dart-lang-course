// Düzelt: /dartadvance Projemde kullanıcı girdisini ya da sunucudan gelen metni int.parse /
//    double.parse ile okuyan yerleri bul. tryParse ile düzelt, virgüllü ve hatalı girdide alan
//    hatası göster, test yaz.
// Üret: /dartadvance Bana ürün ölçüsü formu yaz: genişlik ve yükseklik cm, Türkçe klavyede
//    virgülle girilebilsin, hatalı girdide alanın altında hata yazsın.

/// Product size form (cm); a Turkish keyboard types the decimal comma.
final class DimensionField {
  // ✗ '12,5' and '12a' throw FormatException; Save crashes.
  double parseWrong(String text) => double.parse(text);

  double? parse(String text) => double.tryParse(text.trim().replaceAll(',', '.')); // '12,5': 12.5

  String? errorText(String text) => parse(text) == null ? 'Geçerli bir ölçü girin' : null;
}
