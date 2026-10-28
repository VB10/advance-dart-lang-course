import 'dart:convert';

import 'package:characters/characters.dart';
import 'package:dartadvance_examples/01_builtin_types/brand_page.dart';
import 'package:dartadvance_examples/01_builtin_types/category_slug.dart';
import 'package:dartadvance_examples/01_builtin_types/chat_preview.dart';
import 'package:dartadvance_examples/01_builtin_types/dimension_field.dart';
import 'package:dartadvance_examples/01_builtin_types/event_filter_sheet.dart';
import 'package:dartadvance_examples/01_builtin_types/event_time.dart';
import 'package:dartadvance_examples/01_builtin_types/locate_button.dart';
import 'package:dartadvance_examples/01_builtin_types/photo_gallery.dart';
import 'package:dartadvance_examples/01_builtin_types/pin_address_cache.dart';
import 'package:dartadvance_examples/01_builtin_types/product_price.dart';
import 'package:dartadvance_examples/01_builtin_types/product_sort.dart';
import 'package:dartadvance_examples/01_builtin_types/resend_countdown.dart';
import 'package:dartadvance_examples/01_builtin_types/store_location.dart';
import 'package:test/test.dart';

void main() {
  group('product_price', () {
    final price = ProductPrice();

    test('double toString shows a raw number', () {
      expect(price.labelWrong(24999.9), '24999.9 ₺');
      expect(price.labelWrong(29999), '29999.0 ₺');
    });

    test('int cents with ~/ and % shows lira, kuruş and thousands', () {
      expect(price.label(2499990), '24.999,90 ₺');
      expect(price.label(5), '0,05 ₺');
    });
  });

  group('photo_gallery', () {
    const gallery = PhotoGallery(5);

    test('remainder keeps the sign: back from the first photo is -1', () {
      expect(gallery.previousWrong(0), -1);
    });

    test('% wraps back to the last photo and forward to the first', () {
      expect(gallery.previous(0), 4);
      expect(gallery.next(4), 0);
    });
  });

  group('resend_countdown', () {
    final countdown = ResendCountdown();

    test('/ with round shows 3:30 and 2:5', () {
      expect(countdown.labelWrong(150), '3:30');
      expect(countdown.labelWrong(125), '2:5');
    });

    test('~/ and % with padLeft show 2:30 and 2:05', () {
      expect(countdown.label(150), '2:30');
      expect(countdown.label(125), '2:05');
      expect(countdown.label(59), '0:59');
    });
  });

  group('store_location', () {
    final json = jsonDecode('{"latitude": 41, "longitude": 29.0}') as Map<String, Object?>;

    test('as double throws when JSON sends a whole number', () {
      expect(json['latitude'], isA<int>());
      expect(() => StoreLocation.fromJsonWrong(json), throwsA(isA<TypeError>()));
    });

    test('as num then toDouble accepts int and double', () {
      final location = StoreLocation.fromJson(json);
      expect(location.latitude, 41.0);
      expect(location.longitude, 29.0);
    });
  });

  group('dimension_field', () {
    final field = DimensionField();

    test('double.parse throws on a decimal comma and on typos', () {
      expect(() => field.parseWrong('12,5'), throwsFormatException);
      expect(() => field.parseWrong('12a'), throwsFormatException);
    });

    test('tryParse reads the comma and returns null instead of throwing', () {
      expect(field.parse('12,5'), 12.5);
      expect(field.parse(' 40 '), 40);
      expect(field.parse('12a'), isNull);
      expect(field.errorText('12a'), isNotNull);
      expect(field.errorText('12,5'), isNull);
    });
  });

  group('chat_preview', () {
    const message = 'Pazar kahvaltısı 👨‍👩‍👧 sizde mi?';
    final preview = ChatPreview();

    test('substring splits the family emoji', () {
      final text = preview.textWrong(message);
      expect(text, contains('👨‍👩'));
      expect(text, isNot(contains('👨‍👩‍👧')));
    });

    test('characters keeps the emoji whole', () {
      final text = preview.text(message);
      expect(text, contains('👨‍👩‍👧'));
      expect(text.characters.length, ChatPreview.maxLength + 1);
    });
  });

  group('category_slug', () {
    final slug = CategorySlug();

    test('[^a-z0-9] removes Turkish letters', () {
      expect(slug.slugWrong('Öne Çıkan Ürünler'), 'ne-kan-r-nler');
    });

    test('Turkish letters are mapped before cleaning', () {
      expect(slug.slug('Öne Çıkan Ürünler'), 'one-cikan-urunler');
      expect(slug.slug('İndirimli Ayakkabı & Çanta'), 'indirimli-ayakkabi-canta');
    });
  });

  group('pin_address_cache', () {
    test('a List key never hits: every tap asks the server', () {
      final cache = PinAddressCache();
      for (var i = 0; i < 3; i++) {
        cache.addressWrong(40.99, 29.02);
      }
      expect(cache.requestsWrong, 3);
    });

    test('a record key compares by value: one request', () {
      final cache = PinAddressCache();
      for (var i = 0; i < 3; i++) {
        cache.address(40.99, 29.02);
      }
      expect(cache.requests, 1);
    });
  });

  group('event_time', () {
    const iso = '2026-11-02T17:30:00Z';
    final event = EventTime();

    test('parse keeps a Z time in UTC', () {
      final time = event.startWrong(iso);
      expect(time.isUtc, isTrue);
      expect(event.label(time), '17:30');
    });

    test('toLocal moves it to the device time zone', () {
      final time = event.start(iso);
      expect(time.isUtc, isFalse);
      expect(time.isAtSameMomentAs(DateTime.utc(2026, 11, 2, 17, 30)), isTrue);
    });
  });

  group('event_filter_sheet', () {
    test('late final keeps the first language, the getter follows the change', () {
      final sheet = EventFilterSheet('tr');
      expect(sheet.titlesWrong.first, 'Bekleyen');
      sheet.language = 'en';
      expect(sheet.titlesWrong.first, 'Bekleyen');
      expect(sheet.titles.first, 'Pending');
    });
  });

  group('brand_page', () {
    const brands = [
      Brand('Nova', 3),
      Brand('Arda', 1),
      Brand('Taslak', 0, visible: false),
      Brand('Mavi', 2),
    ];

    List<String> readLikeAGrid(List<Brand> Function() visible) => [
      for (var i = 0; i < visible().length; i++) visible()[i].name,
    ];

    test('the getter sorts on every read', () {
      final page = BrandPage(brands);
      expect(readLikeAGrid(() => page.visibleWrong), ['Arda', 'Mavi', 'Nova']);
      expect(page.sorts, 7);
    });

    test('late final sorts once', () {
      final page = BrandPage(brands);
      expect(readLikeAGrid(() => page.visible), ['Arda', 'Mavi', 'Nova']);
      expect(page.sorts, 1);
    });
  });

  group('product_sort', () {
    final sort = ProductSort();

    test('..sort reorders the source list too', () {
      final products = ['Zeytinyağı', 'Bal', 'Peynir'];
      final az = sort.alphabeticalWrong(products);
      expect(identical(az, products), isTrue);
      expect(products, ['Bal', 'Peynir', 'Zeytinyağı']);
    });

    test('copy then cascade keeps the server order', () {
      final products = ['Zeytinyağı', 'Bal', 'Peynir'];
      expect(sort.alphabetical(products), ['Bal', 'Peynir', 'Zeytinyağı']);
      expect(products, ['Zeytinyağı', 'Bal', 'Peynir']);
    });
  });

  group('locate_button', () {
    test('! throws when the map is not ready', () {
      expect(() => LocateButton().onTapWrong('Kadıköy'), throwsA(isA<TypeError>()));
    });

    test('?.. skips the whole chain until the map is ready', () {
      final button = LocateButton()..onTap('Kadıköy');
      expect(button.camera, isNull);

      button
        ..camera = MapCamera()
        ..onTap('Kadıköy');
      expect(button.camera?.pin, 'Kadıköy');
    });
  });
}
