import 'package:flutter/material.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/music_viewmodel.dart'
    show MusicViewModel;
import 'package:provider/provider.dart';

/// This widget provides music control buttons: play/pause, previous and next.
class MusicControls extends StatelessWidget {
  const MusicControls({super.key});

  @override
  Widget build(BuildContext context) {
    final musicViewModel = context.watch<MusicViewModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: () async {
            await musicViewModel.previous();
          },
        ),
        IconButton(
          icon: Icon(
            musicViewModel.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: () async {
            await musicViewModel.togglePlayPause();
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: () async {
            await musicViewModel.skip();
          },
        ),
      ],
    );
  }
}
