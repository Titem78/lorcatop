import 'dart:convert';
import 'package:http/http.dart' as http;

class PlayHubService {
  static const String baseUrl =
      "https://api.playlorcana.com"; // À adapter si besoin

  // 1. Récupérer un utilisateur via son pseudo
  static Future<String?> getUserIdByName(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/rph/users'));

    if (response.statusCode == 200) {
      final users = jsonDecode(response.body);
      final user = users.firstWhere(
        (u) => u['username'].toString().toLowerCase() == username.toLowerCase(),
        orElse: () => null,
      );
      return user != null ? user['id'].toString() : null;
    } else {
      throw Exception("Erreur lors de la récupération des utilisateurs.");
    }
  }

  // 2. Liste des tournois joués par un utilisateur
  static Future<List<Map<String, dynamic>>> getUserEvents(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rph/user/$userId/events'),
    );

    if (response.statusCode == 200) {
      final events = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(events);
    } else {
      throw Exception(
        "Erreur lors de la récupération des événements de l'utilisateur.",
      );
    }
  }

  // 3. Détail complet d’un tournoi
  static Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    final response = await http.get(Uri.parse('$baseUrl/rph/event/$eventId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de la récupération des détails du tournoi.");
    }
  }
}
