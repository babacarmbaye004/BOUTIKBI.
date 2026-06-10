# Boutikbi — Suivi des Ventes d'une Boutique de Quartier

> **Projet Flutter — DAR26 — Sujet 22**  
> **ODD 8 — Travail décent et croissance économique**  
> **Auteur : Papa Babacar Mbaye — ESMT Dakar**

---

## Présentation

**Boutikbi** est une application mobile Flutter permettant à un boutiquier de quartier d'enregistrer ses ventes quotidiennes et de consulter sa recette du jour en temps réel.

L'application s'inscrit dans l'**Objectif de Développement Durable n°8** des Nations Unies — *Travail décent et croissance économique* — en aidant les petits commerçants du Sénégal à numériser la gestion de leurs ventes et à mieux piloter leur activité.

---

## Fonctionnalités

- ✅ **Enregistrer** une vente (article, quantité, prix unitaire, mode de paiement)
- ✅ **Consulter** la liste des ventes avec la recette du jour en en-tête
- ✅ **Voir le détail** d'une vente (montant total calculé automatiquement)
- ✅ **Modifier** une vente existante via un formulaire pré-rempli
- ✅ **Supprimer** une vente avec confirmation obligatoire
- ✅ **Filtrer** les ventes par paiement en Mobile Money (Wave, Orange Money)
- ✅ **Persistance SQLite** : les données sont conservées entre les sessions

---

## Architecture du projet

```
lib/
├── main.dart              ← ThemeData orange + go_router (4 routes)
├── models/
│   └── vente.dart         ← Classe Vente + enum ModePaiement
├── database/
│   └── vente_dao.dart     ← CRUD complet SQLite
├── screens/
│   ├── liste_screen.dart  ← Écran 1 : StatefulWidget (liste + recette)
│   ├── detail_screen.dart ← Écran 2 : StatelessWidget (détail + suppression)
│   ├── formulaire_screen.dart ← Écran 3 : StatefulWidget (création/modification)
│   └── apropos_screen.dart    ← Écran 4 : StatelessWidget (À propos)
└── widgets/
    └── vente_card.dart    ← Widget réutilisable (carte vente + badge paiement)
```

---

## Données réelles collectées

Les 8 articles ont été relevés dans une épicerie de quartier à Dakar (Sénégal) en **juin 2026** :

| Article | Prix unitaire | Mode de paiement |
|---|---|---|
| Riz brisé 5kg | 3 500 FCFA | Espèces |
| Huile Ndémba 1L | 1 200 FCFA | Mobile Money |
| Sucre 1kg | 800 FCFA | Espèces |
| Lait Ceres 500ml | 750 FCFA | Mobile Money |
| Savon Omo 400g | 600 FCFA | Espèces |
| Tomate concentrée | 250 FCFA | Mobile Money |
| Cube Maggi x10 | 500 FCFA | Espèces |
| Eau minérale 1.5L | 400 FCFA | Mobile Money |

---

## Compétences Flutter démontrées

| Compétence | Implémentation |
|---|---|
| **Dart** | Classe `Vente`, `enum ModePaiement`, `List<Vente>`, `Map<String, dynamic>`, null safety, getter `montantTotal` |
| **Stateless / Stateful** | `DetailScreen` et `AproposScreen` → Stateless ; `ListeScreen` et `FormulaireScreen` → Stateful + setState |
| **UI personnalisée** | ThemeData orange (#EF9F27), widget `VenteCard`, badge coloré Mobile Money |
| **CRUD complet** | Créer (formulaire validé), Lire (liste + détail), Modifier (pré-rempli), Supprimer (AlertDialog) |
| **Routage** | go_router avec 4 routes nommées, passage de l'objet `Vente` via `extra` |
| **Bonus SQLite** | Persistance via sqflite — données conservées entre fermetures |

---

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.x
- Dart ≥ 3.x
- Un émulateur Android/iOS ou un appareil physique

---

## Lancement

```bash
# Cloner le dépôt
git clone <url-du-dépôt>
cd boutikbi

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

---

## Licence

Projet académique — ESMT Dakar — DAR26 — 2026
