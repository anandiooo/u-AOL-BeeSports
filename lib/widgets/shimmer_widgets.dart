import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:beesports/app/app_colors.dart';

class ShimmerListView extends StatelessWidget {
  final int count;
  final Widget child;

  const ShimmerListView({super.key, required this.count, required this.child});

  factory ShimmerListView.lobbyCards({int count = 4}) {
    return ShimmerListView(
      count: count,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.softCloud,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 150, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 12, color: Colors.white),
                    ],
                  ),
                ),
                Container(width: 60, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              ],
            ),
            const SizedBox(height: 18),
            Container(width: double.infinity, height: 1, color: Colors.white),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(width: 80, height: 14, color: Colors.white),
                const Spacer(),
                Container(width: 40, height: 14, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  factory ShimmerListView.transactions({int count = 5}) {
    return ShimmerListView(
      count: count,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Container(width: 24, height: 24, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120, height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 80, height: 12, color: Colors.white),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(width: 60, height: 16, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 40, height: 12, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  factory ShimmerListView.notifications({int count = 6}) {
    return ShimmerListView(
      count: count,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity, height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 150, height: 12, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.softCloud,
      highlightColor: AppColors.hairline,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        itemBuilder: (_, __) => child,
      ),
    );
  }
}

class ShimmerProfileHeader extends StatelessWidget {
  const ShimmerProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.softCloud,
      highlightColor: AppColors.hairline,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 96, height: 96, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(height: 18),
            Container(width: 150, height: 24, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 200, height: 14, color: Colors.white),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 80, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                const SizedBox(width: 8),
                Container(width: 100, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
