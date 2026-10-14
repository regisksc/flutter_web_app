import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_app/core/error/failure.dart';
import 'package:flutter_web_app/features/short_links/domain/rules/short_link_rules.dart';

void main() {
  group('validateLongUrl', () {
    test('accepts http and https URLs with a host', () {
      expect(validateLongUrl('https://example.com/a?b=1'), isNull);
      expect(validateLongUrl('http://example.com'), isNull);
    });

    test('rejects empty input', () {
      expect(validateLongUrl(''), isA<ValidationFailure>());
    });

    test('rejects schemes other than http and https', () {
      expect(validateLongUrl('ftp://example.com'), isA<ValidationFailure>());
      expect(validateLongUrl('javascript:alert(1)'), isA<ValidationFailure>());
    });

    test('rejects a URL without a host', () {
      expect(validateLongUrl('https://'), isA<ValidationFailure>());
    });

    test('rejects text that is not a URL', () {
      expect(validateLongUrl('not a url'), isA<ValidationFailure>());
    });

    test('accepts a URL of exactly 2048 characters', () {
      final url =
          'https://example.com/${'a' * (2048 - 'https://example.com/'.length)}';
      expect(url.length, 2048);
      expect(validateLongUrl(url), isNull);
    });

    test('rejects a URL longer than 2048 characters', () {
      final url = 'https://example.com/${'a' * 2048}';
      expect(validateLongUrl(url), isA<ValidationFailure>());
    });
  });

  group('validateAlias', () {
    test('a missing alias is allowed', () {
      expect(validateAlias(null), isNull);
    });

    test('accepts 3 to 20 letters, digits, underscores and hyphens', () {
      expect(validateAlias('abc'), isNull);
      expect(validateAlias('A_b-9'), isNull);
      expect(validateAlias('a' * 20), isNull);
    });

    test('rejects aliases shorter than 3 or longer than 20 characters', () {
      expect(validateAlias('ab'), isA<ValidationFailure>());
      expect(validateAlias('a' * 21), isA<ValidationFailure>());
    });

    test('rejects characters outside the allowed set', () {
      expect(validateAlias('my alias'), isA<ValidationFailure>());
      expect(validateAlias('a/b'), isA<ValidationFailure>());
      expect(validateAlias('héllo'), isA<ValidationFailure>());
    });

    test('rejects reserved words', () {
      for (final word in ['api', 'admin', 'links', 'health']) {
        expect(validateAlias(word), isA<ValidationFailure>(), reason: word);
      }
    });

    test('rejects reserved words in any letter case', () {
      expect(validateAlias('API'), isA<ValidationFailure>());
    });

    test('keeps aliases case-sensitive when they are not reserved', () {
      expect(validateAlias('Promo'), isNull);
      expect(validateAlias('promo'), isNull);
    });

    test('lists the reserved words', () {
      expect(reservedAliases, containsAll(['api', 'admin', 'links', 'health']));
    });
  });
}
