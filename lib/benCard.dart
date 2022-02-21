import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'benevole.dart';
import 'constant.dart';
import 'customPainter.dart';

class benCard extends StatefulWidget {
  Benevole b;

  benCard({
    Key key,
    this.b,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => benCardState();
}

class benCardState extends State<benCard> {
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();

    // On fait défiler la listes des missions pour mettre au centre la mission en cours
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController
          .jumpTo((widget.b.indexMission - 1) * 146.toDouble() + 43.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    /**
     * Créer la page bénévole
     *
     * param :
     *     - context (BuildContext)
     *
     * result :
     *     - Container (Widget)
     */
    Benevole b = widget.b;
    return Container(
        color: Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // L'image du fonc en haut de la page
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/backgroundtest.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 60,
                  ),
                  // Le surnom du bénévole
                  (b.surnom.isNotEmpty)
                      // Si il a un surnom
                      ? Container(
                          height: 55,
                          child: Text(
                            b.surnom,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Constants.background,
                                fontWeight: FontWeight.w900,
                                fontSize: 35),
                          ),
                        )
                      // Si il n'en a pas
                      : Container(
                          height: 55,
                        ),
                  // Le nom du bénévole
                  Container(
                    height: 45,
                    child: Text(
                      b.nom,
                      style: TextStyle(
                          color: Constants.background,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  // Le numéro du bénévole
                  Container(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          // L'arrondi en haut à droite
                          child: CustomPaint(
                            painter: CurvePainter(),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              b.num,
                              style: TextStyle(
                                  color: Constants.background,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ],
                        ),
                        Container(
                          width: 70,
                        ),
                      ],
                    )
                  ),
                  // L'arrondi en haut à gauche
                  Container(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(70)),
                      color: Colors.grey.shade100,
                    ),
                    alignment: Alignment.center,
                    child: // Le texte pour les missions
                      b.missions.length > 0
                      // Si le bénévole a des missions
                      ? Column(children: [
                          Container(
                            height: 35,
                          ),
                          Text(
                            "Missions",
                            style: TextStyle(
                                color: Constants.darkgrad,
                                fontWeight: FontWeight.w900,
                                fontSize: 25),
                          )
                        ])
                      // Sinon
                      : Container(),
                  )
                ],
              ),
            ),
            Container(
              height: 20,
            ),
            // Le conteneur de la liste des missions qui s'étend sur toute la hauteur possible
            Expanded(
                // Le défilement dans la largeur
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    controller: _scrollController,
                    child: Container(
                      alignment: Alignment.center,
                      // la liste des misisons
                      child: Row(children: buildMissions(b, _scrollController)),
                    )),
            ),
            // Les deux boutons sont contenues dans une ligne
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Un conteneur pour espacer proprement les boutons
                Container(),
                // Le bouton sms
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: Constants.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 5), //  changes position of shadow
                      ),
                    ],
                  ),
                  child:
                    IconButton(
                    onPressed: () {
                      Action("sms", b.num);
                    },
                    icon: FaIcon(
                      Icons.message_rounded,
                      color: Constants.darkbtn,
                      size: 55,
                    )
                  )
                ),
                // Fixe la hauteur de la ligne
                Container(
                  height: 150,
                  width: 20,
                ),
                // Le bouton téléphone
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: Constants.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 5), //  changes position of shadow
                      ),
                    ],
                  ),
                  child: IconButton(
                      onPressed: () {
                        Action('tel', b.num);
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.phoneAlt,
                        color: Constants.darkbtn,
                        size: 55,
                      )),
                ),
                // Un autre conteneur pour espacer proprement les boutons
                Container(),
              ],
            )
          ],
        ));
  }

  void Action(String action, String num) async {
    /**
     * Lance soit la messagerie soit l'appel avec le numéro donné
     *
     * param :
     *      - action ("tel" / "sms") (String)
     *      - num (String)
     */
    await launch(action + ':+' + num);
  }

  List<Widget> buildMissions(Benevole b, ScrollController _scrollController) {
    /**
     *  Créer la liste des missions du bénévole
     *
     * param :
     *     - b (Benevole) le bénévole dont on veut afficher les missions
     *     - _scrollController (ScrollController) le controlleur de défilement de la liste des missions
     *
     * result :
     *     - list(Widget)
     */
    return b.missions
        // On transforme la liste en dictionnaire pour récupérer l'index de chaque mission
        .asMap()
        // On applique la transformation suivante à tous les éléments du dictionnaire
        .map((i, e) => MapEntry(
            i,
            // Le conteneur d'une mission
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topLeft,
                  // On change la couleur en focntion de si cette mission est la mission en cours
                  colors: i == b.indexMission
                      ? [Constants.darkgrad, Constants.lightgrad]
                      : [Constants.background, Constants.background],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 5), //  changes position of shadow
                  ),
                ],
              ),
              height: 150,
              width: 106,
              child: Column(
                children: [
                  Container(
                    height: 50,
                  ),
                  // Le nom de la mission (le nom du point)
                  Container(
                    height: 30,
                    child: Text(
                      e.nom,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          // On change la couleur en fonction de si cette mission est la mission en cours
                          color: i == b.indexMission
                              ? Constants.background
                              : Constants.darkgrad,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  // L'heure de début et de fin de la mission
                  Container(
                    height: 30,
                    child: Text(
                      e.dateDebut.hour.toString() +
                          "h" +
                          e.dateDebut.minute.toString() +
                          " - " +
                          e.dateFin.hour.toString() +
                          "h" +
                          e.dateFin.minute.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          // On change la couleur en fonction de si cette mission est la mission en cours
                          color: i == b.indexMission
                              ? Constants.background
                              : Constants.lightgrad,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ),
                  )
                ],
              ),
            )))
        .values
        // On remet tout sous la forme d'une liste
        .toList();
  }
}

