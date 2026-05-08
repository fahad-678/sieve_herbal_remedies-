import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/herb.dart';
import '../theme/app_colors.dart';

/// Displays herb images with optimized caching, sizing, and loading states.
///
/// This widget centralizes herb image rendering to ensure consistent aspect
/// ratios, decode sizing, loading placeholders, and error handling across
/// the app. Both network and asset images are supported.
///
/// - For network images: uses [CachedNetworkImage] with configurable caching
/// - For asset images: uses [Image.asset] with decode size hints
/// - Provides loading and error placeholders with fallback icon
class OptimizedHerbImage extends StatelessWidget {
  /// The herb whose image should be displayed.
  final Herb herb;

  /// The width of the image display area in logical pixels.
  final double width;

  /// The height of the image display area in logical pixels.
  final double height;

  /// How the image should fit within the bounding box.
  /// Defaults to [BoxFit.cover].
  final BoxFit fit;

  /// Optional border radius for clipped corners.
  final BorderRadius? borderRadius;

  /// Optional callback when the image finishes loading.
  final VoidCallback? onImageLoaded;

  /// Duration of the fade-in animation. Defaults to 300ms.
  final Duration fadeInDuration;

  /// Whether to show a loading placeholder while the image decodes.
  /// Defaults to true.
  final bool showPlaceholder;

  /// Multiplier for decode sizing. Use 2.0 for high-DPI displays.
  /// Defaults to 1.0.
  final double pixelRatio;

  /// Opacity value for the image. Defaults to 1.0 (fully opaque).
  final double opacity;

  const OptimizedHerbImage({
    super.key,
    required this.herb,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.onImageLoaded,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.showPlaceholder = true,
    this.pixelRatio = 1.0,
    this.opacity = 1.0,
  });

  /// Compute the decode cache dimensions to avoid oversampling.
  /// Multiply display size by pixel ratio to account for device DPI.
  /// Returns a reasonable default for infinite dimensions.
  int _getDecodeDimension(double displaySize) {
    if (displaySize.isInfinite || displaySize.isNaN) {
      return 2048; // Default for full-width/unknown dimensions
    }
    return (displaySize * pixelRatio).ceil();
  }

  /// Widget to show while the image is loading.
  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget to show when the image fails to load or is not found.
  Widget _buildErrorFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.3),
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.local_florist,
          color: AppColors.muted,
          size: 40,
        ),
      ),
    );
  }

  /// Wrap the image with borderRadius clipping if specified.
  Widget _applyClipping(Widget imageWidget) {
    if (borderRadius == null) {
      return imageWidget;
    }
    return ClipRRect(
      borderRadius: borderRadius!,
      child: imageWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cacheWidth = _getDecodeDimension(width);
    final cacheHeight = _getDecodeDimension(height);

    Widget imageWidget;

    if (herb.hasNetworkImage) {
      // Use CachedNetworkImage with fade-in for network sources.
      imageWidget = CachedNetworkImage(
        imageUrl: herb.imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => showPlaceholder
            ? _buildLoadingPlaceholder()
            : const SizedBox.expand(),
        errorWidget: (context, url, error) => _buildErrorFallback(),
        fadeInDuration: fadeInDuration,
        fadeOutDuration: const Duration(milliseconds: 100),
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        // The maxHeightDiskCache and maxWidthDiskCache are set globally
        // via ImageCacheManager configuration in main.dart
      );
    } else {
      // Use Image.asset with decode hints for local assets.
      imageWidget = Image.asset(
        herb.assetImagePath,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: (context, error, stackTrace) => _buildErrorFallback(),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame != null ? 1.0 : 0.0,
            duration: fadeInDuration,
            child: child,
          );
        },
      );
    }

    // Apply opacity if not fully opaque
    if (opacity < 1.0) {
      imageWidget = Opacity(
        opacity: opacity,
        child: imageWidget,
      );
    }

    return _applyClipping(imageWidget);
  }
}
