import 'package:dio/dio.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/live_tv_category.dart';

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

  Future<List<LiveTvChannel>> getLiveChannels() async {
    try {
      final url =
          '$_baseUrl/player_api.php?username=$username&password=$password&action=get_live_streams';
      final response = await Dio().get(url);
      final List<dynamic> data = response.data;

      return data
          .map(
            (json) => LiveTvChannel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } on Exception catch (e) {
      throw Exception('Greska pri ucitavanju LiveTvChannel: $e');
    }
  }

  Future<List<LiveTvCategory>> getLiveCategories() async {
    try {
      final url =
          '$_baseUrl/player_api.php?username=$username&password=$password&action=get_live_categories';
      final response = await Dio().get(url);
      final List<dynamic> data = response.data;

      return data
          .map(
            (json) => LiveTvCategory.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } on Exception catch (e) {
      throw Exception('Greska pri ucitavanju LiveTvCategory: $e');
    }
  }
}
