typedef UserIdAlias = int;

extension type const UserId(int value) {}

String describeAlias(UserIdAlias id) => 'user #$id';
String describeTyped(UserId id) => 'user #${id.value}';

// A product count is also an int, so the alias accepts it silently.
UserIdAlias productCount() => 42;

String loadProfileWithAlias() => describeAlias(productCount());

// describeTyped(productCount()) is rejected by the analyzer.
String loadProfileWithTyped() => describeTyped(const UserId(7));
