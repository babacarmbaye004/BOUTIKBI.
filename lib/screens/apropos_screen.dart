// ============================================================
// FICHIER : lib/screens/apropos_screen.dart
// RÔLE    : Écran "À propos" — exigence obligatoire du professeur.
//           Affiche le nom de l'auteur, la source des données
//           et la date de collecte.
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

import 'package:flutter/material.dart';

// --- WIDGET STATELESS : AproposScreen ---
// C'est un StatelessWidget car il n'affiche que des informations
// statiques qui ne changent jamais.
class AproposScreen extends StatelessWidget {
  const AproposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // --- 1. LOGO / EN-TÊTE DE L'APPLICATION ---
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.storefront,
                        size: 54,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Boutikbi',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Suivi des ventes d\'une boutique de quartier',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- 2. CARTE : INFORMATIONS AUTEUR ---
              _construireSectionCard(
                titre: 'AUTEUR',
                icone: Icons.person_outline,
                color: themeColor,
                enfants: [
                  _construireLigneInfo('Nom complet', 'Papa Babacar Mbaye'),
                  _construireLigneInfo('Promotion', 'DAR26 — Sujet 22'),
                  _construireLigneInfo('École', 'ESMT Dakar'),
                ],
              ),
              const SizedBox(height: 12),

              // --- 3. CARTE : SOURCE DES DONNÉES ---
              _construireSectionCard(
                titre: 'SOURCE DES DONNÉES',
                icone: Icons.data_usage,
                color: themeColor,
                enfants: [
                  _construireLigneInfo(
                    'Boutique',
                    'Épicerie de quartier — Dakar, Sénégal',
                  ),
                  _construireLigneInfo(
                    'Date de collecte',
                    'Juin 2026',
                  ),
                  _construireLigneInfo(
                    'Méthode',
                    '8 articles relevés directement en boutique',
                  ),
                  _construireLigneInfo(
                    'Devise',
                    'Franc CFA (FCFA)',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- 4. CARTE : ODD 8 ---
              _construireSectionCard(
                titre: "OBJECTIF DE DÉVELOPPEMENT DURABLE",
                icone: Icons.public,
                color: const Color(0xFFA21942),
                enfants: [
                  _construireLigneInfo('ODD', '8 — Travail décent et croissance économique'),
                  _construireLigneInfo(
                    'Mission',
                    'Aider les petits commerçants à suivre leurs ventes et recettes quotidiennes',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- 5. CARTE : STACK TECHNOLOGIQUE ---
              _construireSectionCard(
                titre: 'TECHNOLOGIES UTILISÉES',
                icone: Icons.code,
                color: Colors.blueGrey,
                enfants: [
                  _construireLigneInfo('Framework', 'Flutter 3.x (Dart)'),
                  _construireLigneInfo('Base de données', 'SQLite via sqflite'),
                  _construireLigneInfo('Routage', 'go_router'),
                  _construireLigneInfo('Formatage', 'intl (dates & montants)'),
                ],
              ),
              const SizedBox(height: 24),

              // --- 6. ODD BADGE OFFICIEL ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFA21942),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      'ODD 8',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Travail décent et croissance économique',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET : Section carte ---
  Widget _construireSectionCard({
    required String titre,
    required IconData icone,
    required Color color,
    required List<Widget> enfants,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la section
            Row(
              children: [
                Icon(icone, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  titre,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...enfants,
          ],
        ),
      ),
    );
  }

  // --- WIDGET : Ligne d'information (label + valeur) ---
  Widget _construireLigneInfo(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valeur,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
