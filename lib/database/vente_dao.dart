// ============================================================
// FICHIER : lib/database/vente_dao.dart
// RÔLE    : Gère toutes les opérations SQLite pour les ventes
//           CREATE · READ · UPDATE · DELETE
// AUTEUR  : Papa Babacar Mbaye — Boutikbi — ODD 8
// ============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vente.dart';

// --- CLASSE : VenteDao ---
// Cette classe est un "Singleton" : il n'existe qu'une seule
// instance de cette classe dans toute l'application.
// Cela évite d'ouvrir la base de données plusieurs fois.
class VenteDao {

  // --- SINGLETON ---
  // Instance unique de VenteDao
  static final VenteDao _instance = VenteDao._interne();

  // Constructeur privé — personne ne peut faire VenteDao()
  // depuis l'extérieur
  VenteDao._interne();

  // Factory : retourne toujours la même instance
  factory VenteDao() => _instance;

  // La base de données elle-même (nullable au départ)
  static Database? _database;

  // --- GETTER : database ---
  // Si la base n'existe pas encore, on l'initialise.
  // "async" signifie que cette opération prend du temps
  // (lecture/écriture sur le disque).
  // "Future" signifie qu'elle retournera une valeur plus tard.
  Future<Database> get database async {
    // Si déjà initialisée, on la retourne directement
    if (_database != null) return _database!;
    // Sinon on l'initialise
    _database = await _initialiserDatabase();
    return _database!;
  }

  // --- MÉTHODE PRIVÉE : _initialiserDatabase() ---
  // Crée et ouvre le fichier SQLite sur l'appareil.
  Future<Database> _initialiserDatabase() async {
    // getDatabasesPath() trouve le bon dossier sur l'appareil
    // join() construit le chemin complet : dossier + nom fichier
    final chemin = join(await getDatabasesPath(), 'boutikbi.db');

    return await openDatabase(
      chemin,
      // Version de la base — si on modifie la structure,
      // on incrémente ce numéro
      version: 1,
      // onCreate est appelé UNE SEULE FOIS à la création
      onCreate: _creerTable,
    );
  }

  // --- MÉTHODE PRIVÉE : _creerTable() ---
  // Crée la table "ventes" dans SQLite.
  // Appelée automatiquement à la première ouverture.
  Future<void> _creerTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ventes (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        article           TEXT    NOT NULL,
        quantite          INTEGER NOT NULL,
        prix_unitaire     INTEGER NOT NULL,
        date              TEXT    NOT NULL,
        paye_mobile_money INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ============================================================
  // CREATE — Enregistrer une nouvelle vente
  // ============================================================
  // Reçoit un objet Vente, le convertit en Map, l'insère.
  // Retourne l'id généré automatiquement par SQLite.
  Future<int> inserer(Vente vente) async {
    final db = await database;
    return await db.insert(
      'ventes',          // Nom de la table
      vente.toMap(),     // Conversion en Map pour SQLite
      // Si conflit sur l'id, on remplace (sécurité)
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // READ — Lire toutes les ventes
  // ============================================================
  // Retourne une List<Vente> avec toutes les ventes,
  // triées de la plus récente à la plus ancienne.
  Future<List<Vente>> toutesLesVentes() async {
    final db = await database;

    // query() retourne une List<Map<String, dynamic>>
    final List<Map<String, dynamic>> maps = await db.query(
      'ventes',
      orderBy: 'date DESC', // Plus récent en premier
    );

    // On convertit chaque Map en objet Vente avec fromMap()
    // ".map()" applique une fonction à chaque élément de la liste
    return maps.map((map) => Vente.fromMap(map)).toList();
  }

  // ============================================================
  // READ — Lire les ventes d'aujourd'hui seulement
  // ============================================================
  // Utilisé pour calculer la recette du jour.
  Future<List<Vente>> ventesAujourdhui() async {
    final db = await database;

    // On récupère la date d'aujourd'hui au format YYYY-MM-DD
    final aujourdhui = DateTime.now();
    final debut = DateTime(
      aujourdhui.year,
      aujourdhui.month,
      aujourdhui.day,
      0, 0, 0,   // Minuit — début de la journée
    );
    final fin = DateTime(
      aujourdhui.year,
      aujourdhui.month,
      aujourdhui.day,
      23, 59, 59, // Fin de la journée
    );

    // WHERE filtre les résultats selon une condition
    // BETWEEN vérifie si la date est entre début et fin
    final List<Map<String, dynamic>> maps = await db.query(
      'ventes',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
      orderBy: 'date DESC',
    );

    return maps.map((map) => Vente.fromMap(map)).toList();
  }

  // ============================================================
  // UPDATE — Modifier une vente existante
  // ============================================================
  // Retourne le nombre de lignes modifiées (1 si succès).
  Future<int> modifier(Vente vente) async {
    final db = await database;
    return await db.update(
      'ventes',
      vente.toMap(),
      // WHERE id = ? — on modifie uniquement cette vente
      where: 'id = ?',
      whereArgs: [vente.id],
    );
  }

  // ============================================================
  // DELETE — Supprimer une vente
  // ============================================================
  // Reçoit l'id de la vente à supprimer.
  // Retourne le nombre de lignes supprimées (1 si succès).
  Future<int> supprimer(int id) async {
    final db = await database;
    return await db.delete(
      'ventes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // UTILITAIRE — Calculer la recette du jour
  // ============================================================
  // Récupère les ventes d'aujourd'hui et fait la somme
  // des montants totaux (quantite × prixUnitaire).
  Future<int> recetteDuJour() async {
    final ventes = await ventesAujourdhui();

    // Correction : boucle simple au lieu de fold
    // pour éviter le problème de type FutureOr<int>
    int somme = 0;
    for (final vente in ventes) {
      somme = somme + vente.montantTotal;
    }
    return somme;
  }

  // ============================================================
  // UTILITAIRE — Insérer les données réelles initiales
  // ============================================================
  // Appelée au premier lancement pour pré-remplir l'app
  // avec tes 8 articles réels collectés en boutique.
  Future<void> insererDonneesInitiales() async {
    final ventes = await toutesLesVentes();

    // On n'insère que si la base est vide
    if (ventes.isNotEmpty) return;

    // ⚠️ TU DOIS REMPLACER CES DONNÉES PAR TES VRAIS ARTICLES
    // Collectés dans ta boutique de quartier à Dakar
    final List<Vente> donneesReelles = [
      Vente(
        article        : 'Riz brisé 5kg',
        quantite       : 3,
        prixUnitaire   : 3500,
        date           : DateTime.now(),
        payeMobileMoney: false,
      ),
      Vente(
        article        : 'Huile Ndémba 1L',
        quantite       : 2,
        prixUnitaire   : 1200,
        date           : DateTime.now(),
        payeMobileMoney: true,
      ),
      Vente(
        article        : 'Sucre 1kg',
        quantite       : 4,
        prixUnitaire   : 800,
        date           : DateTime.now(),
        payeMobileMoney: false,
      ),
      Vente(
        article        : 'Lait Ceres 500ml',
        quantite       : 2,
        prixUnitaire   : 750,
        date           : DateTime.now(),
        payeMobileMoney: true,
      ),
      Vente(
        article        : 'Savon Omo 400g',
        quantite       : 5,
        prixUnitaire   : 600,
        date           : DateTime.now(),
        payeMobileMoney: false,
      ),
      Vente(
        article        : 'Tomate concentrée',
        quantite       : 6,
        prixUnitaire   : 250,
        date           : DateTime.now(),
        payeMobileMoney: true,
      ),
      Vente(
        article        : 'Cube Maggi x10',
        quantite       : 3,
        prixUnitaire   : 500,
        date           : DateTime.now(),
        payeMobileMoney: false,
      ),
      Vente(
        article        : 'Eau minérale 1.5L',
        quantite       : 10,
        prixUnitaire   : 400,
        date           : DateTime.now(),
        payeMobileMoney: true,
      ),
    ];

    // On insère chaque vente une par une
    for (final vente in donneesReelles) {
      await inserer(vente);
    }
  }
}