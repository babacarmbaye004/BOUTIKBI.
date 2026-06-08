// ============================================================
// FICHIER : lib/screens/detail_screen.dart
// RÔLE    : Écran de détails d'une vente (Stub)
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

import 'package:flutter/material.dart';
import '../models/vente.dart';

class DetailScreen extends StatelessWidget {
  final Vente vente;

  const DetailScreen({super.key, required this.vente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la vente (Stub)'),
      ),
      body: Center(
        child: Text('Vente : ${vente.article} (Stub)'),
      ),
    );
  }
}
