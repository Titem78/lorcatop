import 'dart:math';
import 'package:flutter/material.dart';

class StrategyBO2Page extends StatefulWidget {
  const StrategyBO2Page({super.key});

  @override
  State<StrategyBO2Page> createState() => _StrategyBO2PageState();
}

class _StrategyBO2PageState extends State<StrategyBO2Page> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController playersController = TextEditingController();
  final TextEditingController roundsController = TextEditingController();
  final TextEditingController topCutController = TextEditingController();
  final TextEditingController currentRoundController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();

  String result = '';
  bool hasCustomRounds = false;
  bool hasCustomTopCut = false;

  void updateDefaultsFromPlayers(String val) {
    final players = int.tryParse(val);
    if (players == null) return;

    int defaultRounds;
    int defaultTopCut;

    if (players <= 8) {
      defaultRounds = 3;
      defaultTopCut = 0;
    } else if (players <= 16) {
      defaultRounds = 5;
      defaultTopCut = 4;
    } else if (players <= 32) {
      defaultRounds = 5;
      defaultTopCut = 8;
    } else if (players <= 64) {
      defaultRounds = 6;
      defaultTopCut = 8;
    } else if (players <= 128) {
      defaultRounds = 7;
      defaultTopCut = 8;
    } else if (players <= 226) {
      defaultRounds = 8;
      defaultTopCut = 8;
    } else if (players <= 512) {
      defaultRounds = 9;
      defaultTopCut = 16;
    } else if (players <= 1024) {
      defaultRounds = 10;
      defaultTopCut = 32;
    } else {
      defaultRounds = 10;
      defaultTopCut = 64;
    }

    if (!hasCustomRounds) roundsController.text = defaultRounds.toString();
    if (!hasCustomTopCut) topCutController.text = defaultTopCut.toString();
  }

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

          if (outcome < 0.4) {
            scores[p1] += 3;
          } else if (outcome < 0.6) {
            scores[p1] += 1;
            scores[p2] += 1;
          } else {
            scores[p2] += 3;
          }
        }
      }

      scores.sort((a, b) => b.compareTo(a));
      cutoffs.add(scores[topCut - 1]);
    }

    double avgCutoff = cutoffs.reduce((a, b) => a + b) / simulations;
    int remainingRounds = rounds - currentRound;
    int maxReachable = currentScore + (remainingRounds * 3);

    int minWinsNeeded = ((avgCutoff - currentScore) / 3).ceil();
    String advice;

    if (currentRound > rounds) {
      advice = '⚠️ Tu as indiqué une ronde supérieure au nombre total.';
    } else if (currentScore >= avgCutoff) {
      advice = '✅ Tu es probablement déjà qualifié.';
    } else if (maxReachable < avgCutoff) {
      advice =
          '❌ Même avec des victoires, ce sera difficile. Prépare-toi à sortir.';
    } else {
      advice =
          '🎯 Il te faut encore au moins $minWinsNeeded victoire${minWinsNeeded > 1 ? "s" : ""} pour espérer atteindre le top.';
    }

    setState(() {
      result =
          'Ronde à jouer : $currentRound / $rounds\n'
          'Score moyen pour le cut : ${avgCutoff.toStringAsFixed(1)}\n'
          'Score max possible pour ton tournoi : $maxReachable\n\n$advice';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stratégie en BO2')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: playersController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de joueurs',
                ),
                keyboardType: TextInputType.number,
                onChanged: updateDefaultsFromPlayers,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ce champ est requis';
                  return null;
                },
              ),
              TextFormField(
                controller: roundsController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de rondes',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => hasCustomRounds = true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ce champ est requis';
                  return null;
                },
              ),
              TextFormField(
                controller: topCutController,
                decoration: const InputDecoration(labelText: 'Top cut'),
                keyboardType: TextInputType.number,
                onChanged: (_) => hasCustomTopCut = true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ce champ est requis';
                  return null;
                },
              ),
              TextFormField(
                controller: currentRoundController,
                decoration: const InputDecoration(
                  labelText: 'Prochaine ronde à jouer',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ce champ est requis';
                  return null;
                },
              ),
              TextFormField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: 'Score actuel'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ce champ est requis';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez remplir tous les champs'),
                            ),
                          );
                          return;
                        }

                        setState(() => isLoading = true);
                        await Future.delayed(const Duration(milliseconds: 100));

                        evaluateStrategy(
                          players: int.parse(playersController.text),
                          rounds: int.parse(roundsController.text),
                          topCut: int.parse(topCutController.text),
                          currentRound: int.parse(currentRoundController.text),
                          currentScore: int.parse(scoreController.text),
                        );

                        setState(() => isLoading = false);
                      },
                child: Text(
                  isLoading ? "Calcul en cours..." : "Lancer la stratégie",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
