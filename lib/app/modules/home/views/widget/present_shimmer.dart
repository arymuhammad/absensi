import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget presentShimmer() {
  return Expanded(
    flex: 1,
    child: Container(
      decoration: const BoxDecoration(
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(5),
        //   bottomLeft: Radius.circular(5),
        // ),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 28,
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 55,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 30,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    ),
  );
}
