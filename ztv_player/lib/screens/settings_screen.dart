import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/helpers/theme.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/screens/create_playlist_screen.dart';
import 'package:ztv_player/services/playlist_service.dart';
import 'package:ztv_player/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Box settingsBox = Hive.box('settings');
  final SettingsService _settingsService = const SettingsService();
  final PlaylistService _playlistService = PlaylistService();
  String? selectedPlaylistId;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPlaylist();
  }

  void _loadCurrentPlaylist() {
    selectedPlaylistId = _settingsService.getCurrentPlaylist()?.id;
  }

  void _switchTheme(AppThemeType type) {
    AppTheme.notifier.value = type;
    settingsBox.put('theme', type.index);
  }

  Future<void> _setCurrentPlaylist(Playlist? playlist) async {
    await _settingsService.setCurrentPlaylist(playlist);
    if (!mounted) {
      return;
    }
    setState(() => selectedPlaylistId = playlist?.id);
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm delete'),
        content: Text('Delete "${playlist.name}" and all its content?'),
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

    if (!mounted || confirmed != true) {
      return;
    }

    await _settingsService.deletePlaylist(playlist);
    if (!mounted) {
      return;
    }

    setState(() {
      selectedPlaylistId = _settingsService.getCurrentPlaylist()?.id;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Playlist deleted')));
  }

  Future<void> _reloadPlaylist(Playlist playlist) async {
    await _runPlaylistAction(
      title: 'Reloading playlist',
      action: (onProgress, onStatusChanged) {
        return _playlistService.reloadPlaylist(
          playlist,
          onProgress: onProgress,
          onStatusChanged: onStatusChanged,
        );
      },
      successMessage: 'Playlist reloaded successfully.',
    );
  }

  Future<void> _editPlaylist(Playlist playlist) async {
    final request = await _showEditDialog(playlist);
    if (!mounted || request == null) {
      return;
    }

    await _runPlaylistAction(
      title: 'Updating playlist',
      action: (onProgress, onStatusChanged) {
        return _playlistService.editPlaylist(
          playlist,
          request: request,
          onProgress: onProgress,
          onStatusChanged: onStatusChanged,
        );
      },
      successMessage: 'Playlist updated successfully.',
    );
  }

  Future<void> _runPlaylistAction({
    required String title,
    required Future<PlaylistLoadResult> Function(
      void Function(PlaylistLoadProgress progress) onProgress,
      void Function(String status) onStatusChanged,
    )
    action,
    required String successMessage,
  }) async {
    if (_isBusy) {
      return;
    }

    final progressNotifier = ValueNotifier(
      const PlaylistLoadProgress(status: 'Preparing...', value: 0),
    );

    setState(() => _isBusy = true);
    _showProgressDialog(title, progressNotifier);

    try {
      final result = await action(
        (progress) => progressNotifier.value = progress,
        (status) {
          progressNotifier.value = PlaylistLoadProgress(
            status: status,
            value: progressNotifier.value.value,
          );
        },
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pop();
      setState(() => selectedPlaylistId = result.playlist.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      progressNotifier.dispose();
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showProgressDialog(
    String title,
    ValueNotifier<PlaylistLoadProgress> progressNotifier,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: ValueListenableBuilder<PlaylistLoadProgress>(
            valueListenable: progressNotifier,
            builder: (context, progress, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress.value.clamp(0, 1),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(progress.status),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<PlaylistLoadRequest?> _showEditDialog(Playlist playlist) async {
    final nameController = TextEditingController(text: playlist.name);
    final serverController = TextEditingController(text: playlist.server);
    final usernameController = TextEditingController(text: playlist.username);
    final passwordController = TextEditingController(text: playlist.password);
    final canSaveNotifier = ValueNotifier(false);

    void refreshCanSave() {
      canSaveNotifier.value = _hasPlaylistChanges(
        playlist: playlist,
        name: nameController.text,
        server: serverController.text,
        username: usernameController.text,
        password: passwordController.text,
      );
    }

    nameController.addListener(refreshCanSave);
    serverController.addListener(refreshCanSave);
    usernameController.addListener(refreshCanSave);
    passwordController.addListener(refreshCanSave);
    refreshCanSave();

    final result = await showDialog<PlaylistLoadRequest>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit playlist'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: serverController,
                  decoration: const InputDecoration(labelText: 'Server'),
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: canSaveNotifier,
              builder: (context, canSave, _) {
                return TextButton(
                  onPressed: !canSave
                      ? null
                      : () {
                          Navigator.of(ctx).pop(
                            PlaylistLoadRequest(
                              name: nameController.text.trim(),
                              server: serverController.text.trim(),
                              username: usernameController.text.trim(),
                              password: passwordController.text.trim(),
                            ),
                          );
                        },
                  child: const Text('Save'),
                );
              },
            ),
          ],
        );
      },
    );

    canSaveNotifier.dispose();
    nameController.dispose();
    serverController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    return result;
  }

  bool _hasPlaylistChanges({
    required Playlist playlist,
    required String name,
    required String server,
    required String username,
    required String password,
  }) {
    return name.trim() != playlist.name.trim() ||
        server.trim() != playlist.server.trim() ||
        username.trim() != playlist.username.trim() ||
        password.trim() != playlist.password.trim();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Playlist>>(
      valueListenable: Hive.box<Playlist>('playlists').listenable(),
      builder: (context, box, _) {
        final playlists = _settingsService.getPlaylists();
        if (!playlists.any((playlist) => playlist.id == selectedPlaylistId)) {
          selectedPlaylistId = _settingsService.getCurrentPlaylist()?.id;
        }

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
                    ...playlists.map((playlist) {
                      return DropdownMenuItem(
                        value: playlist.id,
                        child: Text(
                          playlist.name.isNotEmpty ? playlist.name : 'Unnamed',
                        ),
                      );
                    }),
                  ],
                  onChanged: _isBusy
                      ? null
                      : (playlistId) {
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
              const SizedBox(height: 16),
              if (selectedPlaylist != null) ...[
                _PlaylistAccountCard(playlist: selectedPlaylist),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isBusy
                            ? null
                            : () => _editPlaylist(selectedPlaylist!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isBusy
                            ? null
                            : () => _reloadPlaylist(selectedPlaylist!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reload'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isBusy
                            ? null
                            : () => _deletePlaylist(selectedPlaylist!),
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
                onPressed: _isBusy || playlists.length >= 5
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
      },
    );
  }
}

class _PlaylistAccountCard extends StatelessWidget {
  const _PlaylistAccountCard({required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            playlist.name.isEmpty ? 'Unnamed playlist' : playlist.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Username', value: playlist.username),
          _InfoRow(label: 'Password', value: playlist.password),
          _InfoRow(label: 'Server', value: playlist.server),
          _InfoRow(
            label: 'Exp Date',
            value: _formatDateTime(playlist.expiresAt) ?? 'Unavailable',
          ),
        ],
      ),
    );
  }

  static String? _formatDateTime(DateTime? value) {
    if (value == null) {
      return null;
    }

    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
