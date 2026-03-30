import 'package:flutter/material.dart';

class MediaDetailScaffold extends StatelessWidget {
  const MediaDetailScaffold({
    super.key,
    required this.title,
    required this.player,
    required this.content,
    this.playerActions,
  });

  final String title;
  final Widget player;
  final Widget content;
  final Widget? playerActions;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      player,
      ...?(playerActions == null ? null : <Widget>[playerActions!]),
      Expanded(child: content),
    ];

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
      body: Column(children: children),
    );
  }
}
