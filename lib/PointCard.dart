import 'dart:math';
import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'point.dart';
import 'benevole.dart';
import 'database.dart';
import 'constant.dart';
import 'customPainter.dart';

class pointCard extends StatefulWidget {
  pointCard({Key key, this.p, this.ben, this.posPoints, this.db})
      : super(key: key);

  List<Benevole> ben = [];
  DatabaseManager db;
  Point p;
  List<Point> posPoints;

  @override
  State<StatefulWidget> createState() => benCardState();
}

class benCardState extends State<pointCard> {
  Widget buildCard(Benevole e, Point p, int ind) {
    /**
     * Crée la carte avec les informations sur le bénévole donné
     *
     * param :
     *     - e (Benevole) le bénévole dont on veut afficher les informations
     *     - p (Point) le point
     *     - ind (int) l'indice du point dans la liste des points du bénévole
     *
     * result :
     *     - Widget
     */
    bool check = e.indexMission == ind;
    List<Benevole> Pben = getPointBen(p);
    // La carte du bénévole
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(25, 20, 25, 20),
        child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              color: Constants.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 5), //  changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 15,
                ),
                Text(
                  e.surnom.isNotEmpty ? e.surnom : e.nom,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Constants.darkgrad,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                Container(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 0,
                    ),
                    Container(
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 65,
                            // Le bouton personne
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  if (e.missions[e.indexMission].nom == p.nom) {
                                    update(e, p, ind, Pben, 0);
                                  }
                                });
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.times,
                                size:
                                    (!check || e.statusMission == 0) ? 45 : 40,
                                color: (!check || e.statusMission == 0)
                                    ? Constants.personne
                                    : Constants.disable,
                              ),
                            ),
                          ),
                          Container(
                            height: 0,
                          ),
                          Container(
                            width: 65,
                            child: Text(
                              "Personne",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: (!check || e.statusMission == 0)
                                      ? Constants.personne
                                      : Constants.disable,
                                  fontWeight: FontWeight.bold,
                                  fontSize: (!check || e.statusMission == 0)
                                      ? 15
                                      : 12),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 65,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  update(e, p, ind, Pben, 1);
                                });
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.mapMarkerAlt,
                                size: (check && e.statusMission == 1) ? 40 : 35,
                                color: (check && e.statusMission == 1)
                                    ? Constants.arrivee
                                    : Constants.disable,
                              ),
                            ),
                          ),
                          Container(
                            height: 0,
                          ),
                          Container(
                            width: 65,
                            child: Text(
                              "Arrivée",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: (check && e.statusMission == 1)
                                    ? Constants.arrivee
                                    : Constants.disable,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    (check && e.statusMission == 1) ? 15 : 13,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 65,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  update(e, p, ind, Pben, 2);
                                });
                              },
                              icon: FaIcon(FontAwesomeIcons.trophy,
                                  size:
                                      (check && e.statusMission == 2) ? 40 : 35,
                                  color: (check && e.statusMission == 2)
                                      ? Constants.premier
                                      : Constants.disable),
                            ),
                          ),
                          Container(
                            height: 0,
                          ),
                          Container(
                            width: 65,
                            child: Text(
                              "Premier",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: (check && e.statusMission == 2)
                                      ? Constants.premier
                                      : Constants.disable,
                                  fontWeight: FontWeight.bold,
                                  fontSize: (check && e.statusMission == 2)
                                      ? 15
                                      : 12),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 65,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  update(e, p, ind, Pben, 3);
                                });
                              },
                              icon: FaIcon(FontAwesomeIcons.stopwatch,
                                  size:
                                      (check && e.statusMission == 3) ? 40 : 35,
                                  color: (check && e.statusMission == 3)
                                      ? Constants.dernier
                                      : Constants.disable),
                            ),
                          ),
                          Container(
                            height: 0,
                          ),
                          Container(
                            width: 65,
                            child: Text(
                              "Dernier",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: (check && e.statusMission == 3)
                                      ? Constants.dernier
                                      : Constants.disable,
                                  fontWeight: FontWeight.bold,
                                  fontSize: (check && e.statusMission == 3)
                                      ? 15
                                      : 12),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 0,
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }

  void update(Benevole e, Point p, int ind, List<Benevole> Pben, int i) {
    /**
     * Met à jour les informations du bénévole, du point et du point précédent du bénévole
     *
     * param :
     *     - e (Benevole) le bénévole dont on doit changer les informations
     *     - p (Point) le point
     *     - ind (int) l'indice du point dans la liste des points du bénévole
     *     - Pben (List<Benevole>) la liste des bénévoles qui ont ce point pour mission
     *     - i (int) le nouveau status du bénévole et du point
     */
    // Le point précédent
    Point prev = findPoint(e.missions[e.indexMission].nom);
    // On enlève le bénévole du point où il était avant
    prev.numOnPoint = max(prev.numOnPoint - 1, 0);
    // On change l'index du point de la mission actuelle
    e.indexMission = ind;
    // On ajoute la personne aux personnes sur ce point
    p.numOnPoint++;
    // On change le point actuel
    e.pointActuel = p;
    // Le bénévole vient d'arriver
    e.statusMission = i;
    // Le status du point
    p.status = Pben
            // On filtre les personnes qui sont sur ce point
            .where((element) =>
                element.missions[element.indexMission].nom == p.nom)
        // On regarde leur status
        .map((element) => element.statusMission)
        // On retransforme en liste
        .toList()
        // On en prend le maximum
        .reduce(max);
    // On récupère la couleur
    p.getCol();
    List<Benevole> listPrev = getPointBen(prev)
        // On filtre les personnes qui sont sur ce point
        .where(
            (element) => element.missions[element.indexMission].nom == prev.nom)
        .toList();
    // On met à jour le status du point précédent
    prev.status = (listPrev.length > 0)
        ? listPrev
            // On regarde leur status
            .map((element) => element.statusMission)
            // On retransforme en liste
            .toList()
            // On en prend le maximum
            .reduce(max)
        : 0;
    // On récupère la couleur
    prev.getCol();
    // On met à jour le bénévole
    widget.db.updateBenevole(e);
    // On met à jour le point
    widget.db.updatePoint(p);
    // On met à jour le point précédent
    widget.db.updatePoint(prev);
  }

  Point findPoint(String nom) {
    /**
     * Renvoie le point dont le nom est donné
     *
     * param :
     *     - nom (String) le nom du point que l'on cherche
     *
     * result :
     *     - Point
     */
    // Pour chaque point
    for (Point p in widget.posPoints) {
      // Si son nom est le nom donné
      if (p.nom == nom) {
        // C'est le point que l'on cherchait
        return p;
      }
    }
    return Point.empty();
  }

  List<Benevole> getPointBen(Point p) {
    /**
     * Récupère les bénévole qui sont sur un point donné
     *
     * param :
     *     - p (Point) le point
     *
     * result :
     *     - List<Benevole>
     */
    List<Benevole> resp = [];
    // Pour chaque bénévole
    for (Benevole b in widget.ben) {
      // Pour chaque mission du bénévole
      for (Point m in b.missions) {
        // Si c'est le point qu'on cherche
        if (m.nom == p.nom) {
          // On ajoute le bénévole
          resp.add(b);
        }
      }
    }
    return resp;
  }

  @override
  Widget build(BuildContext context) {
    /**
     * Crée la page
     *
     * result :
     *     - Widget
     */
    // le point
    Point p = widget.p;
    // Le lsite des bénévoles qui ont ce point pour mission
    List<Benevole> Pben = getPointBen(p);
    // La position du point formattée pour pouvoir être copiée-collée sur Maps
    String position =
        p.lat.toStringAsFixed(6) + ", " + p.long.toStringAsFixed(6);
    return Container(
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Le fonc en haut de l'application
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
                // Espace avec le haut
                Container(
                  height: 60,
                ),
                Container(
                  height: 35,
                  // le nom du point
                  child: Text(
                    p.nom,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Constants.background,
                        fontWeight: FontWeight.w900,
                        fontSize: 35),
                  ),
                ),
                Container(
                  height: 65,
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Espace entre le nom du point
                        Container(
                          width: 20,
                        ),
                        Column(children: [
                          Container(
                            height: 45,
                          ),
                          // Les coordonnées du point
                          Text(
                            "Lat : " +
                                p.lat.toStringAsFixed(6) +
                                ", Long : " +
                                p.long.toStringAsFixed(6),
                            style: TextStyle(
                                color: Constants.background,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ]),
                        Column(children: [
                          Container(
                            height: 40,
                          ),
                          // L'icône copier-coller
                          FaIcon(
                            FontAwesomeIcons.copy,
                            size: 22,
                            color: Constants.background,
                          ),
                        ]),
                        Container(
                          width: 20,
                        ),
                      ],
                    ),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: position));
                      Toast.show("Position copiée", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    },
                  ),
                ),
                // le coin arrondi
                Container(
                    height: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          child: CustomPaint(
                            painter: CurvePainter(),
                          ),
                        ),
                      ],
                    )),
                Container(
                    height: 70,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(70)),
                      color: Colors.grey.shade100,
                    ),
                    alignment: Alignment.center,
                    child: Column(children: [
                      Container(
                        height: 35,
                      ),
                      Text(
                        "Bénévoles",
                        style: TextStyle(
                            color: Constants.darkgrad,
                            fontWeight: FontWeight.w900,
                            fontSize: 25),
                      )
                    ]))
              ],
            ),
          ),
          Column(
              children: Pben.map((e) {
            List<String> pt = e.missions.map((g) => g.nom).toList();
            int ind = pt.indexOf(p.nom);
            return buildCard(e, p, ind);
          }).toList())
        ],
      )),
    );
  }
}
