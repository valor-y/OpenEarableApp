import 'package:flutter/material.dart';
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Game'),
      ),
      body: Stack(
        children: [
          // Score View and Combo Counter
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: _ScoreView(score: _score, combo: _combo),
          ),
          // Music + Sensor visualization with track info and play button below
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Music and Sensor Visualization Placeholder'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget._viewModel.currentSession?.track.title ??
                            'No Track',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget._viewModel.currentSession?.track.artist ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (widget._viewModel.getCurrentPlayer() != null) {
                          await widget._viewModel.startGame();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Play',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
          color: Colors.blue.withOpacity(0.7),
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
