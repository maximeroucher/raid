import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:connectivity/connectivity.dart';
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
import 'connection.dart';
import 'lienMissionsBeneveloves.dart';

// Le gestionnaire de toutes les pages et de la page de la carte
class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // L'addresse des cartes en ligne
  final _onlineMapScheme = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
  // L'addresse des cartes hors ligne
  final _offlineMapScheme = "assets/Tiles/{z}-{x}-{y}.png";

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
  // Si on peut quitter l'application avec le bouton retour
  bool _canback = false;

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

  // La liste des points
  List<Point> posPoints = [];
  // Le point affiché sur la page des points (par défaut le point en (0, 0))
  Point _point = Point.empty();

  // le gestionnaire de base de donnée
  DatabaseManager dbm = DatabaseManager.instance;

  // La poisiton centrale de la carte (ECL par défaut)
  LatLng _center = LatLng(45.783218966301575, 4.768481472180009);

  // la connectivité TODO: opti carte (ie jamais co)
  final MyConnectivity _connectivity = MyConnectivity.instance;

  // Le controlleur de carte
  MapController _mapController = MapController();
  // L'état de connection (Wi-Fi, réseau, rien) TODO: à f disparaitre
  Map _source = {ConnectivityResult.none: false};

  // Quand on quitte l'appliaction
  @override
  void dispose() {
    // On arrête de regarder si on est connecté
    _connectivity.disposeStream();
    super.dispose();
  }

  // Au lancemenent de l'application
  void initState() {
    super.initState();

    // Quand la cart est chargée, on change la valeur de _isMapReady
    _mapController.onReady.then((value) => _isMapReady = true);

    // On lance la vérification de la connection
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      // On met à jour létat de connection quand il change
      setState(() => _source = source);
    });

    // On regarde si la base de donnée est accessible
    updateDBStatus();
    // On regarde si les cartês sont accessibles
    updateTileStatus();

    // Onrécupère tout les bénévoles de la base de donnée
    dbm.readAllBenevoles().then((value) {
      setState(() {
        // On les met dans ben
        ben = value;
        // S'il n'y en a pas
        if (ben.length == 0) {
          dataFromFile();
        } else {
          // On récupère les points
          posPoints = InitPoints(ben);
          // Le bénévole sélectionné est le premier (La croix rouge)
          _selected = ben[0];
          // le point sélectionné est le preimer
          _point = posPoints[0];
          // Le centre est la position du premier point
          _center = _point.pos;
        }
      });
    });
  }

  void dataFromFile() {
    //TODO: vérif bon fichier
    /* Génère la base de donnée à partir d'un fichier
    */
    // On demande de séléctionner le fichier de la base de donnée
    pickFile().then((r) {
      // On récupère les listes de point et bénévoles
      parseDB(r).then((value) {
        setState(() {
          // On indique que la base de donnée est chargée
          _isDBLoaded = true;
        });
        // On assigne les points et bénévole
        ben = value[0];
        posPoints = value[1];
        // Le bénévole sélectionné est le premier (La croix rouge)
        _selected = ben[0];
        // le point sélectionné est le preimer
        _point = posPoints[0];
        // Le centre est la position du premier point
        _center = _point.pos;
        // On sauvegarde les données dans la base de donnée
        Genben();
      });
    });
  }

  void updateDBStatus() {
    /* Met à jour la valeur de _isDBLoaded
    */
    // regarde si la base de donnée n'est pas vide
    dbm.isNotEmpty().then((value) {
      setState(() => _isDBLoaded = value);
    });
  }

  void updateTileStatus() async {
    /* Met à jour la valeur de _isDBLoaded
    */
    // On cherche un fichier en particulier
    var path = "assets/Tiles/0.txt";
    setState(() {
      // Si on le trouve
      try {
        rootBundle.loadString(path).then((value) => _isTileSetLoaded = true);
        // Sinon
      } catch (e) {
        _isTileSetLoaded = false;
      }
    });
  }

  List<Point> InitPoints(List<Benevole> ben) {
    /* Récupère la liste des points
    param :
          - ben (List<Benevole>) la liste des bénévoles

    result :
          - List<Point>
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

  void SaveMap() {
    /* Sauvegarde l'état de l'affichage de la carte
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
    /* Crée les lignes reliant les points
    result :
          - List<Polyline>
    */
    List<Polyline> list = [];
    // Pour chaque point
    for (Point p in posPoints) {
      // On trouve son point précédent
      Point prec = findPoint(p.pointPrec);
      // Si ce point existe
      if (prec.nom != "") {
        // On ajoute un ligne entre ces deux points
        list.add(new Polyline(
            points: [prec.pos, p.pos], strokeWidth: 3.0, color: p.col));
      }
    }
    return list;
  }

  Point findPoint(String nom) {
    /* Renvoie le point dont on donne le nom
    result :
          - Point
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
    /* Renvoie la liste des widget des résultats de la recherche
    param :
          - lb (List<Benevole>) la liste des résultats de la recherche

    result :
          - List<Widget>
    */
    // S'il y des résultats
    if (lb.length > 0) {
      List<Widget> resp = [];
      // Pour les N - 1 premiers résultats
      for (int i = 0; i < lb.length - 1; i++) {
        // On crée la carte du bénévole
        resp.add(getSuggestion(lb[i]));
        // On espace avec la carte suivante
        resp.add(SizedBox(
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
    /* Ouvre une fenêtre d'exploration de fichier et retourne le fichier choisis TODO:
    */
    FilePickerResult result = await FilePicker.platform.pickFiles();
    FilePickerResult r = result ?? FilePickerResult([]);
    return r;
  }

  Future<List> parseDB(FilePickerResult r) async {
    /* Reconstruit la base de donnée d'après le fichier donné
    param :
          - r (FilePickerResult) le résultat de la demande de fichier
    */
    // Si il y a une réponse
    if (r != null) {
      // On récupère le fichier on le lit et on le décode
      File sourceFile = File(r.files.single.path);
      final content = await sourceFile.readAsString();
      final data = await json.decode(content);
      // On crée les variabbles globales de l'application et on les renseigne
      posPoints = [];
      // Pour chaque point
      for (int x = 0; x < data["pt"].length; x++) {
        // On met les dates au bon format
        data["pt"][x]["dateDebut"] = formatDate(data["pt"][x]["dateDebut"]);
        data["pt"][x]["dateFin"] = formatDate(data["pt"][x]["dateFin"]);
        // On l'ajoute à la liste des points
        posPoints.add(Point.fromJson(data["pt"][x]));
      }
      // Les liens entre missions et points
      List<Lien> liens = [];
      for (int x = 0; x < data["lien"].length; x++) {
        liens.add(Lien.fromJson(data["lien"][x]));
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
              if (p.id == l.mission) {
                // On l'ajoute à la liste des missions
                missions.add(p);
              }
            }
          }
        }
        b.missions = missions;
        ben.add(b);
      }
      return [ben, posPoints];
    }
    return [];
  }

  String formatDate(String dd) {
    /* Transforme le texte représentant la date en un texte compréhenssible pour DateTime
    param :
          - dd (String)

    result :
          - (String) la date modifiée
    */
    var d1 = dd.split(" ")[0].split("-");
    var d2 = dd.split(" ")[1].split("-");
    return DateTime(int.parse(d1[0]), int.parse(d1[1]), int.parse(d1[2]),
            int.parse(d2[0]), int.parse(d2[1]))
        .toString();
  }

  void updateSearch(String query) {
    /* Récupère les réponses potentielles à la recherche
    param :
          - query (String) la recherche
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

  void Genben() async {
    /* Génère la base de donnée
    */
    // Pour chaque bénévole
    for (Benevole b in ben) {
      // On l'ajoute à la base de donnée
      await dbm.createBenevole(b);
    }
  }

  Future<bool> _onWillPop() async {
    /* La fonction de retour (se lance quand on appuie sur le bouton retour du téléphone)
    */
    // Si on peut quitter l'application
    if (_canback) {
      // On la quitte
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      // Sinon
    } else {
      // On retourne sur la première page
      setState(() {
        _page = 0;
      });
    }
    // Pendant les 800 millisecondes suivantes, si on refait la même action, on quitte l'application
    Timer(Duration(milliseconds: 800), () {
      setState(() {
        _canback = false;
      });
    });
    _canback = true;
  }

  Widget buildFloatingSearchBar() {
    /* Crée la barre de recherche
    result :
          - FloatingSearchBar(Widget)
    */
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Rechercher bénévole',
      hintStyle: TextStyle(
        color: Constants.text
      ),
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
            ben.sort((a, b) => b.type - a.type);
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
            icon: Icon(
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
    /* Crée la carte de bénévole
    param :
          - b (Benevole) le bénévole dont on veut crée la carte

    restult :
          - Container(Widget)
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
              offset: Offset(0, 15), // changes position of shadow
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
          child: Container(
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
                      color: b.type < 4 ? Constants.lightgrad : Constants.samu,
                      size: 55,
                    ),
                  )
                ),
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
                              style: TextStyle(
                                  color: Constants.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            ),
                            // On espace le surnom du nom
                            SizedBox(
                              height: 8,
                            ),
                            // On affiche le nom
                            Text(
                              b.nom,
                              textAlign: TextAlign.left,
                              style: TextStyle(
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
                          style: TextStyle(
                              color: Constants.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                ),
                // On affiche le point sur lequel le bénévole est actuellement
                Container(
                    width: 110,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 90,
                          child: Text(
                            b.pointActuel.nom,
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
    /* Renvoie la page sur laquelle on est
    result :
          - Container(Widget)
    */
    // Si on est sur la page bénévole
    if (_page == 1) {
      // On sauvegarde les pararmètres de la carte
      setState(() {
        SaveMap();
      });
      // On envoie sur la page du bénévole
      return benCard(b: _selected);
      // Si on est sur la page point
    } else if (_page == 2) {
      // On sauvegarde les pararmètres de la carte
      setState(() {
        SaveMap();
      });
      // On envoie sur la page du point
      return pointCard(
          p: _point,
          ben: ben,
          posPoints: posPoints,
          db: dbm);
      // Si on est sur la page des paramètres
    } else if (_page == 3) {
      setState(() {
        // On sauvegarde les pararmètres de la carte
        SaveMap();
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
            // le point sélectionné est le preimer
            _point = Point.empty();
            // Le centre est la position du premier point
            _center = _point.pos;
            // On indique que la base de donnée n'est pas chargée
            _isDBLoaded = false;
          });
        },
        delMap: () {},
        addDB: () {
          dataFromFile();
        },
        addMap: () {},
      );
    }
    // Sinon, on est sur la page de la carte
    return Container(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      // On superpose la carte et la barre de recherche
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildMap(),
          buildFloatingSearchBar(),
        ],
      ),
    ));
  }

  FlutterMap _buildMap() {
    /* Crée la carte, les points et les lignes
    result :
          - FlutterMap(Widget)
    */
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        // On met les paramètres de sorte à se retruver avec la carte dans la même état que quand on est partit
        zoom: _zoom,
        center: _center,
        rotation: _rotation,
      ),
      layers: [
        // On affiche la carte
        TileLayerOptions(
            urlTemplate: _onlineMapScheme, subdomains: ['a', 'b', 'c']
            /*_source.keys.toList()[0] == ConnectivityResult.none
              ? TileLayerOptions(
                  tileProvider: AssetTileProvider(),
                  urlTemplate: _offlineMapScheme,
                )
              : TileLayerOptions(
                  urlTemplate: _onlineMapScheme, subdomains: ['a', 'b', 'c']*/
            /*'https://api.mapbox.com/styles/v1/khurzs/ckw90kcczdmh514pcmhg6rdnm/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia2h1cnpzIiwiYSI6ImNrdzkwOXR2ZzFxdWMyeW1lMWNlYmZvMnEifQ.4Uy-gUkzVk0q1BXlQ8aHwA',
          additionalOptions: {
            'accessToken':
        mapController: mapController,
                'sk.eyJ1Ijoia2h1cnpzIiwiYSI6ImNrdzkxaWxuMTFxeHYyeG1lMXppdTk4djEifQ.Iof7IMiW2Ucnv7SGKlBW3Q',
            'id': 'mapbox.mapbox-streets-v8'
          }*/
            ),
        // On affiche les lignes
        PolylineLayerOptions(polylines: getPolyLines()),
        // On affiche les points
        MarkerLayerOptions(markers: _buildMarkersOnMap()),
      ],
    );
  }

  List<Marker> _buildMarkersOnMap() {
    /* Crée les points sur la carte
    result :
          - List<Marker>
    */
    // On itère sur chaque point
    return posPoints
        .map((x) => new Marker(
            point: x.pos,
            width: 80.0,
            height: 145.0,
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
                            fontSize: 15),
                      ),
                    ),
                    // On affiche l'icône du point, qui dépend du type du point
                    x.type == 0
                        // Si c'est un point classique
                        ? Icon(Icons.location_pin, color: x.col, size: 60.0)
                        // Si c'est un point principal
                        : Image.asset(
                            'assets/images/ic_marker.png',
                            height: 60,
                            width: 60,
                          ),
                  ],
                ))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    /* Crée la page principale
    */
    return WillPopScope(
        child: Scaffold(
            // This is handled by the search bar itself.
            resizeToAvoidBottomInset: false,
            // On récupère la page sélectionnée
            body: _getBody(),
            //appBar: _buildAppBar(context),
            // La liste des boutons de la barre de navigation
            bottomNavigationBar: BottomNavBarFb5(
              l: [
                IconBottomBar(
                  text: "Carte",
                  icon: FontAwesomeIcons.map,
                  onPressed: () {
                    setState(() {
                      _page = 0;
                    });
                  },
                  selected: _page == 0,
                ),
                IconBottomBar(
                  text: "Bénévole",
                  icon: FontAwesomeIcons.listUl,
                  onPressed: () {
                    setState(() {
                      _page = 1;
                    });
                  },
                  selected: _page == 1,
                ),
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
                IconBottomBar(
                  text: "Paramètres",
                  icon: FontAwesomeIcons.cog,
                  onPressed: () {
                    setState(() {
                      _page = 3;
                    });
                  },
                  selected: _page == 3,
                )
              ],
            )),
        // Quand on veut quitter l'application avec le bouton retour
        //onWillPop: _onWillPop
      );
  }
}