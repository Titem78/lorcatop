import 'dart:math';
import 'package:flutter/material.dart';

class StrategyPage extends StatefulWidget {
  const StrategyPage({super.key});

  @override
  State<StrategyPage> createState() => _StrategyPageState();
}

class _StrategyPageState extends State<StrategyPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController playersController = TextEditingController();
  final TextEditingController roundsController = TextEditingController();
  final TextEditingController topCutController = TextEditingController();
  final TextEditingController currentRoundController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();

  String result = '';

  void evaluateStrategy({
    required int players,
    required int rounds,
    required int topCut,
    required int currentRound,
    required int currentScore,
  }) {
    const int simulations = 1000;
    final rand = Random();
    List<int> cutoffs = [];

    for (int i = 0; i < simulations; i++) {
      List<int> scores = List.filled(players, 0);

      for (int r = 0; r < rounds; r++) {
        for (int j = 0; j < players ~/ 2; j++) {
          double outcome = rand.nextDouble();
          int p1 = j * 2;
          int p2 = j * 2 + 1;

          if (outcome < 0.25) {
            scores[p1] += 7;
          } else if (outcome < 0.5) {
            scores[p2] += 7;
          } else {
            scores[p1] += 3;
            scores[p2] += 3;
          }
        }
      }

      scores.sort((a, b) => b.compareTo(a));
      cutoffs.add(scores[topCut - 1]);
    }

    double avgCutoff = cutoffs.reduce((a, b) => a + b) / simulations;
    int remainingRounds = rounds - currentRound;
    int maxReachable = currentScore + (remainingRounds * 7);

    String advice;
    if (currentScore >= avgCutoff) {
      advice = '✅ Tu es probablement déjà qualifié.';
    } else if (maxReachable < avgCutoff) {
      advice = '❌ Même avec des victoires, ce sera difficile. Prépare-toi à sortir.';
    } else if (currentScore + (remainingRounds * 3) >= avgCutoff) {
      advice = '⚠️ Tu peux draw, mais ce sera tendu. Vérifie les tie-breaks.';
    } else {
      advice = '🎯 Tu dois encore gagner au moins un match pour être tranquille.';
    }

    setState(() {
      result = 'Score moyen pour le cut : ${avgCutoff.toStringAsFixed(1)}\n'
          'Score max possible : $maxReachable\n\n$advice';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stratégie en cours de tournoi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: playersController,
                decoration: const InputDecoration(labelText: 'Nombre de joueurs'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: roundsController,
                decoration: const InputDecoration(labelText: 'Nombre de rondes'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: topCutController,
                decoration: const InputDecoration(labelText: 'Top cut'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: currentRoundController,
                decoration: const InputDecoration(labelText: 'Ronde actuelle'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: 'Score actuel'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  evaluateStrategy(
                    players: int.parse(playersController.text),
                    rounds: int.parse(roundsController.text),
                    topCut: int.parse(topCutController.text),
                    currentRound: int.parse(currentRoundController.text),
                    currentScore: int.parse(scoreController.text),
                  );
                },
                child: const Text('Évaluer la stratégie'),
              ),
              const SizedBox(height: 20),
              Text(result, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
