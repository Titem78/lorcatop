import 'package:flutter/material.dart';
import 'playhub_service.dart';

class StrategyPlayhubPage extends StatefulWidget {
  const StrategyPlayhubPage({super.key});

  @override
  State<StrategyPlayhubPage> createState() => _StrategyPlayhubPageState();
}

class _StrategyPlayhubPageState extends State<StrategyPlayhubPage> {
  final TextEditingController _usernameController = TextEditingController();
  bool isLoading = false;
  String? userId;
  List<Map<String, dynamic>> userEvents = [];
  Map<String, dynamic>? selectedEvent;
  String result = "";

  Future<void> fetchUser() async {
    setState(() {
      isLoading = true;
      userEvents.clear();
      selectedEvent = null;
      result = "";
    });

    try {
      final id = await PlayHubService.getUserIdByName(
        _usernameController.text.trim(),
      );

      if (id == null) {
        setState(() {
          result = "❌ Utilisateur non trouvé.";
          isLoading = false;
        });
        return;
      }

      userId = id;
      final events = await PlayHubService.getUserEvents(id);

      setState(() {
        userEvents = events;
        result =
            "✅ ${events.length} tournoi(s) trouvé(s). Choisis-en un pour analyser.";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        result = "❌ Erreur : ${e.toString()}";
        isLoading = false;
      });
    }
  }

  Future<void> analyzeEvent(String eventId) async {
    setState(() {
      isLoading = true;
      result = "Analyse en cours...";
    });

    try {
      final details = await PlayHubService.getEventDetails(eventId);
      selectedEvent = details;

      final rounds = details['tournamentPhase']?['rounds'] ?? [];
      final standings = details['standings'] ?? [];

      final me = standings.firstWhere(
        (s) => s['user']['id'].toString() == userId,
        orElse: () => null,
      );

      if (me == null) {
        setState(() {
          result = "❌ Ton profil n'apparaît pas dans ce tournoi.";
          isLoading = false;
        });
        return;
      }

      final currentScore = me['points'] ?? 0;
      final currentRoundNum =
          rounds.where((r) => r['status'] == 'COMPLETED').length + 1;
      final totalRounds = rounds.length;
      final totalPlayers = standings.length;
      final topCut = 8;

      final maxReachable =
          currentScore + ((totalRounds - (currentRoundNum - 1)) * 3);

      String advice;
      if (currentRoundNum > totalRounds) {
        advice = "⚠️ Tu as terminé toutes les rondes.";
      } else if (currentScore >= 3 * (totalRounds - 2)) {
        advice = "✅ Très bien placé, sauf catastrophe.";
      } else if (maxReachable < 3 * (totalRounds - 3)) {
        advice = "❌ Trop juste. Tu devras probablement tout gagner.";
      } else {
        advice =
            "🟡 Tu dois encore performer pour sécuriser une place dans le top.";
      }

      setState(() {
        result =
            '''
📊 Tournoi : ${details['name']}
Joueurs : $totalPlayers
Rondes : $totalRounds
Ronde actuelle : $currentRoundNum
Score actuel : $currentScore
Score max possible : $maxReachable

$advice
''';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        result = "❌ Erreur lors de l'analyse : ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stratégie - PlayHub Connect")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "🔎 Recherche ton pseudo PlayHub pour voir ta progression dans un tournoi.",
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Pseudo PlayHub"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isLoading ? null : fetchUser,
              child: Text(
                isLoading ? "Chargement..." : "Rechercher mes tournois",
              ),
            ),
            const SizedBox(height: 20),
            if (userEvents.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📅 Sélectionne un tournoi :"),
                  ...userEvents.map((e) {
                    return ListTile(
                      title: Text(e['name'] ?? 'Tournoi sans nom'),
                      subtitle: Text("ID: ${e['id']}"),
                      onTap: () => analyzeEvent(e['id'].toString()),
                    );
                  }).toList(),
                ],
              ),
            const SizedBox(height: 20),
            Text(result, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
