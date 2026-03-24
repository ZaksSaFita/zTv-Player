// lib/helpers/xtream_parser.dart

import 'package:dio/dio.dart';
import '../models/live_category.dart';
import '../models/live_channel.dart';
import '../models/vod_category.dart';
import '../models/vod_movie.dart';
import '../models/series_category.dart';
import '../models/series.dart';
import '../models/season.dart';
import '../models/episode.dart';

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
}
