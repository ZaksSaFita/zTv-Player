String formatRating(String? value) {
  final rating = double.tryParse(value ?? '');
  if (rating == null) {
    return value ?? '';
  }

  return rating.toStringAsFixed(2);
}

String? formatNullableRating(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  return formatRating(value);
}
