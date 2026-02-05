import 'package:flutter/material.dart';
import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/game_viewmodel.dart';

class GameView extends StatefulWidget {
  const GameView({super.key, required GameViewModel viewModel})
      : _viewModel = viewModel;

  @override
  State<GameView> createState() => _GameViewState();

  final GameViewModel _viewModel;
}

class _GameViewState extends State<GameView> {
  int _score = 0;
  int _combo = 0;

  @override
  void initState() {
    super.initState();
    _syncFromViewModel();
    widget._viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget._viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(_syncFromViewModel);
  }

  void _syncFromViewModel() {
    _score = widget._viewModel.score;
    _combo = widget._viewModel.combo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Score View and Combo Counter
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: _ScoreView(score: _score, combo: _combo),
          ),
          // Music + Sensor visualization
          Center(child: Text('Music and Sensor Visualization Placeholder')),
          
          // music controls
          Positioned(
            bottom: 48,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  color: Colors.white,
                  iconSize: 48,
                  onPressed: () { 
                    //set play and change to pause icon
                    //TODO: implement play functionality
                    widget._viewModel.startGame(MusicTrack(id: 'track1', title: 'Sample Track', artist: '', duration: Duration.zero, sourceType: MusicSourceType.local));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreView extends StatelessWidget {
  final int score;
  final int combo;

  const _ScoreView({
    required this.score,
    required this.combo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Score', value: score.toString()),
        const SizedBox(width: 12),
        _StatCard(label: 'Combo', value: 'x$combo'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                )),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }
}
