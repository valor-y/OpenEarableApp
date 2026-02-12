/// Player with name, total points and list of sessions
class Player {
  final String name;
  int _points;
  int _sessions;

  Player({
    required this.name,
    int points = 0,
    int sessions = 0,
  })  : _points = points,
        _sessions = sessions;

  void addSession(int pointsEarned) {
    _points += pointsEarned;
    _sessions++;
}

  int get points => _points;
  int get sessions => _sessions;

}

Player defaultPlayer = Player(name: 'Player1');
