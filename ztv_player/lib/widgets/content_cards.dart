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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
          placeholder: (context, url) => _LoadingVisual(
            width: width,
            height: height,
            radius: radius,
          ),
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
      child: Icon(
        fallbackIcon,
        color: accentColor,
        size: width * 0.58,
      ),
    );
  }
}
