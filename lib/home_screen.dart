import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:archive/archive.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'point.dart';
import 'benCard.dart';
import 'benevole.dart';
import 'database.dart';
import 'constant.dart';
import 'bottomBar.dart';
import 'PointCard.dart';
import 'paramCard.dart';
import 'tempsCard.dart';
import 'equipe.dart';
import 'lienMissionsBeneveloves.dart';

// Le gestionnaire de toutes les pages et de la page de la carte
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // L'addresse des cartes en ligne
  final _onlineMapScheme = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
  // L'addresse des cartes hors ligne
  final offlinePartMapScheme = "{z}/{x}/{y}.png";
  // Le chemin vers les cartes hors ligne
  String _offlineMapScheme = "";
  // Le texte du bouton des cartes
  String TileText = "Charger les cartes";

  // Le numéro de la page sur laquelle on est
  int _page = 0;

  // la rotation de la carte
  double _rotation = 0.0;
  // Le zoom de la carte
  double _zoom = 15.0;

  // Si la carte est chargée
  bool _isMapReady = false;
  // Si la recherche est intialisée
  bool _searchInit = false;

  // Si la base de donnée est chargée
  bool _isDBLoaded = false;
  // Si les cartes sont chargées
  bool _isTileSetLoaded = false;

  // La liste des bénévoles recherchés
  List<Benevole> Searched = [];
  // la liste des bénévoles
  List<Benevole> ben = [];
  // Le bénévole affiché sur la page bénévole (par défaut personne)
  Benevole _selected = Benevole.empty();

  // La liste des équipes
  List<Equipe> eq = [];

  // La liste des points
  List<Point> posPoints = [];
  // Le point affiché sur la page des points (par défaut le point en (0, 0))
  Point _point = Point.empty();

  // le gestionnaire de base de donnée
  DatabaseManager dbm = DatabaseManager.instance;

  // La poisiton centrale de la carte (ECL par défaut)
  LatLng _center = LatLng(45.783218966301575, 4.768481472180009);

  // Le controlleur de carte
  MapController _mapController = MapController();

  // l'épreuve chronométrée
  String nomEpreuve = "";
  // La liste des épreuves chronométrées
  List<String> listeEpreuves = [];

  // Au lancemenent de l'application
  @override
  void initState() {
    super.initState();

    // Quand la cart est chargée, on change la valeur de _isMapReady
    _mapController.onReady.then((value) => _isMapReady = true);

    // On regarde si la base de donnée est accessible
    updateDBStatus();
    // On regarde si les cartês sont accessibles
    updateTileStatus();

    // Onrécupère tout les bénévoles de la base de donnée
    dbm.readAllBenevoles().then((value) {
      setState(() {
        // On les met dans ben
        ben = value;
        ben.sort((a, b) => b.type - a.type);

        // S'il n'y en a pas
        if (ben.isEmpty) {
          dataFromFile();
        } else {
          // On récupère les points
          posPoints = initPoints(ben);
          // Le bénévole sélectionné est le premier (La croix rouge)
          _selected = ben[0];
          // le point sélectionné est le preimer
          _point = posPoints[0];
          // Le centre est la position du premier point
          _center = _point.pos;
          // On récupère la liste des épreuves
          dbm.getEpreuve().then((value) => setState(() {
                listeEpreuves = value;
                nomEpreuve = listeEpreuves[0];
              }));
          // On récupère la liste de équipes
          dbm.readAllEquipe(listeEpreuves).then((value) => setState(() {
                eq = value;
              }));
        }
      });
    });
  }

  void dataFromFile() {
    /**
     * Génère la base de donnée à partir d'un fichier
     */
    try {
      // On demande de séléctionner le fichier de la base de donnée
      pickFile().then((r) {
        // On récupère les listes de point et bénévoles
        parseDB(r).then((value) {
          setState(() {
            // On indique que la base de donnée est chargée
            _isDBLoaded = true;
          });
          // On assigne les points, bénévoles, équipes et épreuves
          ben = value[0];
          posPoints = value[1];
          eq = value[2];
          listeEpreuves = value[3];
          if (nomEpreuve.isNotEmpty) {
            nomEpreuve = listeEpreuves[0];
          }
          // Le bénévole sélectionné est le premier (La croix rouge)
          _selected = ben[0];
          // le point sélectionné est le preimer
          _point = posPoints[0];
          // Le centre est la position du premier point
          _center = _point.pos;
          // On sauvegarde les données dans la base de donnée
          genben();
        });
      });
    } catch (e) {
      // On affiche un message
      Toast.show("Fichier incompatible", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void mapFromFile() {
    /**
     * Génère la base de donnée à partir d'un fichier
     */
    try {
      // On demande de séléctionner le fichier zip des cartes
      pickFile().then((r) {
        // On récupère les cartes
        parseMap(r);
      });
    } catch (e) {
      // On affiche un message
      Toast.show("Fichier incompatible", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void updateDBStatus() {
    /**
     * Met à jour la valeur de _isDBLoaded
     */
    // On regarde si la base de donnée n'est pas vide
    dbm.isNotEmpty().then((value) {
      setState(() => _isDBLoaded = value);
    });
  }

  void updateTileStatus() {
    /**
     * Met à jour la valeur de _isDBLoaded
     */
    // On récupère le nom du dossier des cartes
    getMapTilepath().then((value) {
      // On regarde si le dossier des cartes existe
      Directory(value).exists().then((value) => setState(() {
            // On indique si les cartes sont chargées et on change le message en conséquence
            _isTileSetLoaded = value;
            TileText = _isTileSetLoaded
                ? "Supprimer les cartes"
                : "Charger les cartes";
          }));
    });
  }

  List<Point> initPoints(List<Benevole> ben) {
    /**
     * Récupère la liste des points
     *
     * param :
     *     - ben (List<Benevole>) la liste des bénévoles
     *
     * result :
     *     - List<Point>
     */
    List<Point> resp = [];
    // On regarde les noms, car les objets peuvent avoir les mêmes données sans être égaux
    List<String> noms = [];
    // Pour chaque bénévole
    for (Benevole b in ben) {
      // Pour chaque mission
      for (Point p in b.missions) {
        // Si le point n'est pas dans la liste
        if (!noms.contains(p.nom)) {
          // On l'ajoute
          resp.add(p);
          noms.add(p.nom);
        }
      }
    }
    return resp;
  }

  void saveMap() {
    /**
     * Sauvegarde l'état de l'affichage de la carte
     */
    // Si la carte est chargée
    if (_isMapReady) {
      // On enregistre le zoom, le centre et la rotation
      _zoom = _mapController.zoom;
      _center = _mapController.center;
      _rotation = _mapController.rotation;
      // On recrée un controlleur (car on va changer de page)
      _mapController = MapController();
      // Ce controlleur n'est pas prêt pour l'instant
      _isMapReady = false;
      // On change la valeur de _isMapReady quand le controlleur est prêt
      _mapController.onReady.then((value) => _isMapReady = true);
    }
  }

  List<Polyline> getPolyLines() {
    /**
     * Crée les lignes reliant les points
     *
     * result :
     *     - List<Polyline>
     */
    List<Polyline> list = [];
    // Pour chaque point
    for (Point p in posPoints) {
      // On trouve son point précédent
      Point prec = findPoint(p.pointPrec);
      // Si ce point existe
      if (prec.nom != "") {
        // On ajoute un ligne entre ces deux points
        list.add(Polyline(
            points: [prec.pos, p.pos], strokeWidth: 3.0, color: p.col));
      }
    }
    return list;
  }

  Point findPoint(String nom) {
    /**
     * Renvoie le point dont on donne le nom
     *
     * result :
     *     - Point
     */
    // Pour chaque point
    for (Point p in posPoints) {
      // Si ce point est celui qu'on cherche
      if (p.nom == nom) {
        return p;
      }
    }
    return Point.empty();
  }

  List<Widget> buildResp(List<Benevole> lb) {
    /**
     * Renvoie la liste des widget des résultats de la recherche
     *
     * param :
     *     - lb (List<Benevole>) la liste des résultats de la recherche
     *
     * result :
     *     - List<Widget>
     */
    // S'il y des résultats
    if (lb.isNotEmpty) {
      List<Widget> resp = [];
      // Pour les N - 1 premiers résultats
      for (int i = 0; i < lb.length - 1; i++) {
        // On crée la carte du bénévole
        resp.add(getSuggestion(lb[i]));
        // On espace avec la carte suivante
        resp.add(const SizedBox(
          height: 10,
        ));
      }
      // On ajoute la carte du dernier bénévole
      resp.add(getSuggestion(lb[lb.length - 1]));
      // On retransforme en liste
      return resp.toList();
      // Sinon, la liste est vide
    } else {
      return [];
    }
  }

  Future<FilePickerResult> pickFile() async {
    /**
     * Ouvre une fenêtre d'exploration de fichier et retourne le fichier choisis
     *
     * result :
     *     - Future<FilePickerResult>
     */
    FilePickerResult result = await FilePicker.platform.pickFiles();
    // Évite les erreurs où result est null
    FilePickerResult r = result ?? const FilePickerResult([]);
    return r;
  }

  Future<List> parseDB(FilePickerResult r) async {
    /**
     * Reconstruit la base de donnée d'après le fichier donné
     *
     * param :
     *     - r (FilePickerResult) le résultat de la demande de fichier
     *
     * result :
     *     - Future<List>
     */
    // Si il y a une réponse
    if (r != null) {
      // On récupère le fichier on le lit et on le décode
      File sourceFile = File(r.files.single.path);
      final content = await sourceFile.readAsString();
      final data = await json.decode(content);
      // On crée les variabbles globales de l'application et on les renseigne
      // Les liens entre missions et points
      List<Lien> liens = [];
      for (int x = 0; x < data["lien"].length; x++) {
        // On met les dates au bon format
        data["lien"][x]["dateDebut"] = formatDate(data["lien"][x]["dateDebut"]);
        data["lien"][x]["dateFin"] = formatDate(data["lien"][x]["dateFin"]);
        // On ajoute le lien à la liste
        liens.add(Lien.fromJson(data["lien"][x]));
      }
      posPoints = [];
      // Pour chaque point
      for (int x = 0; x < data["pt"].length; x++) {
        // On l'ajoute à la liste des points
        posPoints.add(Point.fromJson(data["pt"][x]));
      }
      // La liste des bénévoles
      ben = [];
      for (int x = 0; x < data["ben"].length; x++) {
        var b = Benevole.fromJson(data["ben"][x]);
        // La liste des missions du bénévole
        List<Point> missions = [];
        // Pour cahque lien
        for (Lien l in liens) {
          // S'il concerne le bénévole
          if (l.ben == b.id) {
            // Pour chaque point
            for (Point p in posPoints) {
              // Si c'est le point du lien
              if (p.id == l.mission && b.id == l.ben) {
                // On copie le point pour éviter les alias
                Point p2 = p.copy();
                // On change les temps de début et de fin de mission en fonction du bénévole
                p2.dateDebut = l.dateDebut;
                p2.dateFin = l.dateFin;
                // On l'ajoute à la liste des missions
                missions.add(p2);
              }
            }
          }
        }
        // On assigne les missions au bénévole
        b.missions = missions;
        // Si le bénévole a des missions (tout le monde sauf le samu et les bénévoles sportifs)
        if (b.missions.isNotEmpty) {
          // On charge le point actuel
          b.pointActuel = b.missions[b.indexMission];
        }
        // On ajoute le bénévole
        ben.add(b);
      }
      // La liste des épreuves
      listeEpreuves = [];
      for (int x = 0; x < data["epreuves"].length; x++) {
        listeEpreuves.add(data["epreuves"][x] as String);
      }
      // la liste des équipes
      eq = [];
      for (int x = 0; x < data["equipe"].length; x++) {
        eq.add(Equipe.fromJson(data["equipe"][x], listeEpreuves));
      }
      return [ben, posPoints, eq, listeEpreuves];
    }
    return [[], [], [], []];
  }

  Future<void> parseMap(FilePickerResult r) async {
    /**
     * Récupère les cartes depuis le fichier .zip
     *
     * param :
     *     - r (FilePickerResult) le résultat de la demande de fichier
     *
     * result :
     *     - Future<void>
     */
    // On indique que l'on décompresse le fichier
    setState(() {
      TileText = "Décompression";
    });
    // On attend pour que le texte se mette à jour
    await Future.delayed(const Duration(microseconds: 1));
    // On lit le fichier
    final bytes = File(r.files.single.path).readAsBytesSync();
    // On récupère le dossier des cartes
    var value = await getMapTilepath();
    // On décompresse
    final archive = ZipDecoder().decodeBytes(bytes);
    // Le nombre total de fichier
    var len = archive.length;
    // Le nombre de fichier décompressés
    var x = 0;
    // Le pourcentage de fichier décompressé
    var v = (x / len * 100).round();
    // Le dernier pourcentage
    var lv = v;
    // Pour chaque fichier
    for (final file in archive) {
      // On récupère son nom
      final filename = file.name;
      // Si c'est un ficher
      if (file.isFile) {
        // On lit le fichier
        final data = file.content as List<int>;
        // On crée le fichier dans le dossier
        File(value + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        // Si c'est un dossier, on le crée
      } else {
        Directory(value + filename).create(recursive: true);
      }
      // On augmente le nombre de fichier décompressé et le pourcentage
      x++;
      v = (x / len * 100).round();
      // Si le pourcentage
      if (v != lv) {
        // On met à jour le texte
        setState(() {
          TileText = "Chargement (" + v.toString() + "%)";
        });
        // On attend pour que le texte se mette à jour
        await Future.delayed(const Duration(microseconds: 1));
        // On met à jour le dernier pourcentage
        lv = v;
      }
    }
    // Message en bas pour dire quee l'on a fini
    Toast.show("Cartes chargées", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    // On indique que la base de donnée est chargée
    setState(() {
      _isTileSetLoaded = true;
      TileText = "Supprimer les cartes";
    });
  }

  Future<String> getMapTilepath() async {
    /**
     * Récupère le chemin d'accès aux cartes
     *
     * result :
     *     - Future<String>
     */
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    return appDocDirectory.path + '/map/';
  }

  String formatDate(String dd) {
    /**
     * Transforme le texte représentant la date en un texte compréhenssible pour DateTime
     * param :
     *     - dd (String)
     *
     * result :
     *     - String, la date modifiée
     */
    var d1 = dd.split(" ")[0].split("-");
    var d2 = dd.split(" ")[1].split("-");
    return DateTime(int.parse(d1[0]), int.parse(d1[1]), int.parse(d1[2]),
            int.parse(d2[0]), int.parse(d2[1]))
        .toString();
  }

  void updateSearch(String query) {
    /**
     * Récupère les réponses potentielles à la recherche
     *
     * param :
     *     - query (String) la recherche
     */
    // Si la recherche est vide, toute réponse convient
    if (query.isEmpty) {
      setState(() {
        // la liste des réponses est alors la liste entières des bénévoles
        Searched = ben;
      });
      // Sinon
    } else {
      // On met la recherche en minuscule pour simplifier le filtrage des bénévoles
      String q = query.toLowerCase();
      setState(() {
        // On ne met dans Searched uniquement les bénévoles qui vérifient une des conditions:
        Searched = ben
            .where((b) =>
                // La recherche contient le nom
                b.nom.toLowerCase().contains(q) ||
                // La recherche contient le surnom
                b.surnom.toLowerCase().contains(q) ||
                // La recherche contient le point où est le bénévole
                b.pointActuel.nom.toLowerCase().contains(q) ||
                // La recherche contient le racourci de recherche
                b.isType(q))
            .toList();
      });
    }
  }

  void genben() async {
    /**
     * Génère la base de donnée
     */
    // Pour chaque bénévole
    for (Benevole b in ben) {
      // On l'ajoute à la base de donnée
      await dbm.createBenevole(b);
    }
    // On crée la table dans la base de donnée
    dbm.createEquipetable(eq[0]);
    // Pour chaque équipe
    for (Equipe e in eq) {
      // On l'ajoute à la base de donnée
      await dbm.createEquipe(e);
    }
  }

  Widget buildFloatingSearchBar() {
    /**
     * Crée la barre de recherche
     *
     * result :
     *     - Widget
     */
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Rechercher bénévole',
      hintStyle: const TextStyle(color: Constants.text),
      backgroundColor: Constants.background,
      accentColor: Constants.darkgrad,
      scrollPadding: const EdgeInsets.only(top: 20, bottom: 60),
      transitionDuration: const Duration(milliseconds: 500),
      transitionCurve: Curves.ease,
      clearQueryOnClose: true,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      // Quand on clique sur la barre (sans avoir fait de recherche avant)
      onFocusChanged: (e) {
        if (!_searchInit) {
          updateSearch("");
          setState(() {
            // On trie les bénévoles par type
            //ben.sort((a, b) => b.type - a.type);
            _searchInit = true;
          });
        }
      },
      borderRadius: BorderRadius.circular(10),
      // Quand on fait une recherche
      onQueryChanged: (query) {
        updateSearch(query);
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(
              FontAwesomeIcons.userAlt,
              color: Constants.darkgrad,
            ),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Material(
              color: Colors.transparent,
              elevation: 4.0,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: buildResp(Searched)),
            ));
      },
    );
  }

  Widget getSuggestion(Benevole b) {
    /**
     * Crée la carte de bénévole
     *
     * param :
     *     - b (Benevole) le bénévole dont on veut crée la carte
     *
     * restult :
     *     - Widget
    */
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Constants.background,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.9),
              spreadRadius: 5,
              blurRadius: 20,
              offset: const Offset(0, 15), // changes position of shadow
            ),
          ]),
      // Quand on clique sur la carte
      child: InkWell(
          onTap: () {
            setState(() {
              // On est redirigé vers la page bénévole avec le bénévole choisi
              _selected = b;
              _page = 1;
            });
          },
          splashColor: Colors.green.shade200,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 100,
            child: Row(
              children: [
                SizedBox(
                    width: 100,
                    // On affiche l'icône en fonction du type de bénévole
                    child: Center(
                      child: FaIcon(
                        b.getIcon(),
                        // la couleur change avec le type de bénévole
                        color:
                            b.type < 4 ? Constants.lightgrad : Constants.samu,
                        size: 55,
                      ),
                    )),
                Expanded(
                  // l'identité
                  child: b.surnom.isNotEmpty
                      // Si le bénévole a un surnom
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // On affiche le surnom
                            Text(
                              b.surnom,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Constants.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            ),
                            // On espace le surnom du nom
                            const SizedBox(
                              height: 8,
                            ),
                            // On affiche le nom
                            Text(
                              b.nom,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Constants.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        )
                      // Sinon, on affiche que le nom
                      : Text(
                          b.nom,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Constants.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                ),
                // On affiche le point sur lequel le bénévole est actuellement
                SizedBox(
                    width: 110,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 90,
                          child: Text(
                            b.pointActuel.nom,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Constants.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ))),
              ],
            ),
          )),
    );
  }

  Widget _getBody() {
    /**
     * Renvoie la page sur laquelle on est
     *
     * result :
     *     - Widget
     */
    // Si on est sur la page bénévole
    if (_page == 1) {
      return getBenPage();
      // Si on est sur la page point
    } else if (_page == 2) {
      return getPointPage();
      // Si on est sur la page des paramètres
    } else if (_page == 3) {
      return getParamPage();
    } else if (_page == 4) {
      return getTempsPage();
    }
    // Sinon, on est sur la page de la carte
    return getMapPage();
  }

  Widget getBenPage() {
    /**
     * Génère la page d'un bénévole
     *
     * result :
     *     - Widget
     */
    // On sauvegarde les pararmètres de la carte
    setState(() {
      saveMap();
    });
    // On envoie sur la page du bénévole
    return benCard(b: _selected);
  }

  Widget getPointPage() {
    /**
     * Génère la page d'un point
     *
     * result :
     *     - Widget
     */
    // On sauvegarde les pararmètres de la carte
    setState(() {
      saveMap();
    });
    // On envoie sur la page du point
    return pointCard(p: _point, ben: ben, posPoints: posPoints, db: dbm);
  }

  Widget getMapPage() {
    /**
     * Génère la page de la carte
     *
     * result :
     *     - Widget
     */
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // On superpose la carte et la barre de recherche
      body: Stack(
    fit: StackFit.expand,
    children: [
      _buildMap(),
      buildFloatingSearchBar(),
    ],
      ),
    );
  }

  Widget getParamPage() {
    /**
     * Génère la page des paramètres
     *
     * result :
     *     - Widget
     */
    setState(() {
      // On sauvegarde les pararmètres de la carte
      saveMap();
    });
    // On envoie sur la page des paramètres
    return paramCard(
      isDBLoaded: _isDBLoaded,
      isTileSetLoaded: _isTileSetLoaded,
      delDB: () {
        dbm.delAll();
        setState(() {
          // On assigne les points et bénévole
          ben = [];
          posPoints = [];
          // Le bénévole sélectionné est le premier (La croix rouge)
          _selected = Benevole.empty();
          // On indique que la base de donnée n'est pas chargée
          _isDBLoaded = false;
        });
      },
      delMap: () {
        try {
          // On récupère le chemin d'accés au dossier des cartes
          getMapTilepath().then((value) {
            // On suprime le dossier
            Directory(value).deleteSync(recursive: true);
            // On indique que les cartes ne sont pas chargées
            setState(() {
              _isTileSetLoaded = false;
              TileText = "Charger les cartes";
            });
          });
          // En cas d'erreur
        } catch (e) {
          setState(() {
            // On indique que les cartes ne sont pas chargées
            _isTileSetLoaded = false;
            TileText = "Charger les cartes";
          });
        }
      },
      addDB: () {
        dataFromFile();
      },
      addMap: () {
        mapFromFile();
      },
      TileText: TileText,
    );
  }

  Widget getTempsPage() {
    /**
     * Génère la page des temps des participants
     *
     * result :
     *     - Widget
     */
    // On sauvegarde les pararmètres de la carte
    setState(() {
      saveMap();
    });
    // On envoie sur la page du point
    return tempsCard(
      eq: eq,
      nomEpreuve: nomEpreuve,
      epreuves: listeEpreuves,
      db: dbm,
    );
  }

  Widget getBottomBar() {
    /**
     * Génère la barre de navigation en bas
     *
     * result :
     *     - Widget
     */
    return BottomNavBarFb5(
      l: [
        // La page de la carte
        IconBottomBar(
          text: "Carte",
          icon: FontAwesomeIcons.mapMarkedAlt,
          onPressed: () {
            setState(() {
              _page = 0;
            });
          },
          selected: _page == 0,
        ),
        // La page des bénévoles
        IconBottomBar(
          text: "Bénévole",
          icon: FontAwesomeIcons.userAlt,
          onPressed: () {
            setState(() {
              _page = 1;
            });
          },
          selected: _page == 1,
        ),
        // La page des points
        IconBottomBar(
          text: "Points",
          icon: FontAwesomeIcons.mapMarkerAlt,
          onPressed: () {
            setState(() {
              _page = 2;
            });
          },
          selected: _page == 2,
        ),
        // La page des temps
        IconBottomBar(
          text: "Temps",
          icon: FontAwesomeIcons.stopwatch,
          onPressed: () {
            setState(() {
              _page = 4;
            });
          },
          selected: _page == 4,
        ),
        // la page des paramètres
        IconBottomBar(
          text: "Paramètres",
          icon: FontAwesomeIcons.cog,
          onPressed: () {
            setState(() {
              _page = 3;
            });
          },
          selected: _page == 3,
        ),
      ],
    );
  }

  FlutterMap _buildMap() {
    /**
     * Crée la carte, les points et les lignes
     *
     * result :
     *     - FlutterMap (Widget)
     */
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        maxZoom: 17,
        minZoom: 8,
        // On met les paramètres de sorte à se retrouver avec la carte dans la même état que quand on est partit
        zoom: _zoom,
        center: _center,
        rotation: _rotation,
      ),
      layers: [
        _isTileSetLoaded
            // La carte hors ligne
            ? TileLayerOptions(
                urlTemplate: _offlineMapScheme,
                tileProvider: const FileTileProvider(),
              )
            // La carte en ligne
            : TileLayerOptions(
                urlTemplate: _onlineMapScheme,
                subdomains: ['a', 'b', 'c'],
              ),
        // On affiche les lignes
        PolylineLayerOptions(polylines: getPolyLines()),
        // On affiche les points
        MarkerLayerOptions(markers: _buildMarkersOnMap()),
      ],
    );
  }

  List<Marker> _buildMarkersOnMap() {
    /**
     * Crée les points sur la carte
     *
     * result :
     *     - List<Marker>
     */
    // On itère sur chaque point
    return posPoints
        .map((x) => Marker(
            point: x.pos,
            width: 80.0,
            // Les points importants sont plus gros
            height: x.type == 0 ? 115.0 : 135,
            builder: (context) => GestureDetector(
                onTap: () {
                  // Si on clique sur un point, on est redirigé vers la page des points avec le point choisis
                  setState(() {
                    _page = 2;
                    _point = x;
                  });
                },
                child: Column(
                  children: [
                    Center(
                      // On affiche le nom du point
                      child: Text(
                        x.nom,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: x.col,
                            fontWeight: FontWeight.w900,
                            // Les points importants sont plus gros
                            fontSize: x.type == 0 ? 12 : 15),
                      ),
                    ),
                    // On affiche l'icône du point, qui dépend du type du point
                    x.type == 0
                        // Si c'est un point classique
                        ? FaIcon(FontAwesomeIcons.mapMarkerAlt,
                            color: x.col, size: 42.0)
                        // Si c'est un point principal, on affiche le logo du Raid
                        : Stack(children: [
                            Center(
                              child: FaIcon(FontAwesomeIcons.mapMarker,
                                  color: Colors.grey.shade100, size: 50.0),
                            ),
                            Center(
                                child: Column(
                              children: [
                                Container(
                                  height: 5,
                                ),
                                Image.asset(
                                  'assets/images/logo.png',
                                  height: 27,
                                  width: 27,
                                ),
                              ],
                            ))
                          ])
                  ],
                ))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    /**
     * Crée la page principale
     *
     * result :
     *     - Widget
     */
    // On crée le chemin vers le dossier des cartes
    getMapTilepath().then((value) {
      _offlineMapScheme = value + offlinePartMapScheme;
    });
    return Scaffold(
        // This is handled by the search bar itself.
        resizeToAvoidBottomInset: false,
        // On récupère la page sélectionnée
        body: _getBody(),
        // La liste des boutons de la barre de navigation
        bottomNavigationBar: getBottomBar());
  }
}
