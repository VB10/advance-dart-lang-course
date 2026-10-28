// Düzelt: /dartadvance Projemde istek gövdesi, query parametresi ya da widget listesi kurarken
//    null değeri gönderen veya if (x != null) yazan yerleri bul. 'key': ?value ve ?widget ile
//    düzelt, gönderilen gövdeyi testle kontrol et. SDK 3.8 altındaysa önce söyle.
// Üret: /dartadvance Bana profil düzenleme için yalnız değişen alanları gönderen bir PATCH
//    gövdesi kuran sınıf yaz.

/// Edit profile: only the changed fields go in the PATCH body.
final class ProfilePatch {
  // ✗ Sends "bio": null; the server overwrites the stored bio.
  Map<String, Object?> bodyWrong({String? name, String? bio}) => {'name': name, 'bio': bio};

  Map<String, Object> body({String? name, String? bio}) => {
    'name': ?name,
    'bio': ?bio,
  }; // (name: 'Ayşe'): {'name': 'Ayşe'}

  Map<String, Object?> apply(Map<String, Object?> stored, Map<String, Object?> body) => {
    ...stored,
    ...body,
  };
}
