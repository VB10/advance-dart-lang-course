({List<String> mapKeys, List<String> setElements}) literalOrder() {
  final scores = {'zeynep': 3, 'ali': 5, 'mert': 1};
  final tags = {'flutter', 'dart', 'async'};
  scores['bora'] = 2;
  scores['ali'] = 9; // Updating a key keeps its position.
  return (mapKeys: scores.keys.toList(), setElements: tags.toList());
}
