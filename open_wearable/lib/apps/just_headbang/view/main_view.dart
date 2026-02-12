import 'package:flutter/material.dart';
import 'package:open_wearable/apps/just_headbang/view/game_view.dart';
import 'package:open_wearable/apps/just_headbang/view/settings_view.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/game_viewmodel.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/music_viewmodel.dart';
import 'package:open_wearable/apps/just_headbang/viewmodel/player_viewmodel.dart';

class MainView extends StatefulWidget {
  const MainView(
      {super.key,
      required this.viewModel,
      required this.musicViewModel,
      required this.playersViewModel});

  final GameViewModel viewModel;
  final MusicViewModel musicViewModel;
  final PlayersViewModel playersViewModel;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  void initState() {
    super.initState();
    widget.playersViewModel.addListener(_onPlayersChanged);
  }

  @override
  void dispose() {
    widget.playersViewModel.removeListener(_onPlayersChanged);
    super.dispose();
  }

  void _onPlayersChanged() {
    setState(() {});
  }

  // Convert player data to a list of maps for easier display in the leaderboard
  List<Map<String, dynamic>> get _profiles => widget.playersViewModel.players
      .map(
        (player) => {
          'name': player.name,
          'points': player.points,
          'sessions': player.sessions,
        },
      )
      .toList();

  void _startNewGame() async {
    final playerName = await _showPlayerNameDialog(context);
    if (playerName != null) {
      // Initialize a new session with the selected player
      final player = widget.playersViewModel.currentPlayer;
      if (player != null) {
        widget.viewModel.initSession(player);
      }
      // Wait for GameView to pop, then refresh leaderboard
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameView(
            viewModel: widget.viewModel,
            musicViewModel: widget.musicViewModel,
            playersViewModel: widget.playersViewModel,
          ),
        ),
      );
      if (mounted) setState(() {});
    }
  }

  Future<String?> _showPlayerNameDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    final existingPlayers = widget.playersViewModel.players;
    String? errorMessage;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select or Create Player'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (existingPlayers.isNotEmpty) ...[
                      const Text(
                        'Existing Players:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: existingPlayers.length,
                            itemBuilder: (context, index) {
                              final player = existingPlayers[index];
                              return ListTile(
                                title: Text(player.name),
                                subtitle: Text(
                                    '${player.points} pts • ${player.sessions} sessions'),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
                                  widget.playersViewModel
                                      .setCurrentPlayer(player);
                                  Navigator.pop(context, player.name);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                    ],
                    const Text(
                      'Create New Player:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter new player name',
                        border: const OutlineInputBorder(),
                        errorText: errorMessage,
                      ),
                      autofocus: existingPlayers.isEmpty,
                      onChanged: (_) {
                        if (errorMessage != null) {
                          setState(() {
                            errorMessage = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      setState(() {
                        errorMessage = 'Please enter a player name';
                      });
                      return;
                    }

                    // Check if player name already exists
                    final nameExists = existingPlayers.any(
                      (player) =>
                          player.name.toLowerCase() == name.toLowerCase(),
                    );

                    if (nameExists) {
                      setState(() {
                        errorMessage = 'Player name already exists';
                      });
                      return;
                    }

                    widget.playersViewModel.addPlayer(name);
                    widget.playersViewModel.setCurrentPlayer(
                      widget.playersViewModel.players.last,
                    );
                    Navigator.pop(context, name);
                  },
                  child: const Text('Create & Start'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Just Headbang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Start Game Button
            ElevatedButton(
              onPressed: _startNewGame,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 32),
                  SizedBox(width: 8),
                  Text(
                    'Start New Game',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Cards Section
            const Text(
              'Leaderboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  final profile = _profiles[index];
                  return _ProfileCard(
                    rank: index + 1,
                    name: profile['name'],
                    points: profile['points'],
                    sessions: profile['sessions'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final int sessions;

  const _ProfileCard({
    required this.rank,
    required this.name,
    required this.points,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Player Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sessions sessions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$points',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text(
                  'points',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.blue;
    }
  }
}
