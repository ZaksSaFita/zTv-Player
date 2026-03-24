import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer({
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
    this.overlay,
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
  final Widget? overlay;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  BetterPlayerController? _controller;
  String? _errorMessage;
  final GlobalKey<BetterPlayerPlaylistState> _playlistKey =
      GlobalKey<BetterPlayerPlaylistState>();

  bool get _usesPlaylist =>
      widget.playlistDataSources != null && widget.playlistDataSources!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.autoInitialize && !_usesPlaylist) {
      _initializePlayer();
    }
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUsesPlaylist =
        oldWidget.playlistDataSources != null &&
        oldWidget.playlistDataSources!.isNotEmpty;

    if (oldUsesPlaylist != _usesPlaylist) {
      _disposeController();
      if (_errorMessage != null) {
        setState(() => _errorMessage = null);
      }
      return;
    }

    if (oldWidget.streamUrl != widget.streamUrl ||
        oldWidget.autoInitialize != widget.autoInitialize ||
        oldWidget.isLiveStream != widget.isLiveStream) {
      _disposeController();
      if (widget.autoInitialize && !_usesPlaylist) {
        _initializePlayer();
      } else {
        setState(() => _errorMessage = null);
      }
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final streamUrl = widget.streamUrl?.trim();
    if (streamUrl == null || streamUrl.isEmpty) {
      if (mounted) {
        setState(() => _errorMessage = null);
      }
      return;
    }

    try {
      debugPrint('BetterPlayer opening: $streamUrl');

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        streamUrl,
        liveStream: widget.isLiveStream,
        videoFormat: _detectFormat(streamUrl),
        notificationConfiguration: const BetterPlayerNotificationConfiguration(
          showNotification: false,
        ),
      );

      final controller = BetterPlayerController(_buildPlayerConfiguration());
      await controller.setupDataSource(dataSource);

      if (!mounted) {
        controller.dispose(forceDispose: true);
        return;
      }

      setState(() {
        _errorMessage = null;
        _controller = controller;
      });
    } catch (error, stackTrace) {
      debugPrint('BetterPlayer failed for: $streamUrl');
      debugPrint('BetterPlayer error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Stream could not be loaded.\n$error';
        _controller = null;
      });
    }
  }

  BetterPlayerVideoFormat? _detectFormat(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.m3u8')) {
      return BetterPlayerVideoFormat.hls;
    }
    if (lower.contains('.mpd')) {
      return BetterPlayerVideoFormat.dash;
    }
    return null;
  }

  void _disposeController() {
    final controller = _controller;
    if (controller != null) {
      controller.dispose(forceDispose: true);
    }
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    final playlistDataSources = widget.playlistDataSources;
    final hasPlaylist = _usesPlaylist && widget.autoInitialize;
    final playlistSignature = hasPlaylist
        ? playlistDataSources!
            .map((dataSource) => dataSource.url)
            .join('|')
        : '';

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF17171F)),
        child: hasPlaylist
            ? KeyedSubtree(
                key: ValueKey(
                  'playlist-$playlistSignature-${widget.initialPlaylistIndex}',
                ),
                child: BetterPlayerPlaylist(
                  key: _playlistKey,
                  betterPlayerDataSourceList: playlistDataSources!,
                  betterPlayerConfiguration: _buildPlayerConfiguration(),
                  betterPlayerPlaylistConfiguration:
                      BetterPlayerPlaylistConfiguration(
                        initialStartIndex: widget.initialPlaylistIndex,
                        loopVideos: false,
                      ),
                ),
              )
            : _controller == null
            ? _PlayerFallback(
                placeholderImageUrl: widget.placeholderImageUrl,
                errorMessage: _errorMessage,
                idleTitle: widget.idleTitle,
                idleActionLabel: widget.idleActionLabel,
                onIdleAction: widget.onIdleAction,
                overlay: widget.overlay,
                isIdle:
                    !widget.autoInitialize ||
                    (widget.streamUrl == null ||
                        widget.streamUrl!.trim().isEmpty),
                isLoading:
                    widget.autoInitialize &&
                    widget.streamUrl != null &&
                    widget.streamUrl!.trim().isNotEmpty &&
                    _errorMessage == null,
              )
            : BetterPlayer(controller: _controller!),
      ),
    );
  }

  BetterPlayerConfiguration _buildPlayerConfiguration() {
    return BetterPlayerConfiguration(
      autoPlay: true,
      looping: false,
      allowedScreenSleep: false,
      handleLifecycle: true,
      autoDispose: false,
      autoDetectFullscreenDeviceOrientation: true,
      autoDetectFullscreenAspectRatio: true,
      deviceOrientationsAfterFullScreen: const [
        DeviceOrientation.portraitUp,
      ],
      systemOverlaysAfterFullScreen: SystemUiOverlay.values,
      fit: BoxFit.cover,
      aspectRatio: 16 / 9,
      expandToFill: true,
      useRootNavigator: true,
      placeholder: _PlayerSurface(
        placeholderImageUrl: widget.placeholderImageUrl,
      ),
      showPlaceholderUntilPlay: true,
      placeholderOnTop: true,
      overlay: widget.overlay,
      errorBuilder: (context, errorMessage) => _PlayerSurface(
        placeholderImageUrl: widget.placeholderImageUrl,
        message: errorMessage ?? _errorMessage,
      ),
      eventListener: _handlePlayerEvent,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableQualities: true,
        enableSubtitles: true,
        enableAudioTracks: true,
        enableOverflowMenu: true,
        enableSkips: !widget.isLiveStream,
        enablePlaybackSpeed: !widget.isLiveStream,
        enableRetry: true,
        enablePip: false,
        showControlsOnInitialize: !widget.isLiveStream,
        controlsHideTime: const Duration(seconds: 3),
        controlBarColor: Colors.black54,
        iconsColor: Colors.white,
        progressBarPlayedColor: Colors.orange,
        progressBarHandleColor: Colors.orange,
        progressBarBufferedColor: Colors.white38,
        progressBarBackgroundColor: Colors.white12,
        loadingWidget: const Center(
          child: SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _handlePlayerEvent(BetterPlayerEvent event) {
    if (!mounted) {
      return;
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      final message =
          event.parameters?['exception']?.toString() ??
          'Unknown playback error.';
      setState(() => _errorMessage = message);
      return;
    }

    if (!_usesPlaylist ||
        widget.onPlaylistIndexChanged == null ||
        (event.betterPlayerEventType != BetterPlayerEventType.setupDataSource &&
            event.betterPlayerEventType != BetterPlayerEventType.initialized &&
            event.betterPlayerEventType !=
                BetterPlayerEventType.changedPlaylistItem)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controller =
          _playlistKey.currentState?.betterPlayerPlaylistController;
      final index = controller?.currentDataSourceIndex;
      if (index != null) {
        widget.onPlaylistIndexChanged!(index);
      }
    });
  }
}

class _PlayerSurface extends StatelessWidget {
  const _PlayerSurface({this.placeholderImageUrl, this.message});

  final String? placeholderImageUrl;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return _BackdropSurface(
      imageUrl: placeholderImageUrl,
      showFallbackIcon: true,
      message: message,
    );
  }
}

class _PlayerFallback extends StatelessWidget {
  const _PlayerFallback({
    required this.placeholderImageUrl,
    this.errorMessage,
    required this.isIdle,
    required this.isLoading,
    this.idleTitle,
    this.idleActionLabel,
    this.onIdleAction,
    this.overlay,
  });

  final String? placeholderImageUrl;
  final String? errorMessage;
  final bool isIdle;
  final bool isLoading;
  final String? idleTitle;
  final String? idleActionLabel;
  final VoidCallback? onIdleAction;
  final Widget? overlay;

  bool get _hasImage =>
      placeholderImageUrl != null && placeholderImageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final centerChild = Center(
      child: _IdleOverlay(
        title: isIdle ? idleTitle : null,
        actionLabel: isIdle ? idleActionLabel : null,
        onAction: isIdle ? onIdleAction : null,
        loading: isLoading,
      ),
    );

    if (_hasImage) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isIdle ? onIdleAction : null,
        child: _BackdropSurface(
          imageUrl: placeholderImageUrl,
          showFallbackIcon: true,
          centerChild: centerChild,
          overlay: overlay,
          message: errorMessage,
        ),
      );
    }

    return _BackdropSurface(
      showFallbackIcon: !isIdle,
      centerChild: isIdle || isLoading ? centerChild : null,
      overlay: overlay,
      message: errorMessage,
    );
  }
}

class _BackdropSurface extends StatelessWidget {
  const _BackdropSurface({
    this.imageUrl,
    required this.showFallbackIcon,
    this.centerChild,
    this.overlay,
    this.message,
  });

  final String? imageUrl;
  final bool showFallbackIcon;
  final Widget? centerChild;
  final Widget? overlay;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (imageUrl != null && imageUrl!.isNotEmpty)
        CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              _FallbackSurface(showIcon: showFallbackIcon),
        )
      else
        _FallbackSurface(showIcon: showFallbackIcon),
      const ColoredBox(color: Colors.black38),
    ];

    if (centerChild != null) {
      children.add(centerChild!);
    }
    if (overlay != null) {
      children.add(overlay!);
    }
    if (message != null && message!.isNotEmpty) {
      children.add(_ErrorSurface(message: message!));
    }

    return Stack(fit: StackFit.expand, children: children);
  }
}

class _IdleOverlay extends StatelessWidget {
  const _IdleOverlay({
    this.title,
    this.actionLabel,
    this.onAction,
    this.loading = false,
  });

  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null && actionLabel!.trim().isNotEmpty;
    final hasTitle = title != null && title!.trim().isNotEmpty;

    if (!hasAction && !hasTitle && !loading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            const SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          if (loading && (hasTitle || hasAction)) const SizedBox(height: 14),
          if (hasTitle)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (hasTitle && hasAction) const SizedBox(height: 14),
          if (hasAction) ...[
            const SizedBox(height: 14),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _FallbackSurface extends StatelessWidget {
  const _FallbackSurface({required this.showIcon});

  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF23232D),
      alignment: Alignment.center,
      child: showIcon
          ? const Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white70,
              size: 68,
            )
          : null,
    );
  }
}

class _ErrorSurface extends StatelessWidget {
  const _ErrorSurface({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: Colors.black87,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}
