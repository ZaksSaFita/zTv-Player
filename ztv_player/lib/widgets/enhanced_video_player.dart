import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'app_video_player.dart';
import 'enhanced_player_action_bar.dart';

/// Kombinira AppVideoPlayer sa EnhancedPlayerActionBar u jedan widget
class EnhancedVideoPlayer extends StatefulWidget {
  const EnhancedVideoPlayer({
    super.key,
    required this.streamUrl,
    this.playlistDataSources,
    this.initialPlaylistIndex = 0,
    this.placeholderImageUrl,
    this.autoInitialize = true,
    this.isLiveStream = true,
    this.idleTitle,
    this.idleActionLabel,
    this.onIdleAction,
    this.onPlaylistIndexChanged,
    this.onControllerReady,
    this.onIsPlayingChanged,
    this.overlay,
    this.enableSkips,
    // Enhanced bar callbacks
    this.onPrevious,
    this.onNext,
    this.onFavoriteToggle,
    this.onFullscreen,
    this.onPositionChanged,
    this.isFavorite = false,
  });

  final String? streamUrl;
  final List<BetterPlayerDataSource>? playlistDataSources;
  final int initialPlaylistIndex;
  final String? placeholderImageUrl;
  final bool autoInitialize;
  final bool isLiveStream;
  final String? idleTitle;
  final String? idleActionLabel;
  final VoidCallback? onIdleAction;
  final ValueChanged<int>? onPlaylistIndexChanged;
  final ValueChanged<BetterPlayerController>? onControllerReady;
  final ValueChanged<bool>? onIsPlayingChanged;
  final Widget? overlay;
  final bool? enableSkips;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onFullscreen;
  final ValueChanged<Duration>? onPositionChanged;
  final bool isFavorite;

  @override
  State<EnhancedVideoPlayer> createState() => _EnhancedVideoPlayerState();
}

class _EnhancedVideoPlayerState extends State<EnhancedVideoPlayer> {
  late final ValueNotifier<bool> _isPlayingNotifier;
  late final ValueNotifier<Duration> _durationNotifier;
  late final ValueNotifier<Duration> _positionNotifier;
  late final ValueNotifier<bool> _isFullscreenNotifier;
  BetterPlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    _isPlayingNotifier = ValueNotifier(false);
    _durationNotifier = ValueNotifier(Duration.zero);
    _positionNotifier = ValueNotifier(Duration.zero);
    _isFullscreenNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    _isPlayingNotifier.dispose();
    _durationNotifier.dispose();
    _positionNotifier.dispose();
    _isFullscreenNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPlayingNotifier,
      builder: (context, isPlaying, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isFullscreenNotifier,
          builder: (context, isFullscreen, _) {
            return ValueListenableBuilder<Duration>(
              valueListenable: _durationNotifier,
              builder: (context, duration, _) {
                return ValueListenableBuilder<Duration>(
                  valueListenable: _positionNotifier,
                  builder: (context, position, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Player
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: AppVideoPlayer(
                            streamUrl: widget.streamUrl,
                            playlistDataSources: widget.playlistDataSources,
                            initialPlaylistIndex: widget.initialPlaylistIndex,
                            placeholderImageUrl: widget.placeholderImageUrl,
                            autoInitialize: widget.autoInitialize,
                            isLiveStream: widget.isLiveStream,
                            idleTitle: widget.idleTitle,
                            idleActionLabel: widget.idleActionLabel,
                            onIdleAction: widget.onIdleAction,
                            onPlaylistIndexChanged:
                                widget.onPlaylistIndexChanged,
                            onControllerReady: (controller) {
                              _playerController = controller;
                              widget.onControllerReady?.call(controller);
                            },
                            onIsPlayingChanged: (isPlaying) {
                              _isPlayingNotifier.value = isPlaying;
                              widget.onIsPlayingChanged?.call(isPlaying);
                            },
                            onDurationChanged: (duration) {
                              _durationNotifier.value = duration;
                            },
                            onPositionChanged: (position) {
                              _positionNotifier.value = position;
                            },
                            overlay: widget.overlay,
                            enableSkips: widget.enableSkips,
                          ),
                        ),
                        // Enhanced Player Bar
                        EnhancedPlayerActionBar(
                          isPlaying: isPlaying,
                          isLiveStream: widget.isLiveStream,
                          duration: duration,
                          position: position,
                          onPlayPause: () {
                            if (isPlaying) {
                              _playerController?.pause();
                            } else {
                              _playerController?.play();
                            }
                          },
                          onPrevious: widget.onPrevious,
                          onNext: widget.onNext,
                          onFavoriteToggle: widget.onFavoriteToggle,
                          onFullscreen: () {
                            _isFullscreenNotifier.value = !isFullscreen;
                            if (!isFullscreen) {
                              _playerController?.enterFullScreen();
                            } else {
                              _playerController?.exitFullScreen();
                            }
                            widget.onFullscreen?.call();
                          },
                          onPositionChanged: (position) {
                            _playerController?.videoPlayerController!.seekTo(
                              position,
                            );
                            widget.onPositionChanged?.call(position);
                          },
                          isFavorite: widget.isFavorite,
                          isFullscreen: isFullscreen,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
