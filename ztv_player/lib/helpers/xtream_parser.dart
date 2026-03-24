// lib/helpers/xtream_parser.dart

import 'package:dio/dio.dart';
import '../models/live_category.dart';
import '../models/live_channel.dart';
// import '../models/vod_category.dart';
// import '../models/vod_movie.dart';
// import '../models/series_category.dart';
// import '../models/series.dart';
// import '../models/season.dart';
// import '../models/episode.dart';

class XtreamParser {
  final String server;
  final String username;
  final String password;

  XtreamParser({
    required this.server,
    required this.username,
    required this.password,
  });

  String get _baseUrl =>
      server.endsWith('/') ? server.substring(0, server.length - 1) : server;

  Future<List<LiveChannel>> getLiveChannels() async {
    try {
      final url =
          '$_baseUrl/player_api.php?username=$username&password=$password&action=get_live_streams';
      final response = await Dio().get(url);
      final List<dynamic> data = response.data;

      return data
          .map(
            (json) => LiveChannel(
              id: json['stream_id'].toString(),
              name: json['name'],
              categoryId: json['category_id'].toString(),
              logoUrl: json['stream_icon'],
              num: json['num'] != null
                  ? int.tryParse(json['num'].toString())
                  : null,
            ),
          )
          .toList();
    } on Exception catch (e) {
      throw Exception('Greška pri učitavanju LiveChannel: $e');
    }
  }

  Future<List<LiveCategory>> getLiveCategories() async {
    try {
      final url =
          '$_baseUrl/player_api.php?username=$username&password=$password&action=get_live_categories';
      final response = await Dio().get(url);
      final List<dynamic> data = response.data;

      return data
          .map(
            (json) => LiveCategory(
              id: json['category_id'].toString(),
              name: json['category_name'],
            ),
          )
          .toList();
    } on Exception catch (e) {
      throw Exception('Greška pri učitavanju LiveCategory: $e');
    }
  }
}
