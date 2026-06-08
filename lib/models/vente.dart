// ============================================================
// FICHIER : lib/models/vente.dart
// RÔLE    : Définit la structure d'une vente en boutique
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

// --- ENUM : Mode de paiement ---
// Un enum est une liste fermée de valeurs possibles.
// Ici, un paiement ne peut être QUE mobile money OU espèces.
// C'est une exigence explicite du professeur.
enum ModePaiement {
  mobileMoney, // Paiement via Wave, Orange Money, etc.
  especes,     // Paiement en cash
}

// --- CLASSE : Vente ---
// Une classe est un modèle (un moule) qui décrit ce qu'est
// un objet. Ici, chaque "Vente" a exactement ces 6 champs.
class Vente {

  // --- CHAMPS (attributs) de la classe ---
  // "final" signifie que ces valeurs ne changent pas
  // une fois que la vente est créée.
  // "int?" signifie que id peut être null (avant d'être
  // enregistré en base de données, il n'a pas encore d'id).
  final int?    id;             // Identifiant unique (SQLite)
  final String  article;        // Nom de l'article vendu
  final int     quantite;       // Nombre d'unités vendues
  final int     prixUnitaire;   // Prix en FCFA (entier, pas de centimes)
  final DateTime date;          // Date et heure de la vente
  final bool    payeMobileMoney; // true = Mobile Money, false = Espèces

  // --- CONSTRUCTEUR NOMMÉ ---
  // Le constructeur crée un objet Vente.
  // Les "{}" signifient que les paramètres sont nommés :
  // on doit écrire Vente(article: 'Riz', quantite: 2, ...)
  // "required" signifie que le paramètre est obligatoire.
  const Vente({
    this.id,                       // Optionnel (null si nouveau)
    required this.article,
    required this.quantite,
    required this.prixUnitaire,
    required this.date,
    required this.payeMobileMoney,
  });

  // --- GETTER : montantTotal ---
  // Un getter est une propriété calculée automatiquement.
  // On y accède comme un champ : vente.montantTotal
  // mais il est calculé à la volée (pas stocké).
  // EXIGENCE DU PROF : au moins une méthode qui calcule.
  int get montantTotal => quantite * prixUnitaire;

  // --- GETTER : modePaiement ---
  // Retourne l'enum correspondant au booléen payeMobileMoney.
  // Utile pour l'affichage et le filtre.
  ModePaiement get modePaiement =>
      payeMobileMoney ? ModePaiement.mobileMoney : ModePaiement.especes;

  // --- MÉTHODE : toMap() ---
  // Convertit l'objet Vente en Map<String, dynamic>.
  // SQLite ne comprend pas les objets Dart directement —
  // il travaille avec des Maps (comme un dictionnaire).
  // Cette méthode est utilisée pour ENREGISTRER dans SQLite.
  Map<String, dynamic> toMap() {
    return {
      // On n'inclut "id" que s'il existe déjà
      if (id != null) 'id': id,
      'article'          : article,
      'quantite'         : quantite,
      'prix_unitaire'    : prixUnitaire,
      // DateTime ne se stocke pas directement en SQLite.
      // On le convertit en texte au format ISO 8601 :
      // exemple : "2026-06-08T14:30:00.000"
      'date'             : date.toIso8601String(),
      // SQLite ne connaît pas les booléens.
      // On le convertit : true → 1, false → 0
      'paye_mobile_money': payeMobileMoney ? 1 : 0,
    };
  }

  // --- CONSTRUCTEUR FACTORY : fromMap() ---
  // Fait l'inverse de toMap() : recrée un objet Vente
  // à partir d'une Map récupérée depuis SQLite.
  // Utilisé pour LIRE les données depuis SQLite.
  factory Vente.fromMap(Map<String, dynamic> map) {
    return Vente(
      id            : map['id'] as int?,
      article       : map['article'] as String,
      quantite      : map['quantite'] as int,
      prixUnitaire  : map['prix_unitaire'] as int,
      // On reconvertit le texte ISO 8601 en DateTime
      date          : DateTime.parse(map['date'] as String),
      // On reconvertit 1/0 en booléen : 1 → true, 0 → false
      payeMobileMoney: (map['paye_mobile_money'] as int) == 1,
    );
  }

  // --- MÉTHODE : copyWith() ---
  // Crée une copie de la vente en modifiant seulement
  // certains champs. Très utile pour la modification (UPDATE).
  // Exemple : vente.copyWith(quantite: 5)
  // retourne la même vente mais avec quantite = 5.
  Vente copyWith({
    int?     id,
    String?  article,
    int?     quantite,
    int?     prixUnitaire,
    DateTime? date,
    bool?    payeMobileMoney,
  }) {
    return Vente(
      id             : id             ?? this.id,
      article        : article        ?? this.article,
      quantite       : quantite       ?? this.quantite,
      prixUnitaire   : prixUnitaire   ?? this.prixUnitaire,
      date           : date           ?? this.date,
      payeMobileMoney: payeMobileMoney ?? this.payeMobileMoney,
    );
  }

  // --- MÉTHODE : toString() ---
  // Permet d'afficher une vente lisiblement dans la console.
  // Utile pour déboguer pendant le développement.
  @override
  String toString() {
    return 'Vente(id: $id, article: $article, '
        'quantite: $quantite, prix: $prixUnitaire FCFA, '
        'total: $montantTotal FCFA, '
        'paiement: ${payeMobileMoney ? "Mobile Money" : "Espèces"})';
  }
}