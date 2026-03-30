import 'package:flutter/material.dart';

class PlayerActionBar extends StatelessWidget {
  const PlayerActionBar({
    super.key,
    required this.isPlaying,
    this.onPlayPause,
    this.onPrevious,
    this.onNext,
    this.onFavoriteToggle,
    this.onFullscreen,
    this.isFavorite = false,
  });

  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onFullscreen;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF16161E),
        border: Border(
          top: BorderSide(color: Colors.white10),
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBarButton(
            icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onPressed: onPlayPause,
            tooltip: isPlaying ? 'Pause' : 'Play',
            highlighted: onPlayPause != null,
          ),
          _ActionBarButton(
            icon: Icons.skip_previous_rounded,
            onPressed: onPrevious,
            tooltip: 'Previous',
          ),
          _ActionBarButton(
            icon: Icons.skip_next_rounded,
            onPressed: onNext,
            tooltip: 'Next',
          ),
          _ActionBarButton(
            icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            onPressed: onFavoriteToggle,
            tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
            highlighted: isFavorite,
          ),
          _ActionBarButton(
            icon: Icons.fullscreen_rounded,
            onPressed: onFullscreen,
            tooltip: 'Fullscreen',
            highlighted: onFullscreen != null,
          ),
        ],
      ),
    );
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
            color: enabled ? Colors.white10 : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}
