// ============================================================
// FICHIER : lib/screens/detail_screen.dart
// RÔLE    : Écran affichant les détails complets d'une vente.
//           StatelessWidget conformément aux exigences.
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../database/vente_dao.dart';
import '../models/vente.dart';

// --- WIDGET STATELESS : DetailScreen ---
// C'est un StatelessWidget (exigence prof : affichage pur).
// L'écran reçoit les données de la vente en paramètre
// et ne gère pas d'état interne mutable.
class DetailScreen extends StatelessWidget {
  final Vente vente;

  const DetailScreen({super.key, required this.vente});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;

    // Formatage de la date en français : "9 juin 2026 à 10:30"
    final formatDate = DateFormat("d MMMM yyyy à HH:mm");
    final dateFormatee = formatDate.format(vente.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la Vente'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. CARTE DES DÉTAILS DE LA VENTE ---
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge ODD 8 en en-tête de la carte
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'PRODUIT / ARTICLE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.1,
                            ),
                          ),
                          _construireBadgeODD(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Nom de l'article en grand
                      Text(
                        vente.article,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 32),

                      // Grille d'informations (Quantité et Prix Unitaire)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _construireInfoElement(
                            'Quantité vendue',
                            '${vente.quantite} unité(s)',
                            Icons.production_quantity_limits,
                          ),
                          _construireInfoElement(
                            'Prix unitaire',
                            '${vente.prixUnitaire} FCFA',
                            Icons.sell_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Mode de paiement et Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _construireInfoElement(
                            'Mode de paiement',
                            vente.payeMobileMoney ? 'Mobile Money' : 'Espèces',
                            Icons.account_balance_wallet_outlined,
                            customWidget: _construireBadgePaiement(),
                          ),
                          _construireInfoElement(
                            'Date & Heure',
                            dateFormatee,
                            Icons.calendar_month_outlined,
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Total de la vente
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Montant Total :',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${vente.montantTotal} FCFA',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- 2. BOUTONS D'ACTION (MODIFIER & SUPPRIMER) ---
              Row(
                children: [
                  // Bouton Modifier
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                      onPressed: () async {
                        // On navigue vers le formulaire en lui passant la vente courante.
                        // Si l'utilisateur enregistre, le formulaire renverra true.
                        final aEteModifie = await context.push<bool>(
                          '/formulaire',
                          extra: vente,
                        );

                        // Si la vente a été modifiée, on retourne à la liste
                        // pour forcer son rafraîchissement.
                        if (aEteModifie == true && context.mounted) {
                          context.pop(true);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Bouton Supprimer (Rouge)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _confirmerSuppression(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET : Élément d'information ---
  Widget _construireInfoElement(String titre, String valeur, IconData icone, {Widget? customWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              titre,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        customWidget ??
            Text(
              valeur,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
      ],
    );
  }

  // --- WIDGET : Badge ODD 8 ---
  Widget _construireBadgeODD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFA21942), // Couleur officielle de l'ODD 8
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'ODD 8',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- WIDGET : Badge de paiement ---
  Widget _construireBadgePaiement() {
    final estMobile = vente.payeMobileMoney;
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: estMobile ? Colors.green[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estMobile ? 'Mobile Money' : 'Espèces',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: estMobile ? Colors.green[800] : Colors.grey[800],
        ),
      ),
    );
  }

  // --- LOGIQUE : Dialogue de Confirmation de Suppression ---
  // Exigence prof : dialogue de confirmation pour supprimer.
  void _confirmerSuppression(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // L'utilisateur doit obligatoirement choisir
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer la vente de "${vente.article}" ? Cette action est irréversible.'),
          actions: [
            // Bouton Annuler
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Ferme le dialogue
              },
              child: const Text('Annuler'),
            ),
            // Bouton Supprimer
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Ferme le dialogue
                
                // Appel au DAO pour supprimer de la base SQLite
                if (vente.id != null) {
                  await VenteDao().supprimer(vente.id!);
                  
                  if (context.mounted) {
                    // Retourne à la liste en renvoyant "true" pour recharger la liste
                    context.pop(true);
                    
                    // Affiche une confirmation discrète
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vente supprimée avec succès.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
