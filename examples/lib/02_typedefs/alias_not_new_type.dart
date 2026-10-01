// /dartadvance Projemde `typedef X = int` gibi alias'la ID ya da birim tipi
// tanımlayan yerleri bul, `extension type` ile dönüştür, her biri için test yaz.
typedef UserIdAlias = int; // Just another name for int.

extension type const UserId(int value) {}

String describeAlias(UserIdAlias id) => 'user #$id';
String describeTyped(UserId id) => 'user #${id.value}';

int productCount() => 42;

String loadWithAlias() => describeAlias(productCount()); // user #42: wrong ID accepted

// describeTyped(productCount()) is rejected by the analyzer.
String loadWithTyped() => describeTyped(const UserId(7)); // user #7
