// ============================================================
// FICHIER : lib/screens/formulaire_screen.dart
// RÔLE    : Écran de formulaire pour création/modification (Stub)
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

import 'package:flutter/material.dart';
import '../models/vente.dart';

class FormulaireScreen extends StatefulWidget {
  final Vente? vente;

  const FormulaireScreen({super.key, this.vente});

  @override
  State<FormulaireScreen> createState() => _FormulaireScreenState();
}

class _FormulaireScreenState extends State<FormulaireScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vente == null ? 'Nouvelle Vente' : 'Modifier Vente'),
      ),
      body: const Center(
        child: Text('Formulaire de vente (Stub)'),
      ),
    );
  }
}
