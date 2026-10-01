// Skill'e ver: "Projemde `/` sonucunu `toInt()`/`ceil()` ile tamsayıya çeviren ve
// negatif değerde `%` kullanan yerleri bul, `~/` ve `remainder` ile düzelt, test yaz."

// Naive: goes through double just to get an int back.
int pagesNaive(int items, int size) => (items / size).ceil();

int pages(int items, int size) => (items + size - 1) ~/ size;

int truncatedHalf(int value) => value ~/ 2; // -7: -3

/// `%` is never negative, so it wraps a cyclic index.
int wrapIndex(int offset, int length) => offset % length; // (-1, 5): 4

/// `remainder` keeps the sign of the dividend.
int signedRemainder(int offset, int length) => offset.remainder(length); // (-1, 5): -1
