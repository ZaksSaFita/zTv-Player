import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ztv_player/models/playlist.dart';
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

      // 1. Test konekcije i skidanje playliste
      final m3uUrl =
          '$server/get.php?username=$username&password=$password&type=m3u_plus';
      final response = await Dio().get(m3uUrl);

      if (response.statusCode != 200 || response.data.toString().length < 500) {
        throw Exception('Invalid playlist from server');
      }

      setState(() => _status = 'Connection OK. Saving playlist...');

      // 2. Kreiraj i spremi Playlist u Hive
      final playlist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.isNotEmpty ? name : 'My Playlist',
        server: server,
        username: username,
        password: password,
      );

      final playlistBox = Hive.box<Playlist>('playlists');
      await playlistBox.put(playlist.id, playlist);

      setState(() => _status = 'Loading Live TV categories and channels...');

      // TODO: Ovdje ćemo kasnije dodati parsiranje i spremanje Live, VOD i Series podataka

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist "${playlist.name}" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Idemo direktno na MainScreen (Live TV)
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
