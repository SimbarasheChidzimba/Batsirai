import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    required this.width,
    required this.height,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}

class RestaurantCardShimmer extends StatelessWidget {
  const RestaurantCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: 200, height: 20),
                const SizedBox(height: Spacing.sm),
                const ShimmerLoading(width: 150, height: 16),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: const [
                    ShimmerLoading(width: 60, height: 14),
                    SizedBox(width: Spacing.md),
                    ShimmerLoading(width: 80, height: 14),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: 220, height: 20),
                const SizedBox(height: Spacing.sm),
                const ShimmerLoading(width: 180, height: 16),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: const [
                    ShimmerLoading(width: 80, height: 24),
                    Spacer(),
                    ShimmerLoading(width: 70, height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loader for event/restaurant detail screens
class DetailScreenShimmer extends StatelessWidget {
  const DetailScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          // Image placeholder
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: const ShimmerLoading(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const ShimmerLoading(width: 250, height: 28),
                  const SizedBox(height: Spacing.md),
                  // Info rows
                  ...List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: Row(
                      children: [
                        const ShimmerLoading(width: 20, height: 20),
                        const SizedBox(width: Spacing.sm),
                        const ShimmerLoading(width: 200, height: 16),
                      ],
                    ),
                  )),
                  const SizedBox(height: Spacing.lg),
                  // Section title
                  const ShimmerLoading(width: 100, height: 20),
                  const SizedBox(height: Spacing.sm),
                  // Description lines
                  ...List.generate(4, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.xs),
                    child: ShimmerLoading(
                      width: index == 3 ? 150 : double.infinity,
                      height: 16,
                    ),
                  )),
                  const SizedBox(height: Spacing.lg),
                  // Another section
                  const ShimmerLoading(width: 120, height: 20),
                  const SizedBox(height: Spacing.sm),
                  ...List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: const ShimmerLoading(width: double.infinity, height: 60),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: const ShimmerLoading(width: double.infinity, height: 48),
        ),
      ),
    );
  }
}

/// Shimmer loader for horizontal list items (home screen)
class HorizontalListItemShimmer extends StatelessWidget {
  const HorizontalListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: const ShimmerLoading(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
