import 'package:cached_network_image/cached_network_image.dart';
import 'package:chimbo/core/config/env.dart';
import 'package:flutter/material.dart';

/// Warms a resized cached-image variant before its widget is built.
Future<void> precacheAppNetworkImage(
  BuildContext context,
  String url, {
  int? cacheWidth,
  int? cacheHeight,
  int? diskCacheWidth,
  int? diskCacheHeight,
}) {
  final provider = CachedNetworkImageProvider(
    url,
    headers: Env.tunnelHeaders,
    maxWidth: diskCacheWidth,
    maxHeight: diskCacheHeight,
  );
  return precacheImage(
    ResizeImage.resizeIfNeeded(cacheWidth, cacheHeight, provider),
    context,
    onError: (_, _) {},
  );
}
