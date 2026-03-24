import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData fallbackIcon;
  final IconData? trailingIcon;
  final Color accentColor;
  final Color? trailingIconColor;
  final VoidCallback? onTap;

  const AppListCard({
    super.key,
    required this.title,
    required this.fallbackIcon,
    required this.accentColor,
    this.subtitle,
    this.imageUrl,
    this.trailingIcon,
    this.trailingIconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        leading: _CardVisual(
          imageUrl: imageUrl,
          fallbackIcon: fallbackIcon,
          accentColor: accentColor,
          width: 48,
          height: 48,
          radius: 10,
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
        trailing: trailingIcon == null
            ? null
            : Icon(
                trailingIcon,
                color: trailingIconColor ?? Colors.grey,
                size: 18,
              ),
        onTap: onTap,
      ),
    );
  }
}

class AppGridCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color accentColor;
  final VoidCallback? onTap;

  const AppGridCard({
    super.key,
    required this.title,
    required this.fallbackIcon,
    required this.accentColor,
    this.subtitle,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CardVisual(
                imageUrl: imageUrl,
                fallbackIcon: fallbackIcon,
                accentColor: accentColor,
                width: 44,
                height: 44,
                radius: 12,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppPosterGridCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? badge;
  final IconData fallbackIcon;
  final Color accentColor;
  final BoxFit imageFit;
  final VoidCallback? onTap;

  const AppPosterGridCard({
    super.key,
    required this.title,
    required this.fallbackIcon,
    required this.accentColor,
    this.imageFit = BoxFit.cover,
    this.subtitle,
    this.imageUrl,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _PosterVisual(
                imageUrl: imageUrl,
                fallbackIcon: fallbackIcon,
                accentColor: accentColor,
                fit: imageFit,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x12000000),
                      Color(0xAA000000),
                      Color(0xEE000000),
                    ],
                    stops: [0.0, 0.42, 0.78, 1.0],
                  ),
                ),
              ),
              if (badge != null && badge!.isNotEmpty)
                Positioned(
                  top: 10,
                  left: 10,
                  child: _PosterBadge(label: badge!, accentColor: accentColor),
                ),
              Positioned(
                right: 10,
                bottom: 12,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFCDCDCD),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppPosterListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? badge;
  final IconData fallbackIcon;
  final Color accentColor;
  final BoxFit imageFit;
  final VoidCallback? onTap;

  const AppPosterListCard({
    super.key,
    required this.title,
    required this.fallbackIcon,
    required this.accentColor,
    this.imageFit = BoxFit.cover,
    this.subtitle,
    this.imageUrl,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 182,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 122,
                height: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(18),
                  ),
                  child: _PosterVisual(
                    imageUrl: imageUrl,
                    fallbackIcon: fallbackIcon,
                    accentColor: accentColor,
                    fit: imageFit,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(18),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF161616), Color(0xFF0E0E0E)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (badge != null && badge!.isNotEmpty) ...[
                        _PosterBadge(label: badge!, accentColor: accentColor),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: accentColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Open details',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardVisual extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color accentColor;
  final double width;
  final double height;
  final double radius;

  const _CardVisual({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.accentColor,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              _LoadingVisual(width: width, height: height, radius: radius),
          errorWidget: (context, url, error) {
            return _FallbackVisual(
              fallbackIcon: fallbackIcon,
              accentColor: accentColor,
              width: width,
              height: height,
              radius: radius,
            );
          },
        ),
      );
    }

    return _FallbackVisual(
      fallbackIcon: fallbackIcon,
      accentColor: accentColor,
      width: width,
      height: height,
      radius: radius,
    );
  }
}

class _PosterVisual extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color accentColor;
  final BoxFit fit;

  const _PosterVisual({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.accentColor,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit,
        placeholder: (context, url) => _LoadingVisual(
          width: double.infinity,
          height: double.infinity,
          radius: 0,
        ),
        errorWidget: (context, url, error) {
          return _PosterFallbackVisual(
            fallbackIcon: fallbackIcon,
            accentColor: accentColor,
          );
        },
      );
    }

    return _PosterFallbackVisual(
      fallbackIcon: fallbackIcon,
      accentColor: accentColor,
    );
  }
}

class _PosterBadge extends StatelessWidget {
  final String label;
  final Color accentColor;

  const _PosterBadge({required this.label, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: accentColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _LoadingVisual extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _LoadingVisual({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _FallbackVisual extends StatelessWidget {
  final IconData fallbackIcon;
  final Color accentColor;
  final double width;
  final double height;
  final double radius;

  const _FallbackVisual({
    required this.fallbackIcon,
    required this.accentColor,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(fallbackIcon, color: accentColor, size: width * 0.58),
    );
  }
}

class _PosterFallbackVisual extends StatelessWidget {
  final IconData fallbackIcon;
  final Color accentColor;

  const _PosterFallbackVisual({
    required this.fallbackIcon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.55),
            const Color(0xFF111111),
          ],
        ),
      ),
      child: Center(child: Icon(fallbackIcon, color: Colors.white, size: 42)),
    );
  }
}
