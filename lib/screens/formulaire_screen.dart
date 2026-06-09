// ============================================================
// FICHIER : lib/screens/formulaire_screen.dart
// RÔLE    : Écran de formulaire pour ajouter ou modifier une vente
//           avec validation des champs et sauvegarde SQLite.
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/vente_dao.dart';
import '../models/vente.dart';

// --- WIDGET STATEFUL : FormulaireScreen ---
// C'est un StatefulWidget car le contenu des champs texte
// et l'état du switch (Mobile Money) sont mutables.
class FormulaireScreen extends StatefulWidget {
  // Si ce paramètre est fourni, nous sommes en mode "Modification".
  // S'il est nul, nous sommes en mode "Création".
  final Vente? vente;

  const FormulaireScreen({super.key, this.vente});

  @override
  State<FormulaireScreen> createState() => _FormulaireScreenState();
}

class _FormulaireScreenState extends State<FormulaireScreen> {
  // Clé globale qui identifie de manière unique le formulaire
  // et permet de valider les champs.
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour récupérer les textes saisis par l'utilisateur.
  // Déclarés en variables d'état pour être libérés dans dispose().
  late final TextEditingController _articleController;
  late final TextEditingController _quantiteController;
  late final TextEditingController _prixController;

  // État du mode de paiement (Mobile Money ou Espèces)
  late bool _payeMobileMoney;

  // Indique si nous sommes en mode modification
  bool get _estEnModification => widget.vente != null;

  // --- INITIALISATION DE L'ÉTAT ---
  // Pré-remplit les contrôleurs si nous modifions une vente existante.
  @override
  void initState() {
    super.initState();

    _articleController = TextEditingController(
      text: _estEnModification ? widget.vente!.article : '',
    );
    _quantiteController = TextEditingController(
      text: _estEnModification ? widget.vente!.quantite.toString() : '',
    );
    _prixController = TextEditingController(
      text: _estEnModification ? widget.vente!.prixUnitaire.toString() : '',
    );
    _payeMobileMoney = _estEnModification ? widget.vente!.payeMobileMoney : false;
  }

  // --- LIBÉRATION DES RESSOURCES ---
  // Évite les fuites de mémoire en fermant les contrôleurs.
  @override
  void dispose() {
    _articleController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  // --- SAUVEGARDE DE LA VENTE ---
  // Valide les champs, construit l'objet Vente et l'enregistre en SQLite.
  Future<void> _sauvegarder() async {
    // 1. Déclenche la validation de tous les TextFormField
    if (_formKey.currentState!.validate()) {
      final article = _articleController.text.trim();
      final quantite = int.parse(_quantiteController.text.trim());
      final prix = int.parse(_prixController.text.trim());

      final dao = VenteDao();

      if (_estEnModification) {
        // Mode modification : on met à jour la vente existante
        // en utilisant copyWith pour conserver l'id et la date.
        final venteModifiee = widget.vente!.copyWith(
          article: article,
          quantite: quantite,
          prixUnitaire: prix,
          payeMobileMoney: _payeMobileMoney,
        );

        await dao.modifier(venteModifiee);

        if (mounted) {
          // Affiche un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vente modifiée avec succès.'),
              backgroundColor: Colors.green,
            ),
          );
          // Retourne true pour indiquer qu'un changement a eu lieu
          context.pop(true);
        }
      } else {
        // Mode création : on crée une nouvelle vente.
        // L'id sera auto-généré par SQLite.
        final nouvelleVente = Vente(
          article: article,
          quantite: quantite,
          prixUnitaire: prix,
          date: DateTime.now(), // Date actuelle
          payeMobileMoney: _payeMobileMoney,
        );

        await dao.inserer(nouvelleVente);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vente ajoutée avec succès.'),
              backgroundColor: Colors.green,
            ),
          );
          // Retourne true pour recharger la liste
          context.pop(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_estEnModification ? 'Modifier la Vente' : 'Nouvelle Vente'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Associe la clé globale au formulaire
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section de titre décorative
                Text(
                  _estEnModification
                      ? 'Formulaire de modification'
                      : 'Enregistrer un nouvel article vendu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // --- 1. CHAMP : ARTICLE ---
                TextFormField(
                  controller: _articleController,
                  decoration: const InputDecoration(
                    labelText: "Nom de l'article",
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: Riz brisé, Sucre, Savon...',
                  ),
                  // Validation : ne doit pas être vide
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Veuillez saisir le nom de l'article";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- 2. CHAMP : QUANTITÉ ---
                TextFormField(
                  controller: _quantiteController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantité',
                    prefixIcon: Icon(Icons.production_quantity_limits),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 2, 5, 10...',
                  ),
                  // Validation : doit être un entier supérieur à 0
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir la quantité';
                    }
                    final quantite = int.tryParse(value.trim());
                    if (quantite == null) {
                      return 'Veuillez saisir un nombre entier valide';
                    }
                    if (quantite <= 0) {
                      return 'La quantité doit être supérieure à 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // --- 3. CHAMP : PRIX UNITAIRE ---
                TextFormField(
                  controller: _prixController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prix unitaire (FCFA)',
                    prefixIcon: Icon(Icons.sell_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 500, 1200...',
                  ),
                  // Validation : doit être un entier supérieur à 0
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir le prix unitaire';
                    }
                    final prix = int.tryParse(value.trim());
                    if (prix == null) {
                      return 'Veuillez saisir un montant entier valide';
                    }
                    if (prix <= 0) {
                      return 'Le prix doit être supérieur à 0 FCFA';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // --- 4. DECORATION & INTERRUPTEUR DE PAIEMENT ---
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: SwitchListTile(
                      title: const Text(
                        'Paiement Mobile Money',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _payeMobileMoney
                            ? 'Le client a payé par Mobile Money (Wave, OM)'
                            : 'Le client a payé en espèces (Cash)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      value: _payeMobileMoney,
                      // setState met à jour la valeur et redessine le switch
                      onChanged: (bool value) {
                        setState(() {
                          _payeMobileMoney = value;
                        });
                      },
                      secondary: Icon(
                        _payeMobileMoney ? Icons.phone_android : Icons.payments_outlined,
                        color: _payeMobileMoney ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- 5. BOUTON D'ENREGISTREMENT ---
                ElevatedButton.icon(
                  onPressed: _sauvegarder,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _estEnModification ? 'ENREGISTRER LES MODIFICATIONS' : 'ENREGISTRER LA VENTE',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
