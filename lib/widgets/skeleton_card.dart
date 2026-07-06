import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(color: Colors.grey.shade200, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10, width: 60, color: Colors.grey.shade200),
                  const SizedBox(height: 6),
                  Container(height: 10, width: double.infinity, color: Colors.grey.shade200),
                  const SizedBox(height: 4),
                  Container(height: 10, width: 100, color: Colors.grey.shade200),
                  const SizedBox(height: 8),
                  Container(
                    height: 30, width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
