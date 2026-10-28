part of '../builtin_types_view.dart';

final class _PinCacheExample {
  TopicExample build() {
    const taps = 3;
    final cache = PinAddressCache();
    var wrong = '';
    var right = '';
    for (var i = 0; i < taps; i++) {
      wrong = cache.addressWrong(40.9903, 29.0277);
      right = cache.address(40.9903, 29.0277);
    }
    return TopicExample(
      title: 'Önbellek anahtarı: List değil record',
      negative: _PinPreview(
        address: wrong,
        taps: taps,
        requests: cache.requestsWrong,
      ),
      positive: _PinPreview(
        address: right,
        taps: taps,
        requests: cache.requests,
      ),
    );
  }
}

final class _PinPreview extends StatelessWidget {
  const _PinPreview({
    required this.address,
    required this.taps,
    required this.requests,
  });

  final String address;
  final int taps;
  final int requests;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.place),
      title: Text(address),
      subtitle: Text('Pine $taps kez dokunuldu · $requests sunucu isteği'),
    );
  }
}
