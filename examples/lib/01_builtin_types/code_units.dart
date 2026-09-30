const precomposed = 'café'; // é as one code point
const decomposed = 'café'; // e + combining acute accent

({int codeUnits, int runes}) measure(String text) =>
    (codeUnits: text.length, runes: text.runes.length);
