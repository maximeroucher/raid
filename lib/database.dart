import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'point.dart';
import 'benevole.dart';
import 'equipe.dart';
import 'lienMissionsBeneveloves.dart';

// le gestionnaire de base de donnée
class DatabaseManager {
  DatabaseManager._init();

  // L'instance, l'accès pour les autres classes à la base de donnée
  static final DatabaseManager instance = DatabaseManager._init();

  // La base de donnée
  static Database _database;

  static const String filePath = 'database.db';

  // La conversion des types dart en type SQL
  final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  final intType = 'INTEGER NOT NULL';
  final stringType = 'TEXT NOT NULL';
  final doubleType = 'REAL NOT NULL';

  // Récupère la base de donnée si elle ne l'était pas déjà
  Future<Database> get database async => _database ??= await _initDB();

  Future<Database> _initDB() async {
    /**
     * Ouvre la base de donnée
     *
     * result :
     *     - Future<Database>
     */
    // On récupère le chemin vers la base de donné
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    //await deleteDatabase(path);
    // On ouvre la basse de donnée
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    /**
     * Crée les tables dans la base de donnée
     *
     * param :
     *     - db (Database)
     *     - version (int)
    */

    // Crée la table des bénévoles
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $tableBenevole (
        ${BenevoleFields.id} $idType,
        ${BenevoleFields.nom} $stringType,
        ${BenevoleFields.surnom} $stringType,
        ${BenevoleFields.num} $stringType,
        ${BenevoleFields.type} $intType,
        ${BenevoleFields.indexMission} $intType,
        ${BenevoleFields.statusMission} $intType
    );
    ''');

    // Crée la table des points
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $tablePoint (
        ${PointFields.id} $idType,
        ${PointFields.lat} $doubleType,
        ${PointFields.long} $doubleType,
        ${PointFields.nom} $stringType,
        ${PointFields.type} $intType,
        ${PointFields.status} $intType,
        ${PointFields.numOnPoint} $intType,
        ${PointFields.pointPrec} $stringType
    );
    ''');

    // Crée la table des liens
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $tableLien (
        ${LienFields.ben} $intType,
        ${LienFields.mission} $intType,
        ${PointFields.dateDebut} $stringType,
        ${PointFields.dateFin} $stringType
    );
    ''');
  }

  void createEquipetable(Equipe e) async {
    /**
     * Crée la table pour les équipes
     *
     * param :
     *     - e (Equipe)
     */
    final db = await instance.database;
    // On transforme l'équipe en dictionnaire
    final json = e.toJson();
    // Le début de la commande SQL
    String cmd = '''
    CREATE TABLE IF NOT EXISTS $tableEquipe (
        ${EquipeFields.id} $idType,
        ${EquipeFields.nom} $stringType,
        ${EquipeFields.num} $intType,
        ${EquipeFields.type} $intType''';
    // Les colonnes déjà dans la commande
    final k = ["id", "num", "nom", "type"];
    // On regarde les différentes colonnes crée pour l'équipe
    for (String s in json.keys) {
      // Si elle n'est pas dans les 4 déjà ajoutées
      if (!k.contains(s)) {
        // On ajoute cette colonne à la commande
        cmd += ''',\n''';
        cmd += '''$s $stringType''';
      }
    }
    // On termine la commande
    cmd += ''');''';
    // Créer la table des équipes
    await db.execute(cmd);
  }

  Future close() async {
    /**
     * Ferme la base de donnée
     */
    final db = await instance.database;
    db.close();
  }

  Future<List<String>> getEpreuve() async {
    /**
     * Retourne la lsite des épreuves contenue dans la base de données
     *
     * result :
     *     - Future<List<String>>
     */
    // La base de donnée
    final db = await instance.database;
    // On récupère la première équipe
    final r = await db.rawQuery('''
      SELECT * FROM $tableEquipe LIMIT 1
      ''');
    // On ne regarde que les colonnes après la 4e, puisqu'elles sont id, num, nom et type
    var l = r[0].keys.toList().sublist(4);
    // La liste des épreuves
    List<String> resp = [];
    // On ne regarde que la moitié de la liste
    for (int x = 0; x < l.length / 2; x++) {
      // On reformatte le nom de la colonne pour l'affichage et on l'ajoute à la liste
      String s = l[x]
          .replaceAll("_", " ")
          .replaceAll("\$", "&")
          .substring(0, l[x].length - 1);
      resp.add(s);
    }
    return resp.toList();
  }

  Future<List<Benevole>> readAllBenevoles() async {
    /**
     * Lis tous les bénévoles de la base de donnée
     *
     * result :
     *     - Future<List<Benevole>>
     */
    // La base de donnée
    final db = await instance.database;
    // Pour ordonner les résultats
    const orderBy = '${BenevoleFields.type} DESC';
    // On récupère tous les bénévoles de la base de donnée
    final result = await db.query(tableBenevole, orderBy: orderBy);
    // On transforme le résultat de la requête en liste de bénévole
    List<Benevole> r = result.map((e) => Benevole.fromJson(e)).toList();
    // Pour chqque bénévole
    for (Benevole b in r) {
      // On récupère tous les identifiants de ses missions
      final pointsId = await db
          .query(tableLien, where: '${LienFields.ben} = ?', whereArgs: [b.id]);
      // On transforme le résultat de la requête en liste de liens
      List<Lien> liens = pointsId.map((e) => Lien.fromJson(e)).toList();
      List<Point> pts = [];
      // Pour chaque lien
      for (Lien l in liens) {
        // On récupère le point associé
        final respPoints = await db.query(tablePoint,
            where: '${PointFields.id} = ?', whereArgs: [l.mission]);
        // On ajoute le point transformé à la lsite des points du bénévole
        pts.addAll(respPoints.map((e) {
          Point p = Point.fromJson(e);
          // On rempli les date de début et fin
          p.dateDebut = l.dateDebut;
          p.dateFin = l.dateFin;
          return p;
        }).toList());
      }
      // On ajoute les mission du bénévole
      b.missions = pts;
      // On initialise la position du bénévole s'il a des missions
      if (b.missions.isNotEmpty) {
        b.pointActuel = b.missions[b.indexMission];
      }
    }
    return r;
  }

  Future<List<Equipe>> readAllEquipe(List<String> listeEp) async {
    /**
     * Lis toutes les équipes de la base de donnée
     *
     * result :
     *     - Future<List<Equipe>>
     */
    // La base de donnée
    final db = await instance.database;
    // Pour ordonner les résultats
    final orderBy = EquipeFields.id;
    // On récupère toutes les équipes de la base de donnée
    final result = await db.query(tableEquipe, orderBy: orderBy);
    // On transforme le résultat de la requête en liste d'équipe
    return result.map((e) => Equipe.fromJson(e, listeEp)).toList();
  }

  Future<int> updateEquipe(Equipe e) async {
    /**
     * Met à jour l'équipe
     *
     * param :
     *     - p (Point)
     *
     * result :
     *     - Future<int>
     */
    final db = await instance.database;
    return db.update(tableEquipe, e.toJson(),
        where: '${EquipeFields.id} = ?', whereArgs: [e.id]);
  }

  Future<int> updateBenevole(Benevole b) async {
    /**
     * Met à jour les informations du bénévole
     *
     * param :
     *     - b (Benevole)
     *
     * result :
     *     - Future<int>
     */
    final db = await instance.database;
    return db.update(tableBenevole, b.toJson(),
        where: '${BenevoleFields.id} = ?', whereArgs: [b.id]);
  }

  Future<int> updatePoint(Point p) async {
    /**
     * Met à jour le point
     *
     * param :
     *     - p (Point)
     *
     * result :
     *     - Future<int>
     */
    final db = await instance.database;
    return db.update(tablePoint, p.toJson(),
        where: '${PointFields.id} = ?', whereArgs: [p.id]);
  }

  Future<Benevole> createBenevole(Benevole b) async {
    /**
     * Ajoute un bénévole à la base de donnée
     *
     * pararm :
     *     - b (Benevole)
     *
     * result :
     *     - Future<Benevole>
     */
    final db = await instance.database;
    // On transforme le bénévole en dictionnaire
    final json = b.toJson();
    final id = await db.insert(tableBenevole, json);
    List<Point> points = [];
    // Pour chaque point
    for (Point p in b.missions) {
      // On lui donne un identifiant par défaut
      var Pid = 0;

      // On cherche le point dans la base de donnée
      final isIn = await db.query(tablePoint,
          where: '${PointFields.nom} = ?', whereArgs: [p.nom]);
      print(isIn);

      // On crée le lien entre un bénévole à présicer et le point
      List<Lien> liens = isIn
          .map((e) => Lien(0, e["id"] as int, p.dateDebut, p.dateFin))
          .toList();
      // On crée le lien entre le bénévole et un point à préciser
      Lien l = Lien(id, 0, p.dateDebut, p.dateFin);

      // Si le point est déjà dans la basee de donnée
      if (liens.isNotEmpty) {
        // L'identifiant est celui du premier lien
        Pid = liens[0].mission;
        // Sinon
      } else {
        // On transforme le point en dicitonnaire
        final json = p.toJson();
        Pid = await db.insert(tablePoint, json);
      }
      // On présice le point dans le lien
      l.mission = Pid;
      // On ajoute le point à la liste des points en changeant l'identifiant du point pour colle à celui dans la base de donnée
      points.add(p.copy(id: Pid));
      // On transforme le lien en dicitonnaire
      final json = l.toJson();
      await db.insert(tableLien, json);
    }
    // On met à jour le bénévole avec les missions et l'identifiant qui collent à ceux de la base de donnée
    return b.copy(id: id, missions: points);
  }

  Future<void> createEquipe(Equipe e) async {
    /**
     * Ajoute une équipe à la base de donnée
     *
     * pararm :
     *     - e (Equipe)
     *
     * result :
     *     - Future<Equipe>
     */
    // La base de donnée
    final db = await instance.database;
    // On transforme le bénévole en dictionnaire
    final json = e.toJson();
    db.insert(tableEquipe, json);
  }

  Future<bool> isNotEmpty() async {
    /**
     * Vérifie que la base de donnée n'est pas vide
     *
     * result :
     *     - Future<bool>
     */
    final db = await instance.database;
    var r = await db.rawQuery("SELECT * FROM $tableBenevole");
    return r.isNotEmpty;
  }

  Future<void> delAll() async {
    /**
     * Supprime toutes les tablee de la base de donnée
     *
     * result :
     *     - Future<void>
     */
    final db = await instance.database;
    await db.execute("DELETE FROM $tableBenevole");
    await db.execute("DELETE FROM $tableLien");
    await db.execute("DELETE FROM $tablePoint");
    await db.execute("DELETE FROM $tableEquipe");
  }
}
