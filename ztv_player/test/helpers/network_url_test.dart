import 'package:flutter_test/flutter_test.dart';
import 'package:ztv_player/helpers/network_url.dart';

void main() {
  group('normalizeServerUrlForDevice', () {
    test('removes trailing slash', () {
      expect(
        normalizeServerUrlForDevice('http://example.com:8080/'),
        'http://example.com:8080',
      );
    });

    test('removes player_api.php suffix', () {
      expect(
        normalizeServerUrlForDevice(
          'http://example.com:8080/player_api.php',
        ),
        'http://example.com:8080',
      );
    });

    test('removes get.php suffix', () {
      expect(
        normalizeServerUrlForDevice('http://example.com:8080/get.php'),
        'http://example.com:8080',
      );
    });
  });

  group('normalizeDirectStreamUrlForDevice', () {
    test('trims surrounding whitespace', () {
      expect(
        normalizeDirectStreamUrlForDevice('  http://example.com/live.ts  '),
        'http://example.com/live.ts',
      );
    });
  });
}
