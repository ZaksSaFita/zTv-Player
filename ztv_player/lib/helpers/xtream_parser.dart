import 'package:dio/dio.dart';
import 'package:ztv_player/models/live_category.dart';
import 'package:ztv_player/models/live_channel.dart';

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
          .map((json) => LiveChannel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on Exception catch (e) {
      throw Exception('Greska pri ucitavanju LiveChannel: $e');
    }
  }

  Future<List<LiveCategory>> getLiveCategories() async {
    try {
      final url =
          '$_baseUrl/player_api.php?username=$username&password=$password&action=get_live_categories';
      final response = await Dio().get(url);
      final List<dynamic> data = response.data;

      return data
          .map((json) => LiveCategory.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on Exception catch (e) {
      throw Exception('Greska pri ucitavanju LiveCategory: $e');
    }
  }
}
