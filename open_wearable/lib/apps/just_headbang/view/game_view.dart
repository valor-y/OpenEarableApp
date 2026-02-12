import 'package:flutter/material.dart';
import 'package:open_wearable/apps/just_headbang/model/music_track.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/game_viewmodel.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/music_viewmodel.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/player_viewmodel.dart';
import 'package:open_wearable/apps/just_headbang/widgets/sensor_beat_chart.dart';

class GameView extends StatefulWidget {
  const GameView(
      {super.key,
      required GameViewModel viewModel,
      required MusicViewModel musicViewModel,
      required PlayersViewModel playersViewModel})
      : _viewModel = viewModel,
        _musicViewModel = musicViewModel,
        _playersViewModel = playersViewModel;

  @override
  State<GameView> createState() => _GameViewState();

  final GameViewModel _viewModel;
  final MusicViewModel _musicViewModel;
  final PlayersViewModel _playersViewModel;
}

class _GameViewState extends State<GameView> {
  int _score = 0;
  int _combo = 0;
  bool _loadingTracks = false;

  @override
  void initState() {
    super.initState();
    _syncFromViewModel();
    widget._viewModel.addListener(_onViewModelChanged);
    widget._musicViewModel.addListener(_onViewModelChanged);
    widget._playersViewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget._viewModel.removeListener(_onViewModelChanged);
    widget._musicViewModel.removeListener(_onViewModelChanged);
    widget._playersViewModel.removeListener(_onViewModelChanged);
    widget._musicViewModel.stop();
    // Defer endGame so notifyListeners runs after the widget tree is unlocked
    final viewModel = widget._viewModel;
    final playersViewModel = widget._playersViewModel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.endGame(playersViewModel);
    });
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(_syncFromViewModel);
  }

  void _syncFromViewModel() {
    _score = widget._viewModel.score;
    _combo = widget._viewModel.combo;
  }

  Future<void> _showTrackSelectionDialog() async {
    if (_loadingTracks) return;

    setState(() => _loadingTracks = true);

    try {
      final tracks = await widget._musicViewModel.getAvailableTracks();
      if (mounted) {
        _showTrackDialog(tracks);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tracks: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingTracks = false);
      }
    }
  }

  void _showTrackDialog(List<MusicTrack> tracks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select Track'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: tracks.isEmpty
              ? const Center(child: Text('No tracks available'))
              : Scrollbar(
                  child: ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return ListTile(
                        title: Text(track.title),
                        subtitle: Text(track.artist),
                        onTap: () async {
                          widget._viewModel.setSelectedTrack(track);
                          await widget._musicViewModel.setTrack(track);
                          if (context.mounted) Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
        ),
      ),
    );
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
      body: Column(
        children: [
          // Welcome Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Welcome ${widget._playersViewModel.currentPlayer?.name ?? 'Player'}!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          // Main Game Content
          Expanded(
            child: Stack(
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
                      // Real-time sensor + beat overlay chart
                      SensorBeatChart(
                        sensorViewModel: widget._viewModel.sensorViewModel,
                        beatDetectionService: widget._viewModel.beatService,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap:
                            _loadingTracks ? null : _showTrackSelectionDialog,
                        child: Container(
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Display current track or placeholder text
                                        Text(
                                          widget._viewModel.currentSession
                                                  ?.track.title ??
                                              'No Track',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget._viewModel.currentSession
                                                  ?.track.artist ??
                                              '',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_loadingTracks)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          // Play Button
                          child: ElevatedButton(
                            onPressed: () async {
                              if (widget._musicViewModel.currentTrack != null) {
                                await widget._musicViewModel.togglePlayPause();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please select a track first'),
                                  ),
                                );
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget._musicViewModel.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget._musicViewModel.isPlaying
                                      ? 'Pause'
                                      : 'Play',
                                  style: const TextStyle(
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
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
