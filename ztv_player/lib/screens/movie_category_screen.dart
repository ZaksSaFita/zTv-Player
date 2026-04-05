import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/media_format.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/helpers/theme.dart';
import 'package:ztv_player/models/vod_category.dart';
import 'package:ztv_player/models/vod_movie.dart';
import 'package:ztv_player/screens/movie_player_screen.dart';
import 'package:ztv_player/services/movie_service.dart';
import 'package:ztv_player/widgets/app_search_field.dart';
import 'package:ztv_player/widgets/app_sort_button.dart';
import 'package:ztv_player/widgets/app_view_mode_buttons.dart';
import 'package:ztv_player/widgets/content_cards.dart';
import 'package:ztv_player/widgets/empty_state.dart';

class MovieCategoryScreen extends StatefulWidget {
  const MovieCategoryScreen({super.key, required this.category});

  final VodCategory category;

  @override
  State<MovieCategoryScreen> createState() => _MovieCategoryScreenState();
}

class _MovieCategoryScreenState extends State<MovieCategoryScreen> {
  bool _isSearchOpen = false;

  @override
  Widget build(BuildContext context) {
    final controller = AppSort.movieCategoryController;
    final movieService = MovieService();

    return PopScope(
      onPopInvokedWithResult: (_, _) {
        controller.updateSearch('');
        setState(() => _isSearchOpen = false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.category.name),
          bottom: _isSearchOpen
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: ValueListenableBuilder<String>(
                    valueListenable: controller.searchController.notifier,
                    builder: (context, query, _) {
                      return AppSearchField(
                        value: query,
                        hintText: 'Search movies',
                        onChanged: controller.updateSearch,
                      );
                    },
                  ),
                )
              : null,
          leading: IconButton(
            onPressed: () {
              controller.updateSearch('');
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: AppTheme.colorsNotifier.value.bottomNavIcon,
          ),
          actions: [
            ValueListenableBuilder(
              valueListenable: AppTheme.colorsNotifier,
              builder: (context, colors, _) {
                return IconButton(
                  onPressed: () {
                    final shouldOpen = !_isSearchOpen;
                    setState(() => _isSearchOpen = shouldOpen);
                    if (!shouldOpen) {
                      controller.updateSearch('');
                    }
                  },
                  icon: Icon(_isSearchOpen ? Icons.close : Icons.search),
                  color: _isSearchOpen
                      ? colors.bottomNavSelectedIcon
                      : colors.bottomNavIcon,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: AppTheme.colorsNotifier,
              builder: (context, colors, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: controller.viewColumnsNotifier,
                  builder: (context, viewColumns, _) {
                    return AppViewModeButtons(
                      columns: viewColumns,
                      iconColor: colors.bottomNavIcon,
                      activeColor: colors.bottomNavSelectedIcon,
                      onPressed: controller.toggleView,
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: AppTheme.colorsNotifier,
              builder: (context, colors, _) {
                return ValueListenableBuilder<SortType>(
                  valueListenable: controller.sortNotifier,
                  builder: (context, sortType, _) {
                    return AppSortButton(
                      value: sortType,
                      iconColor: colors.bottomNavIcon,
                      onSelected: controller.setSort,
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: ValueListenableBuilder<Box<VodMovie>>(
          valueListenable: movieService.moviesListenable(),
          builder: (context, box, _) {
            return ValueListenableBuilder<SortType>(
              valueListenable: controller.sortNotifier,
              builder: (context, sortType, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: controller.searchController.notifier,
                  builder: (context, query, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: controller.viewColumnsNotifier,
                      builder: (context, viewColumns, _) {
                        final movies = movieService.getVisibleMovies(
                          categoryId: widget.category.id,
                          sortType: sortType,
                          query: query,
                        );

                        if (movies.isEmpty) {
                          return const EmptyState(
                            title: 'No movies found in this category.',
                            icon: Icons.movie_creation_outlined,
                          );
                        }

                        if (viewColumns > 1) {
                          return GridView.builder(
                            padding: AppView.contentPadding,
                            gridDelegate: AppView.delegateFor(
                              viewColumns,
                              poster: true,
                              densePoster: true,
                            ),
                            itemCount: movies.length,
                            itemBuilder: (context, index) {
                              final movie = movies[index];
                              return AppPosterGridCard(
                                title: movie.name,
                                subtitle: viewColumns >= 3
                                    ? null
                                    : _movieSubtitle(movie),
                                compact: viewColumns >= 3,
                                imageUrl: movie.logoUrl,
                                fallbackIcon: Icons.movie_creation_outlined,
                                accentColor: Colors.red,
                                onTap: () => _openMovie(context, movie),
                              );
                            },
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];
                            return AppPosterListCard(
                              title: movie.name,
                              subtitle: _movieSubtitle(movie),
                              imageUrl: movie.logoUrl,
                              fallbackIcon: Icons.movie_creation_outlined,
                              accentColor: Colors.red,
                              onTap: () => _openMovie(context, movie),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  String? _movieSubtitle(VodMovie movie) {
    final parts = <String>[];
    if (movie.rating != null && movie.rating!.isNotEmpty) {
      parts.add('Rating ${formatRating(movie.rating)}');
    }
    if (movie.categoryId.isNotEmpty) {
      parts.add('Movie');
    }
    return parts.isEmpty ? null : parts.join(' | ');
  }

  void _openMovie(BuildContext context, VodMovie movie) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MoviePlayerScreen(movie: movie)));
  }
}
