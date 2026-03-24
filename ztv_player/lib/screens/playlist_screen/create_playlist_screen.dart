import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ztv_player/models/playlist.dart';
import 'package:ztv_player/models/live_category.dart'; // ← dodaj ovo
import 'package:ztv_player/models/live_channel.dart'; // ← dodaj ovo
import 'package:ztv_player/helpers/xtream_parser.dart';
import 'package:ztv_player/screens/layout_screen/main_screen.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({super.key});

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _nameController = TextEditingController();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _status = '';

  Future<void> _createAndSavePlaylist() async {
    final name = _nameController.text.trim();
    final server = _serverController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (server.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server, Username and Password are required!'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing connection...';
    });

    try {
      final parser = XtreamParser(
        server: server,
        username: username,
        password: password,
      );

      // 1. Test konekcije
      final m3uUrl =
          '$server/get.php?username=$username&password=$password&type=m3u_plus';
      final response = await Dio().get(m3uUrl);

      if (response.statusCode != 200 || response.data.toString().length < 500) {
        throw Exception('Invalid playlist from server');
      }

      setState(() => _status = 'Connection OK. Saving playlist...');

      // 2. Kreiraj i spremi Playlist
      final playlist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.isNotEmpty ? name : 'My Playlist',
        server: server,
        username: username,
        password: password,
      );

      final playlistBox = Hive.box<Playlist>('playlists');
      await playlistBox.put(playlist.id, playlist);

      setState(() => _status = 'Loading Live TV categories...');

      // 3. Učitaj i spremi Live Categories
      final liveCategories = await parser.getLiveCategories();
      final liveCatBox = Hive.box<LiveCategory>('live_categories');
      await liveCatBox.clear(); // brišemo stare podatke
      for (var cat in liveCategories) {
        await liveCatBox.put(cat.id, cat);
      }

      setState(() => _status = 'Loading Live TV channels...');

      // 4. Učitaj i spremi Live Channels
      final liveChannels = await parser.getLiveChannels();
      final liveChanBox = Hive.box<LiveChannel>('live_channels');
      await liveChanBox.clear();
      for (var channel in liveChannels) {
        await liveChanBox.put(channel.id, channel);
      }

      // 5. Izračunaj i ažuriraj channelCount za svaku kategoriju
      setState(() => _status = 'Calculating channel counts...');

      final Map<String, int> countMap = {};
      for (var channel in liveChannels) {
        countMap[channel.categoryId] = (countMap[channel.categoryId] ?? 0) + 1;
      }

      // Ažuriraj svaku kategoriju sa pravim brojem
      for (var cat in liveCategories) {
        final count = countMap[cat.id] ?? 0;
        cat.channelCount = count;
        await cat.save(); // važno! jer je HiveObject
      }

      setState(() => _status = 'Playlist successfully loaded!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Playlist "${playlist.name}" loaded with ${liveChannels.length} channels!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Idemo direktno na MainScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset("assets/images/zTv_logo.png", fit: BoxFit.contain),
              const SizedBox(height: 30),
              const Text(
                'Enter Xtream Codes Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _nameController,
                hint: 'Playlist Name (optional)',
                icon: Icons.playlist_play,
                labelText: "Playlist Name:",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _serverController,
                hint: 'http://example.com:8080',
                icon: Icons.computer,
                labelText: "Server:",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                hint: 'Your Username',
                icon: Icons.person,
                labelText: "Username:",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                hint: 'Your Password',
                icon: Icons.lock,
                obscureText: true,
                labelText: "Password:",
              ),
              const SizedBox(height: 40),
              if (_status.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _status,
                    style: const TextStyle(color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _createAndSavePlaylist,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Let's Go",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        labelText: labelText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
