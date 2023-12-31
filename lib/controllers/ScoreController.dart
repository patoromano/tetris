import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ScoreManager {
  late String _filePath;

  ScoreManager() {
    _initFilePath();
  }

  Future<void> _initFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/scores.json';
  }

  Future<List<Score>> readScores() async {
    String filePath = await getFilePath();
    try {
      final file = File(filePath);
      if (!(await file.exists())) {
        return [];
      }

      final contents = await file.readAsString();
      final parsed = jsonDecode(contents) as List<dynamic>;

      List<Score> scores =
          parsed.map((scoreJson) => Score.fromJson(scoreJson)).toList();
      scores.sort((a, b) => b.score.compareTo(a.score));
      return scores;
    } catch (e) {
      print('error al leer el codigo: $e');
      return [];
    }
  }

  Future<String> getFilePath() async {
    await _initFilePath();
    return _filePath;
  }

  Future<void> writeScores(List<Score> scores) async {
    try {
      final file = File(_filePath);
      final jsonString =
          jsonEncode(scores.map((score) => score.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('error al escribir el codigo: $e');
    }
  }

  Future<void> deleteScore(int id, String playerName, int scoreValue) async {
    try {
      List<Score> scores = await readScores();
      scores.removeWhere((score) =>
          score.playerName == playerName && score.score == scoreValue && score.id == id);
      await writeScores(scores);
    } catch (e) {
      print('Error al eliminar el puntaje: $e');
    }
  }
}

class Score {
  final String playerName;
  final int score;
  final int id;

  Score({required this.id, required this.playerName, required this.score});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerName': playerName,
      'score': score,
    };
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id:json['id'],
      playerName: json['playerName'],
      score: json['score'],
    );
  }
}
