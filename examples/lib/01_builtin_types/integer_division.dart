({int pages, int lastPageItems}) paginate(int itemCount, int pageSize) => (
  // `~/` truncates toward zero and returns an int, unlike `/`.
  pages: (itemCount + pageSize - 1) ~/ pageSize,
  lastPageItems: itemCount % pageSize == 0 ? pageSize : itemCount % pageSize,
);

/// `%` is never negative; `remainder` keeps the dividend's sign.
({int modulo, int remainder}) wrapOffset(int offset, int length) => (
  modulo: offset % length,
  remainder: offset.remainder(length),
);

int truncatedHalf(int value) => value ~/ 2;
