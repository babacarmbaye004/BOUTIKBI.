// ============================================================
// FICHIER : lib/screens/liste_screen.dart
// RÔLE    : Écran principal affichant la liste des ventes (Stub)
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

import 'package:flutter/material.dart';

class ListeScreen extends StatefulWidget {
  const ListeScreen({super.key});

  @override
  State<ListeScreen> createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutikbi — Ventes'),
      ),
      body: const Center(
        child: Text('Liste des ventes (Stub)'),
      ),
    );
  }
}
