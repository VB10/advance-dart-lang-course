int parseWithApply(String source, int radix) =>
    Function.apply(int.parse, [source], {#radix: radix}) as int;
