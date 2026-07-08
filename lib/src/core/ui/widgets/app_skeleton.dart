// lib/core/ui/widgets/app_skeleton.dart

import 'package:flutter/material.dart';
import 'package:reqres_in/src/core/ui/ui.dart';

/// Khối skeleton đơn giản (không animation) dùng thay
/// [CircularProgressIndicator] trần cho các màn hình danh sách/chi tiết,
/// để loading state gợi ý trước hình dạng nội dung sắp hiện ra.
class AppSkeleton extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadiusGeometry borderRadius;

  const AppSkeleton({
    super.key,
    this.height = AppDimens.s16,
    this.width,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppDimens.r4),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.colors.border,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Danh sách các dòng skeleton — dùng thay spinner khi loading một list.
class AppSkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const AppSkeletonList({
    super.key,
    this.itemCount = 4,
    this.itemHeight = AppDimens.s48,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.s16),
      child: Column(
        children: List.generate(
          itemCount,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.s12),
            child: AppSkeleton(height: itemHeight),
          ),
        ),
      ),
    );
  }
}
