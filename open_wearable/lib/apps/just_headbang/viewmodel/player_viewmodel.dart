// players_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:open_wearable/apps/just_headbang/model/player.dart';

class PlayersViewModel extends ChangeNotifier {
  final List<Player> _players = [];
  Player? _currentPlayer;

  List<Player> get players => _players;
  Player? get currentPlayer => _currentPlayer;

  void addPlayer(String name) {
    final player = Player(name: name);
    _players.add(player);
    _currentPlayer = player;
    notifyListeners();
  }

  void removePlayer(Player player) {
    _players.remove(player);
    if (_currentPlayer == player) {
      _currentPlayer = null;
    }
    notifyListeners();
  }

  void setCurrentPlayer(Player player) {
    _currentPlayer = player;
    notifyListeners();
  }

  void updatePlayerSession(int pointsEarned) {
    _currentPlayer?.addSession(pointsEarned);
    notifyListeners();
  }

  Player? getPlayerByName(String name) {
    try {
      return _players.firstWhere((p) => p.name == name);
    } catch (e) {
      return null;
    }
  }
}
