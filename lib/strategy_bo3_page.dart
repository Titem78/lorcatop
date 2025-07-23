import 'dart:math';
import 'package:flutter/material.dart';

class StrategyBO3Page extends StatefulWidget {
  const StrategyBO3Page({super.key});

  @override
  State<StrategyBO3Page> createState() => _StrategyBO3PageState();
}

class _StrategyBO3PageState extends State<StrategyBO3Page> {
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

  String selectedDrawMode = "auto"; // ✅ par défaut
  double customDrawPercent = 5;

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

    double drawRate = switch (selectedDrawMode) {
      "none" => 0.0,
      "auto" => 0.01,
      "custom" => customDrawPercent / 100.0,
      _ => 0.0,
    };

    for (int i = 0; i < simulations; i++) {
      List<int> scores = List.filled(players, 0);

      for (int r = 0; r < rounds; r++) {
        for (int j = 0; j < players ~/ 2; j++) {
          double outcome = rand.nextDouble();
          int p1 = j * 2;
          int p2 = j * 2 + 1;

          if (outcome < (1 - drawRate) / 2) {
            scores[p1] += 3;
          } else if (outcome < 1 - drawRate) {
            scores[p2] += 3;
          } else {
            scores[p1] += 1;
            scores[p2] += 1;
          }
        }
      }

      scores.sort((a, b) => b.compareTo(a));
      cutoffs.add(scores[topCut - 1]);
    }

    double avgCutoff = cutoffs.reduce((a, b) => a + b) / simulations;
    int remainingRounds = rounds - (currentRound - 1);
    int maxReachable = currentScore + (remainingRounds * 3);

    if (currentScore > maxReachable) {
      setState(() {
        result =
            '⚠️ Le score actuel dépasse le score maximum possible. Vérifie les données saisies.';
      });
      return;
    }

    int minWinsNeeded = ((avgCutoff - currentScore) / 3).ceil();
    bool showCutoffExplanation = (currentScore - avgCutoff).abs() <= 1;

    String advice;
    if (currentRound > rounds) {
      advice = '⚠️ Tu as indiqué une ronde supérieure au nombre total.';
    } else if (currentScore >= avgCutoff) {
      advice = '✅ Tu es probablement déjà qualifié.';
    } else if (maxReachable < avgCutoff) {
      advice =
          '❌ Même avec des victoires, ce sera difficile. Prépare-toi à sortir.';
    } else if ((currentScore + ((remainingRounds - 1) * 3)) >= avgCutoff) {
      advice =
          '🟠 Tu es proche de la qualification. Une victoire supplémentaire renforcerait ta position.';
    } else {
      advice =
          '🎯 Il te faut encore au moins $minWinsNeeded victoire${minWinsNeeded > 1 ? "s" : ""} pour espérer atteindre le top.';
    }

    List<String> idResults = [];
    if (selectedDrawMode != "none") {
      for (int idCount = 0; idCount <= remainingRounds; idCount++) {
        int score = currentScore + idCount;
        if (score >= avgCutoff) {
          idResults.add(
            "✅ $idCount ID → $score pts → 🟢 Potentiellement suffisant",
          );
        } else {
          idResults.add("❌ $idCount ID → $score pts → 🔴 Trop juste");
        }
      }
    }

    setState(() {
      result =
          'Ronde à jouer : $currentRound / $rounds\n'
          'Score moyen pour le cut : ${avgCutoff.toStringAsFixed(1)}\n'
          'Score max possible pour ton tournoi : $maxReachable\n\n'
          '$advice';

      if (showCutoffExplanation) {
        result +=
            '\n\n📌 Le score moyen n\'est pas un entier car il peut y avoir des égalités.\n'
            '⚽ Si tu es proche du cut, ta qualification dépendra de la résistance, des égalités ou des ID (si autorisés).';
      }

      if (selectedDrawMode != "none") {
        result += '\n\n🧪 Simulations avec ID :\n' + idResults.join('\n');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stratégie en BO3')),
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
              ),
              TextFormField(
                controller: roundsController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de rondes',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => hasCustomRounds = true,
              ),
              TextFormField(
                controller: topCutController,
                decoration: const InputDecoration(labelText: 'Top cut'),
                keyboardType: TextInputType.number,
                onChanged: (_) => hasCustomTopCut = true,
              ),
              TextFormField(
                controller: currentRoundController,
                decoration: const InputDecoration(
                  labelText: 'Prochaine ronde à jouer',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: 'Score actuel'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text("Mode de gestion des Draws"),
              DropdownButton<String>(
                value: selectedDrawMode,
                items: [
                  DropdownMenuItem(value: "none", child: Text("Interdit")),
                  DropdownMenuItem(
                    value: "auto",
                    child: Text("Automatique (1%)"),
                  ),
                  DropdownMenuItem(
                    value: "custom",
                    child: Text("Personnalisé"),
                  ),
                ],
                onChanged: (val) => setState(() => selectedDrawMode = val!),
              ),
              if (selectedDrawMode == "custom") ...[
                const SizedBox(height: 8),
                Text("Taux de draw : ${customDrawPercent.toStringAsFixed(0)}%"),
                Slider(
                  min: 2,
                  max: 30,
                  divisions: 28,
                  value: customDrawPercent,
                  onChanged: (val) => setState(() => customDrawPercent = val),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => isLoading = true);
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );
                          evaluateStrategy(
                            players: int.parse(playersController.text),
                            rounds: int.parse(roundsController.text),
                            topCut: int.parse(topCutController.text),
                            currentRound: int.parse(
                              currentRoundController.text,
                            ),
                            currentScore: int.parse(scoreController.text),
                          );
                          setState(() => isLoading = false);
                        }
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
