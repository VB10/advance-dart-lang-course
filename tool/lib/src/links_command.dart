import 'dart:io';

import 'package:args/command_runner.dart';

import 'snippets_command.dart';
import 'workspace.dart';

final _docsLink = RegExp(r'https://dart\.dev/[\w/.-]*#[\w-]+');
final _id = RegExp(r'id="([^"]+)"');

/// Every distinct `https://dart.dev/...#anchor` link in [markdown].
Set<String> dartDevAnchorLinks(String markdown) => {
  for (final m in _docsLink.allMatches(markdown)) m.group(0)!,
};

/// `dartadvance links` — fails when a dart.dev `#anchor` link in the
/// references no longer exists on the live page.
class LinksCommand extends Command<int> {
  @override
  String get name => 'links';

  @override
  String get description =>
      'Check every dart.dev #anchor link in the references against live pages.';

  @override
  Future<int> run() async {
    final root = findWorkspaceRoot();
    final links = <String>{};
    for (final doc in skillMarkdownFiles(root)) {
      links.addAll(dartDevAnchorLinks(doc.readAsStringSync()));
    }

    final client = HttpClient();
    final pageIds = <String, Set<String>>{};
    final broken = <String>[];
    try {
      for (final link in links.toList()..sort()) {
        final [page, anchor] = link.split('#');
        final ids = pageIds[page] ??= await _ids(client, page);
        if (!ids.contains(anchor)) broken.add(link);
      }
    } finally {
      client.close();
    }

    if (broken.isEmpty) {
      stdout.writeln('links: ${links.length} dart.dev anchors OK');
      return 0;
    }
    stderr.writeln('links: ${broken.length} broken anchor(s):');
    broken.forEach(stderr.writeln);
    return 1;
  }

  Future<Set<String>> _ids(HttpClient client, String url) async {
    final response = await (await client.getUrl(Uri.parse(url))).close();
    final body = await response.transform(systemEncoding.decoder).join();
    return {for (final m in _id.allMatches(body)) m.group(1)!};
  }
}
