import 'package:flutter/material.dart';
import 'package:movora/models/media.dart';
import 'package:movora/widgets/movie_card.dart';
import 'package:movora/theme/app_theme.dart';

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
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title!,
              style: AppTheme.titleLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        SizedBox(
          height: height,
          child: ListView.builder(
            // Performance optimizations
            cacheExtent: 1200,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            addSemanticIndexes: false,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: media.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: MovieCard(
                  media: media[index],
                  width: itemWidth,
                  height: itemHeight,
                  onTap: () {
                    print('MovieCard tapped: ${media[index].displayTitle}');
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: media[index],
                    );
                  },
                ),
              );
            },
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
          ),
        ),
      ],
    );
  }
}
