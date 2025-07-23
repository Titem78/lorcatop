import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("\u00c0 propos")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/logo.png", height: 80),
            const SizedBox(height: 20),
            const Text(
              "LorcaTop v1.2\n\n"
              "Une application pens\u00e9e pour les joueurs de Lorcana souhaitant optimiser leurs strat\u00e9gies en tournoi.\n\n"
              "D\u00e9velopp\u00e9 par Made4game, sp\u00e9cialiste des accessoires de jeux.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Site : www.made4game.com",
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              "Merci à Eravell / AntoiNech",
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              "Contact : contact@made4game.com",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
