import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'point.dart';
import 'benevole.dart';
import 'lienMissionsBeneveloves.dart';

// le gestionnaire de base de donnée
class DatabaseManager {
  DatabaseManager._init();

  // L'instance, l'accès pour les autres classes à la base de donnée
  static final DatabaseManager instance = DatabaseManager._init();

  // La base de donnée
  static Database _database;

  static final String filePath = 'database.db';

  // Récupère la base de donnée si elle ne l'était pas déjà
  Future<Database> get database async => _database ??= await _initDB();

  Future<Database> _initDB() async {
    /* Ouvre la base de donnée
    result :
          - Future<Database>
    */
    // On récupère le chemin vers la base de donné
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    //await deleteDatabase(path);
    // On ouvre la basse de donnée
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    /* Crée les tables dans la base de donnée
    */
    // La conversion des types dart en type SQL
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final boolType = 'BOOLEAN NOT NULL';
    final intType = 'INTEGER NOT NULL';
    final stringType = 'TEXT NOT NULL';
    final doubleType = 'REAL NOT NULL';

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
        ${PointFields.dateDebut} $stringType,
        ${PointFields.dateFin} $stringType,
        ${PointFields.numOnPoint} $intType,
        ${PointFields.pointPrec} $stringType
    );
    ''');

    // Crée la table des liens
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $tableLien (
        ${LienFields.ben} $intType,
        ${LienFields.mission} $intType
    );
    ''');
  }

  Future close() async {
    /* Ferme la base de donnée
    */
    final db = await instance.database;
    db.close();
  }

  Future<List<Benevole>> readAllBenevoles() async {
    /* Lis tous les bénévoles de la base de donnée
    result :
          - Future<List<Benevole>>
    */
    // La base de donnée
    final db = await instance.database;
    // Pour ordonner les résultats
    final orderBy = '${BenevoleFields.type} DESC';
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
        pts.addAll(respPoints.map((e) => Point.fromJson(e)).toList());
      }
      // On ajoute les mission du bénévole
      b.missions = pts;
      // On initialise la position du bénévole s'il a des missions
      if (b.missions.length > 0) {
        b.pointActuel = b.missions[b.indexMission];
      }
    }
    return r;
  }

  Future<int> updateBenevole(Benevole b) async {
    /* Met à jour les informations du bénévole
    param :
          - b (Benevole)

    result :
          - Future<int> l'identifiant du bénévole
    */
    final db = await instance.database;
    return db.update(tableBenevole, b.toJson(),
        where: '${BenevoleFields.id} = ?', whereArgs: [b.id]);
  }

  Future<Benevole> createBenevole(Benevole b) async {
    /* Ajoute un bénévole à la base de donnée
    pararm :
          - b (Benevole)

    result :
          - Future<Benevole>
    */
    final db = await instance.database;
    // On transforme le bénévole en dictionnaire
    final json = b.toJson();
    // On génère les colonnes et valeurs de la commande SQL
    final columns =
        '${BenevoleFields.nom}, ${BenevoleFields.surnom}, ${BenevoleFields.num}, ${BenevoleFields.type}, ${BenevoleFields.indexMission}, ${BenevoleFields.statusMission}';
    final values =
        '"${json[BenevoleFields.nom]}", "${json[BenevoleFields.surnom]}", "${json[BenevoleFields.num]}", ${json[BenevoleFields.type]}, ${json[BenevoleFields.indexMission]}, ${json[BenevoleFields.statusMission]}';
    // On lance la commande SQL d'ajout du bénévole
    final id = await db
        .rawInsert("INSERT INTO $tableBenevole ($columns) VALUES ($values)");
    List<Point> points = [];
    // Pour chaque point
    for (Point p in b.missions) {
      // On lui donne un identifiant par défaut
      var Pid = 0;

      // On cherche le point dans la base de donnée
      final isIn = await db.query('${tablePoint}',
          columns: ['${PointFields.id}'],
          where: '${PointFields.nom} = ?',
          whereArgs: [p.nom]);

      // On crée le lien entre un bénévole à présicer et le point
      List<Lien> liens = isIn.map((e) => Lien(0, e["id"] as int)).toList();
      // On crée le lien entre le bénévole et un point à préciser
      Lien l = Lien(id, 0);

      // Si le point est déjà dans la basee de donnée
      if (liens.length > 0) {
        // L'identifiant est celui du premier lien
        Pid = liens[0].mission;
        // Sinon
      } else {
        // On transforme le point en dicitonnaire
        final json = p.toJson();
        // On génère les colonnes et valeurs de la commande SQL
        final columns =
            '${PointFields.lat}, ${PointFields.long}, ${PointFields.nom}, ${PointFields.type}, ${PointFields.type}, ${PointFields.status}, ${PointFields.dateDebut}, ${PointFields.dateFin}, ${PointFields.numOnPoint}, ${PointFields.pointPrec}';
        final values =
            '${json[PointFields.lat]}, ${json[PointFields.long]}, "${json[PointFields.nom]}", ${json[PointFields.type]}, ${json[PointFields.type]}, ${json[PointFields.status]}, "${json[PointFields.dateDebut]}", "${json[PointFields.dateFin]}", ${json[PointFields.numOnPoint]}, "${json[PointFields.pointPrec]}"';
        // On lance la commande SQL d'ajout du point
        Pid = await db
            .rawInsert("INSERT INTO $tablePoint ($columns) VALUES ($values)");
      }
      // On présice le point dans le lien
      l.mission = Pid;
      // On ajoute le point à la liste des points en changeant l'identifiant du point pour colle à celui dans la base de donnée
      points.add(p.copy(id: Pid));
      // On transforme le lien en dicitonnaire
      final json = l.toJson();
      // On génère les colonnes et valeurs de la commande SQL
      final Pcolumns = '${LienFields.ben}, ${LienFields.mission}';
      final Pvalues = '${json[LienFields.ben]}, ${json[LienFields.mission]}';
      // On lance la commande SQL d'ajout du lien
      await db
          .rawInsert("INSERT INTO $tableLien ($Pcolumns) VALUES ($Pvalues)");
    }
    // On met à jour le bénévole avec les missions et l'identifiant qui collent à ceux de la base de donnée
    return b.copy(id: id, missions: points);
  }

  Future<bool> isNotEmpty() async {
    /* Vérifie que la base de donnée n'est pas vide
    result :
          - Future<bool>
    */
    final db = await instance.database;
    var r = await db.rawQuery("SELECT * FROM $tableBenevole");
    return r.length != 0;
  }

  Future<void> delAll() async {
    /* Supprime toutes les tablee de la base de donnée
    result :
          - Future<void>
    */
    final db = await instance.database;
    await db.execute("DELETE FROM $tableBenevole");
    await db.execute("DELETE FROM $tableLien");
    await db.execute("DELETE FROM $tablePoint");
  }

  Future<int> updatePoint(Point p) async {
    /* Met à jour la point
    param :
          - p (Point)

    result :
          - Future<int>
    */
    final db = await instance.database;
    return db.update(tablePoint, p.toJson(),
        where: '${PointFields.id} = ?', whereArgs: [p.id]);
  }
}