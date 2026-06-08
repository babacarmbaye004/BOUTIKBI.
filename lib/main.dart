// ============================================================
// FICHIER : lib/main.dart
// RÔLE    : Point d'entrée de l'application Boutikbi.
//           Configure le thème orange, le routage go_router
//           et initialise la base de données.
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'database/vente_dao.dart';
import 'models/vente.dart';
import 'screens/liste_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/formulaire_screen.dart';
import 'screens/apropos_screen.dart';

void main() async {
  // Assure que les liaisons des widgets Flutter sont prêtes
  // car nous faisons des appels asynchrones (SQLite) avant runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de la base de données SQLite
  // et chargement des 8 articles de démonstration si vide.
  final dao = VenteDao();
  await dao.insererDonneesInitiales();

  // Lance l'application
  runApp(const MyApp());
}

// --- CONFIGURATION DE GO_ROUTER ---
// go_router gère la navigation par routes nommées.
// Les arguments complexes (comme l'objet Vente) sont passés via "extra".
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // 1. ÉCRAN : Liste des Ventes (Accueil)
    GoRoute(
      path: '/',
      builder: (context, state) => const ListeScreen(),
    ),
    // 2. ÉCRAN : Détail d'une vente
    GoRoute(
      path: '/detail',
      builder: (context, state) {
        // Récupération de l'objet Vente passé en paramètre
        final vente = state.extra as Vente;
        return DetailScreen(vente: vente);
      },
    ),
    // 3. ÉCRAN : Formulaire (Création ou Édition)
    GoRoute(
      path: '/formulaire',
      builder: (context, state) {
        // En mode création, "extra" est null.
        // En mode modification, "extra" contient l'objet Vente à éditer.
        final vente = state.extra as Vente?;
        return FormulaireScreen(vente: vente);
      },
    ),
    // 4. ÉCRAN : À propos (Exigence prof)
    GoRoute(
      path: '/apropos',
      builder: (context, state) => const AproposScreen(),
    ),
  ],
);

// --- CLASS PRINCIPALE : MyApp ---
// C'est un StatelessWidget car la configuration globale du thème
// et des routes ne change pas dynamiquement pendant l'exécution.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Boutikbi',
      debugShowCheckedModeBanner: false,

      // --- CONFIGURATION DU THÈME ---
      // Couleur principale : Orange (#EF9F27) demandée par le sujet.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEF9F27),
          primary: const Color(0xFFEF9F27),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEF9F27),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        // Style global des boutons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF9F27),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // Style du FloatingActionButton
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFEF9F27),
          foregroundColor: Colors.white,
        ),
      ),

      // --- CONFIGURATION DU ROUTAGE ---
      routerConfig: _router,
    );
  }
}
