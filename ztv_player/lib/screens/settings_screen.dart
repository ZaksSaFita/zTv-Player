import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/theme.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/screens/create_playlist_screen.dart';
import 'package:ztv_player/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Box settingsBox = Hive.box('settings');
  final SettingsService _settingsService = SettingsService();
  String? selectedPlaylistId;

  @override
  void initState() {
    super.initState();
    _loadCurrentPlaylist();
  }

  void _loadCurrentPlaylist() {
    setState(() {
      selectedPlaylistId = _settingsService.getCurrentPlaylist()?.id;
    });
  }

  void _switchTheme(AppThemeType type) {
    AppTheme.notifier.value = type;
    settingsBox.put('theme', type.index);
  }

  Future<void> _setCurrentPlaylist(Playlist? playlist) async {
    await _settingsService.setCurrentPlaylist(playlist);
    setState(() => selectedPlaylistId = playlist?.id);
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm delete'),
        content: Text('Delete "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      await _settingsService.deletePlaylist(playlist);
      if (mounted) {
        setState(() {
          selectedPlaylistId = _settingsService.getCurrentPlaylist()?.id;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Playlist deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlists = _settingsService.getPlaylists();
    Playlist? selectedPlaylist;
    for (final playlist in playlists) {
      if (playlist.id == selectedPlaylistId) {
        selectedPlaylist = playlist;
        break;
      }
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Playlists',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String?>(
              value: selectedPlaylistId,
              isExpanded: true,
              underline: const SizedBox(),
              hint: const Text('Select a playlist'),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...playlists.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name.isNotEmpty ? p.name : 'Unnamed'),
                  );
                }),
              ],
              onChanged: (playlistId) {
                Playlist? playlist;
                for (final item in playlists) {
                  if (item.id == playlistId) {
                    playlist = item;
                    break;
                  }
                }
                _setCurrentPlaylist(playlist);
              },
            ),
          ),
          const SizedBox(height: 12),
          if (selectedPlaylist != null) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Prikaži detalje ili edit opciju
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Playlist Details'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${selectedPlaylist!.name}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Server: ${selectedPlaylist!.server}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Username: ${selectedPlaylist!.username}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.info),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deletePlaylist(selectedPlaylist!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton.icon(
            onPressed: playlists.length >= 5
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreatePlaylistScreen(),
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add),
            label: Text(
              playlists.length >= 5
                  ? 'Maximum playlists reached'
                  : 'Add new playlist',
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Theme',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<AppThemeType>(
            valueListenable: AppTheme.notifier,
            builder: (context, selected, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<AppThemeType>(
                  value: selected,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: AppThemeType.values.map((theme) {
                    return DropdownMenuItem(
                      value: theme,
                      child: Text(AppTheme.getThemeName(theme)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _switchTheme(value);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
