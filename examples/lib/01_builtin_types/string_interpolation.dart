String greeting(String name, int unread) =>
    'Hi $name, you have ${unread + 1} new '
    'messages.'; // Adjacent literals: joined at compile time, no `+`.
