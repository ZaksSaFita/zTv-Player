import 'dart:io' show Platform;

String normalizeServerUrlForDevice(String server) {
  var normalized = server.trim();

  if (normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }

  if (normalized.endsWith('/player_api.php')) {
    normalized = normalized.substring(
      0,
      normalized.length - '/player_api.php'.length,
    );
  }

  if (normalized.endsWith('/get.php')) {
    normalized = normalized.substring(0, normalized.length - '/get.php'.length);
  }

  return _rewriteAndroidLoopbackUrl(normalized);
}

String normalizeDirectStreamUrlForDevice(String url) {
  return _rewriteAndroidLoopbackUrl(url.trim());
}

String _rewriteAndroidLoopbackUrl(String value) {
  if (!Platform.isAndroid) {
    return value;
  }

  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return value;
  }

  final host = uri.host.toLowerCase();
  if (host != 'localhost' && host != '127.0.0.1' && host != '::1') {
    return value;
  }

  return uri.replace(host: '10.0.2.2').toString();
}
