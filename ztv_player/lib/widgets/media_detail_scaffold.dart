import 'package:flutter/material.dart';

class MediaDetailScaffold extends StatelessWidget {
  const MediaDetailScaffold({
    super.key,
    required this.title,
    required this.player,
    required this.content,
  });

  final String title;
  final Widget player;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(child: player),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Column(
        children: [
          player,
          Expanded(child: content),
        ],
      ),
    );
  }
}
