import 'package:flutter/material.dart';
import 'package:ztv_player/helpers/sort.dart';
import 'package:ztv_player/helpers/theme.dart';
import 'package:ztv_player/screens/livetv_screen.dart';
import 'package:ztv_player/screens/movies_screen.dart';
import 'package:ztv_player/screens/series_screen.dart';
import 'package:ztv_player/screens/settings_screen.dart';
import 'package:ztv_player/widgets/app_search_field.dart';
import 'package:ztv_player/widgets/app_sort_button.dart';
import 'package:ztv_player/widgets/app_view_mode_buttons.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int? _selectedActionIcon;
  bool _isSearchOpen = false;

  final List<Widget> _pages = const [
    LiveTvScreen(),
    MoviesScreen(),
    SeriesScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = ['Live TV', 'Movies', 'Series', 'Settings'];

  ScreenSection get _currentSection {
    switch (_selectedIndex) {
      case 0:
        return ScreenSection.live;
      case 1:
        return ScreenSection.movies;
      case 2:
        return ScreenSection.series;
      default:
        return ScreenSection.live;
    }
  }

  bool get _showContentActions => _selectedIndex <= 2;

  void _onTabSelected(int index) {
    if (index == _selectedIndex) {
      return;
    }

    if (_selectedIndex <= 2) {
      AppSort.controller(_currentSection).updateSearch('');
    }

    setState(() {
      _selectedIndex = index;
      _selectedActionIcon = null;
      _isSearchOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppSort.controller(_currentSection);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: !_showContentActions ? Text(_titles[_selectedIndex]) : null,
        bottom: _showContentActions && _isSearchOpen
            ? PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: ValueListenableBuilder<String>(
                  valueListenable: controller.searchController.notifier,
                  builder: (context, query, _) {
                    return AppSearchField(
                      value: query,
                      hintText: 'Search ${_titles[_selectedIndex]}',
                      onChanged: controller.updateSearch,
                    );
                  },
                ),
              )
            : null,
        actions: [
          if (_showContentActions)
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
          if (_showContentActions)
            ValueListenableBuilder<int>(
              valueListenable: controller.viewColumnsNotifier,
              builder: (context, columns, _) {
                return ValueListenableBuilder(
                  valueListenable: AppTheme.colorsNotifier,
                  builder: (context, colors, _) {
                    return AppViewModeButtons(
                      columns: columns,
                      iconColor: colors.bottomNavIcon,
                      activeColor: colors.bottomNavSelectedIcon,
                      onListSelected: () {
                        controller.setListView();
                        setState(() => _selectedActionIcon = 0);
                      },
                      onGridSelected: () {
                        controller.cycleGridView();
                        setState(() => _selectedActionIcon = 0);
                      },
                    );
                  },
                );
              },
            ),
          if (_showContentActions)
            ValueListenableBuilder<SortType>(
              valueListenable: controller.sortNotifier,
              builder: (context, sortType, _) {
                return ValueListenableBuilder(
                  valueListenable: AppTheme.colorsNotifier,
                  builder: (context, colors, _) {
                    return AppSortButton(
                      value: sortType,
                      iconColor: _selectedActionIcon == 1
                          ? colors.bottomNavSelectedIcon
                          : colors.bottomNavIcon,
                      onSelected: (value) {
                        controller.setSort(value);
                        setState(() => _selectedActionIcon = 1);
                      },
                    );
                  },
                );
              },
            ),
          if (_showContentActions)
            ValueListenableBuilder(
              valueListenable: AppTheme.colorsNotifier,
              builder: (context, colors, _) {
                return PopupMenuButton<String>(
                  tooltip: 'More',
                  onSelected: (_) {
                    setState(() => _selectedActionIcon = 2);
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: _selectedActionIcon == 2
                        ? colors.bottomNavSelectedIcon
                        : colors.bottomNavIcon,
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'edit',
                      enabled: false,
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.white38,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Edit (Premium)',
                              style: TextStyle(
                                color: Colors.white38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'reorganize',
                      enabled: false,
                      child: Row(
                        children: [
                          Icon(
                            Icons.reorder_rounded,
                            size: 18,
                            color: Colors.white38,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Reorganize (Premium)',
                              style: TextStyle(
                                color: Colors.white38,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Series'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
