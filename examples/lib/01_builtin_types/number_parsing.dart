int? parseQuantity(String input) => int.tryParse(input.trim());

int parseHexColor(String hex) => int.parse(hex, radix: 16);
