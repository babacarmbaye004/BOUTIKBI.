// ============================================================
// FICHIER : lib/screens/liste_screen.dart
// RÔLE    : Écran principal de l'application Boutikbi.
//           Affiche la recette du jour, la liste des ventes
//           avec filtrage par Mobile Money et navigation.
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/vente_dao.dart';
import '../models/vente.dart';
import '../widgets/vente_card.dart';

// --- WIDGET STATEFUL : ListeScreen ---
// Nous utilisons un StatefulWidget car cet écran gère un état qui change :
// 1. La liste des ventes chargée de SQLite.
// 2. Le filtre Mobile Money (activé/désactivé).
// 3. Le montant total de la recette du jour.
class ListeScreen extends StatefulWidget {
  const ListeScreen({super.key});

  @override
  State<ListeScreen> createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  // Instance du DAO pour communiquer avec SQLite
  final VenteDao _venteDao = VenteDao();

  // États locaux de l'écran
  List<Vente> _toutesLesVentes = [];
  bool _filtrerMobileMoney = false; // true = filtrer, false = tout afficher
  int _recette = 0;
  bool _chargement = true;

  // --- INITIALISATION DE L'ÉTAT ---
  // initState est appelé une seule fois à la création de l'écran.
  // C'est l'endroit parfait pour charger les données initiales.
  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  // --- CHARGEMENT DES DONNÉES ---
  // Récupère les ventes et la recette depuis SQLite de manière asynchrone,
  // puis met à jour l'interface graphique via setState.
  Future<void> _chargerDonnees() async {
    setState(() {
      _chargement = true;
    });

    try {
      final ventes = await _venteDao.toutesLesVentes();
      final recetteJour = await _venteDao.recetteDuJour();

      // On met à jour l'état. setState notifie Flutter qu'il doit
      // reconstruire l'interface avec les nouvelles valeurs.
      setState(() {
        _toutesLesVentes = ventes;
        _recette = recetteJour;
        _chargement = false;
      });
    } catch (e) {
      setState(() {
        _chargement = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement : $e')),
        );
      }
    }
  }

  // --- GETTER : Ventes filtrées ---
  // Calcule la liste à afficher en fonction du filtre Mobile Money.
  List<Vente> get _ventesFiltrees {
    if (_filtrerMobileMoney) {
      return _toutesLesVentes.where((v) => v.payeMobileMoney).toList();
    }
    return _toutesLesVentes;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;

    return Scaffold(
      // --- BARRE D'ACTION (AppBar) ---
      appBar: AppBar(
        title: const Text('Boutikbi — Tableau de Bord'),
        actions: [
          // Bouton pour aller à l'écran "À propos"
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: "À propos de l'application",
            onPressed: () async {
              await context.push('/apropos');
              // On recharge les données au cas où
              _chargerDonnees();
            },
          ),
        ],
      ),

      // --- CORPS DE L'ÉCRAN ---
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- 1. EN-TÊTE : Recette du jour ---
                _construireCardRecette(themeColor),

                // --- 2. ZONE DE FILTRE ---
                _construireFiltreSection(themeColor),

                // --- 3. LISTE DES VENTES ---
                Expanded(
                  child: _ventesFiltrees.isEmpty
                      ? _construireListeVide()
                      : ListView.builder(
                          itemCount: _ventesFiltrees.length,
                          itemBuilder: (context, index) {
                            final vente = _ventesFiltrees[index];
                            return VenteCard(
                              vente: vente,
                              // Lorsque l'utilisateur revient du détail,
                              // on recharge pour voir si une vente a été modifiée/supprimée.
                              onTap: () async {
                                await context.push('/detail', extra: vente);
                                _chargerDonnees();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),

      // --- BOUTON D'AJOUT (FAB) ---
      // Navigue vers le formulaire en mode création (extra = null).
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ajouter une vente',
        onPressed: () async {
          // Attendre le retour du formulaire pour actualiser
          await context.push('/formulaire');
          _chargerDonnees();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- CONSTRUIRE : Carte de la Recette ---
  Widget _construireCardRecette(Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECETTE DU JOUR',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_recette FCFA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Calculée automatiquement sur les ventes du jour',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // --- CONSTRUIRE : Section Filtre ---
  Widget _construireFiltreSection(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Filtre Mobile Money',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          // Interrupteur (Switch) pour activer/désactiver le filtre
          Switch(
            value: _filtrerMobileMoney,
            onChanged: (bool value) {
              // setState indique à Flutter de redessiner l'écran
              // avec la nouvelle valeur de _filtrerMobileMoney
              setState(() {
                _filtrerMobileMoney = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // --- CONSTRUIRE : Liste Vide ---
  Widget _construireListeVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_checkout_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _filtrerMobileMoney
                ? 'Aucune vente par Mobile Money'
                : 'Aucune vente enregistrée',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
