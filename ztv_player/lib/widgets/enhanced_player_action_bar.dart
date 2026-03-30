import 'package:flutter/material.dart';

class EnhancedPlayerActionBar extends StatefulWidget {
  const EnhancedPlayerActionBar({
    super.key,
    required this.isPlaying,
    required this.isLiveStream,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.onPlayPause,
    this.onPrevious,
    this.onNext,
    this.onFavoriteToggle,
    this.onFullscreen,
    this.onPositionChanged,
    this.isFavorite = false,
    this.isFullscreen = false,
  });

  final bool isPlaying;
  final bool isLiveStream;
  final Duration duration;
  final Duration position;
  final VoidCallback? onPlayPause;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onFullscreen;
  final ValueChanged<Duration>? onPositionChanged;
  final bool isFavorite;
  final bool isFullscreen;

  @override
  State<EnhancedPlayerActionBar> createState() =>
      _EnhancedPlayerActionBarState();
}

class _EnhancedPlayerActionBarState extends State<EnhancedPlayerActionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showControls = true;
  bool _isDraggingProgressBar = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (_showControls) {
      _animationController.forward();
    }
    if (widget.isFullscreen) {
      _autoHideControls();
    }
  }

  @override
  void didUpdateWidget(EnhancedPlayerActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFullscreen != widget.isFullscreen) {
      if (widget.isFullscreen) {
        _autoHideControls();
      }
    }
  }

  void _autoHideControls() {
    if (widget.isFullscreen && _showControls && !_isDraggingProgressBar) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _showControls) {
          _toggleControls();
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _animationController.forward();
      if (widget.isFullscreen) {
        _autoHideControls();
      }
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFullscreen) {
      return GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Transparent tap area
            Container(color: Colors.transparent),
            // Controls bar at bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_animationController),
                child: _buildControlsBar(),
              ),
            ),
          ],
        ),
      );
    }

    return _buildControlsBar();
  }

  Widget _buildControlsBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF16161E),
        border: Border(
          top: BorderSide(color: Colors.white10),
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          if (!widget.isLiveStream) _buildProgressBar(),
          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildActionButtons(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return GestureDetector(
      onHorizontalDragStart: (_) {
        _isDraggingProgressBar = true;
      },
      onHorizontalDragEnd: (_) {
        _isDraggingProgressBar = false;
        if (widget.isFullscreen) {
          _autoHideControls();
        }
      },
      onHorizontalDragUpdate: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final newPosition = Duration(
          milliseconds:
              (details.globalPosition.dx /
                      screenWidth *
                      widget.duration.inMilliseconds)
                  .toInt(),
        );
        widget.onPositionChanged?.call(newPosition);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background
                Container(color: Colors.white12),
                // Buffered
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: Colors.white38,
                    width: widget.duration == Duration.zero
                        ? 0
                        : (widget.position.inMilliseconds /
                                  widget.duration.inMilliseconds) *
                              MediaQuery.of(context).size.width,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    final buttons = <Widget>[];

    // Play/Pause (always visible)
    buttons.add(
      _ActionBarButton(
        icon: widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        onPressed: widget.onPlayPause,
        tooltip: widget.isPlaying ? 'Pause' : 'Play',
        highlighted: widget.onPlayPause != null,
      ),
    );

    // Previous (Series only)
    if (widget.onPrevious != null) {
      buttons.add(
        _ActionBarButton(
          icon: Icons.skip_previous_rounded,
          onPressed: widget.onPrevious,
          tooltip: 'Previous',
        ),
      );
    }

    // Next (Series only)
    if (widget.onNext != null) {
      buttons.add(
        _ActionBarButton(
          icon: Icons.skip_next_rounded,
          onPressed: widget.onNext,
          tooltip: 'Next',
        ),
      );
    }

    // Favorite (always visible except live with no other buttons)
    if (widget.onFavoriteToggle != null) {
      buttons.add(
        _ActionBarButton(
          icon: widget.isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          onPressed: widget.onFavoriteToggle,
          tooltip: widget.isFavorite ? 'Remove favorite' : 'Add favorite',
          highlighted: widget.isFavorite,
        ),
      );
    }

    // Fullscreen (always visible)
    buttons.add(
      _ActionBarButton(
        icon: widget.isFullscreen
            ? Icons.fullscreen_exit_rounded
            : Icons.fullscreen_rounded,
        onPressed: widget.onFullscreen,
        tooltip: widget.isFullscreen ? 'Exit fullscreen' : 'Fullscreen',
        highlighted: widget.onFullscreen != null,
      ),
    );

    return buttons;
  }
}

class _ActionBarButton extends StatelessWidget {
  const _ActionBarButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.highlighted = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = !enabled
        ? Colors.white24
        : highlighted
        ? Colors.orangeAccent
        : Colors.white;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 52,
          height: 44,
          decoration: BoxDecoration(
            color: enabled
                ? Colors.white10
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}
