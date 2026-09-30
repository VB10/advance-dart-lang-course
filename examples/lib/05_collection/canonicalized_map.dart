import 'package:collection/collection.dart';

CanonicalizedMap<String, String, String> headers() =>
    CanonicalizedMap<String, String, String>((key) => key.toLowerCase());
