import 'package:flutter_test/flutter_test.dart';
import 'package:ztv_player/helpers/media_format.dart';

void main() {
  group('formatRating', () {
    test('formats numeric values to two decimals', () {
      expect(formatRating('8.5'), '8.50');
    });

    test('returns original value for non numeric input', () {
      expect(formatRating('N/A'), 'N/A');
    });
  });

  group('formatNullableRating', () {
    test('returns null for blank values', () {
      expect(formatNullableRating('   '), isNull);
      expect(formatNullableRating(null), isNull);
    });

    test('formats non blank values', () {
      expect(formatNullableRating('7'), '7.00');
    });
  });
}
