import 'package:flutter/material.dart';
import 'package:movora/models/media.dart';
import 'package:movora/widgets/movie_card.dart';

class MovieList extends StatelessWidget {
  final List<Media> media;
  final String? title;
  final double height;
  final double itemWidth;
  final double itemHeight;

  const MovieList({
    super.key,
    required this.media,
    this.title,
    this.height = 200,
    this.itemWidth = 120,
    this.itemHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
        SizedBox(
          height: height,
          child: ListView.builder(
            // Optimized settings for better performance
            cacheExtent: 300, // Increased cache extent
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: media.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                // Add repaint boundary
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: MovieCard(
                    media: media[index],
                    width: itemWidth,
                    height: itemHeight,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: media[index],
                      );
                    },
                  ),
                ),
              );
            },
            physics: const ClampingScrollPhysics(),
          ),
        ),
      ],
    );
  }
}
