import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlayhubDebugPage extends StatefulWidget {
  const PlayhubDebugPage({super.key});

  @override
  State<PlayhubDebugPage> createState() => _PlayhubDebugPageState();
}

class _PlayhubDebugPageState extends State<PlayhubDebugPage> {
  List<dynamic> users = [];
  List<dynamic> events = [];
  bool isLoading = false;
  String error = '';

  final String baseUrl =
      'https://api.ravensburger.com'; // à adapter selon endpoint réel

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final usersRes = await http.get(Uri.parse('$baseUrl/rph/users'));
      final eventsRes = await http.get(Uri.parse('$baseUrl/rph/events'));

      if (usersRes.statusCode == 200 && eventsRes.statusCode == 200) {
        setState(() {
          users = jsonDecode(usersRes.body);
          events = jsonDecode(eventsRes.body);
        });
      } else {
        setState(() {
          error =
              'Erreur de chargement (code ${usersRes.statusCode}/${eventsRes.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur réseau ou parsing : $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Widget sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.orange,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug PlayHub API')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
            ? Center(
                child: Text(error, style: const TextStyle(color: Colors.red)),
              )
            : ListView(
                children: [
                  sectionTitle("👤 Utilisateurs (${users.length})"),
                  ...users.take(5).map((u) => Text(u.toString())).toList(),
                  sectionTitle("📅 Événements (${events.length})"),
                  ...events.take(5).map((e) => Text(e.toString())).toList(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchData,
                    child: const Text("🔄 Rafraîchir"),
                  ),
                ],
              ),
      ),
    );
  }
}
