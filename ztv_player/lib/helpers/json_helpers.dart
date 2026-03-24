class JsonHelpers {
  static String asString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }

    if (value is List) {
      for (final item in value) {
        final normalized = asNullableString(item);
        if (normalized != null) {
          return normalized;
        }
      }
      return fallback;
    }

    return value.toString();
  }

  static String? asNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is List) {
      for (final item in value) {
        final normalized = asNullableString(item);
        if (normalized != null) {
          return normalized;
        }
      }
      return null;
    }

    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
  }

  static int asInt(dynamic value, {int fallback = 0}) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? fallback;
  }

  static int? asNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static DateTime? unixSecondsToLocalDateTime(dynamic value) {
    final seconds = asNullableInt(value);
    if (seconds == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
        .toLocal();
  }

  static String? unixSecondsToLocalTime(dynamic value) {
    final dateTime = unixSecondsToLocalDateTime(value);
    if (dateTime == null) {
      return null;
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String? yearFromDate(dynamic value) {
    final date = asNullableString(value);
    if (date == null || date.length < 4) {
      return null;
    }

    return date.substring(0, 4);
  }

  static DateTime? asNullableDateTime(dynamic value) {
    final raw = asNullableString(value);
    if (raw == null) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  static DateTime asDateTime(
    dynamic value, {
    DateTime? fallback,
  }) {
    return asNullableDateTime(value) ?? fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static List<Map<String, dynamic>> asMapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const <Map<String, dynamic>>[];
  }
}
