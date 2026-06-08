// ============================================================
// FICHIER : lib/widgets/vente_card.dart
// RÔLE    : Widget de carte réutilisable pour afficher une vente
//           dans la liste avec son badge de paiement.
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../models/vente.dart';

// --- WIDGET : VenteCard ---
// C'est un StatelessWidget car il ne fait qu'afficher des données
// passées en paramètre. Son état interne ne change pas.
class VenteCard extends StatelessWidget {
  final Vente vente;

  // Callback optionnel si on souhaite exécuter une action au clic
  // en plus de la navigation par défaut.
  final VoidCallback? onTap;

  const VenteCard({
    super.key,
    required this.vente,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Formatage de la date en français : "JJ/MM/AAAA à HH:mm"
    final formatDate = DateFormat('dd/MM/yyyy à HH:mm');
    final dateFormatee = formatDate.format(vente.date);

    // Couleur principale du thème pour l'icône et le texte mis en valeur
    final themeColor = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        // Au clic sur la carte, on navigue vers l'écran de détail
        // et on passe l'objet Vente en argument ("extra").
        onTap: onTap ?? () {
          context.push('/detail', extra: vente);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- 1. SECTION GAUCHE : Icône Grande ---
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: themeColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 28,
                  color: themeColor,
                ),
              ),
              const SizedBox(width: 12),

              // --- 2. SECTION CENTRALE : Textes et Badges ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre : Nom de l'article
                    Text(
                      vente.article,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Détail des quantités : ex. "Qté: 3 × 1 500 FCFA"
                    Text(
                      'Qté: ${vente.quantite} × ${vente.prixUnitaire} FCFA',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Badge du mode de paiement
                    _construireBadgePaiement(),
                  ],
                ),
              ),

              // --- 3. SECTION DROITE : Montant Total et Date ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Montant total calculé (quantite * prixUnitaire)
                  Text(
                    '${vente.montantTotal} FCFA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date de la vente
                  Text(
                    dateFormatee.split(' à ').first, // Affiche seulement la date
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
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

  // --- MÉTHODE PRIVÉE : _construireBadgePaiement() ---
  // Construit un badge visuel en fonction du mode de paiement.
  // - Mobile Money : Vert avec icône téléphone
  // - Espèces : Gris avec icône billets
  Widget _construireBadgePaiement() {
    final estMobile = vente.payeMobileMoney;

    final colorBg = estMobile ? Colors.green[50]! : Colors.grey[200]!;
    final colorTexte = estMobile ? Colors.green[800]! : Colors.grey[700]!;
    final icone = estMobile ? Icons.phone_android : Icons.payments_outlined;
    final label = estMobile ? 'Mobile Money' : 'Espèces';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: estMobile ? Colors.green[200]! : Colors.grey[350]!,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icone,
            size: 12,
            color: colorTexte,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorTexte,
            ),
          ),
        ],
      ),
    );
  }
}
