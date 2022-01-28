import 'dart:math';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';

import 'point.dart';
import 'benevole.dart';
import 'database.dart';
import 'constant.dart';

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
  Widget buildCard(Benevole e, Point p, int ind, int k) {
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
                  spreadRadius: 1,
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
                      color: Constants.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                                    // Le point précédent
                                    Point prev =
                                        findPoint(e.missions[e.indexMission].nom);
                                    // On enlève le bénévole du point où il était avant
                                    prev.numOnPoint = max(prev.numOnPoint - 1, 0);
                                    // On change l'index du point de la mission actuelle
                                    e.indexMission = ind;
                                    // On ajoute la personne aux personnes sur ce point
                                    p.numOnPoint++;
                                    // On change le point actuel
                                    e.pointActuel = p;
                                    // Le bénévole vient d'arriver
                                    e.statusMission = 0;
                                    // Le status du point
                                    p.status = Pben
                                      // On filtre les personnes qui sont sur ce point
                                      .where((element) => element.missions[element.indexMission].nom == p.nom)
                                      // On regarde leur status
                                      .map((e) => e.statusMission)
                                      // On retransforme en liste
                                      .toList()
                                      // On en prend le maximum
                                      .reduce(max);
                                    // On récupère la couleur
                                    p.getCol();
                                    // On met à jour le status du point précédent
                                    prev.status = getPointBen(prev)
                                      // On filtre les personnes qui sont sur ce point
                                      .where((element) => element.missions[element.indexMission].nom == prev.nom)
                                      // On regarde leur status
                                      .map((e) => e.statusMission)
                                      // On retransforme en liste
                                      .toList()
                                      // On en prend le maximum
                                      .reduce(max);
                                    // On récupère la couleur
                                    prev.getCol();
                                    // On met à jour le bénévole
                                    widget.db.updateBenevole(e);
                                    // On met à jour le point
                                    widget.db.updatePoint(p);
                                    // On met à jour le point précédent
                                    widget.db.updatePoint(prev);
                                  }
                                });
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.times,
                                size: (!check || e.statusMission == 0) ? 40 : 35,
                                color: Constants.text,
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
                                  color: Constants.text,
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
                                  // Le point précédent
                                  Point prev =
                                      findPoint(e.missions[e.indexMission].nom);
                                  // On enlève le bénévole du point où il était avant
                                  prev.numOnPoint = max(prev.numOnPoint - 1, 0);
                                  // On change l'index du point de la mission actuelle
                                  e.indexMission = ind;
                                  // On ajoute la personne aux personnes sur ce point
                                  p.numOnPoint++;
                                  // On change le point actuel
                                  e.pointActuel = p;
                                  // Le bénévole vient d'arriver
                                  e.statusMission = 1;
                                  // Le status du point
                                  p.status = Pben
                                    // On filtre les personnes qui sont sur ce point
                                    .where((element) => element.missions[element.indexMission].nom == p.nom)
                                    // On regarde leur status
                                    .map((e) => e.statusMission)
                                    // On retransforme en liste
                                    .toList()
                                    // On en prend le maximum
                                    .reduce(max);
                                  // On récupère la couleur
                                  p.getCol();
                                  // On met à jour le status du point précédent
                                  prev.status = getPointBen(prev)
                                    // On filtre les personnes qui sont sur ce point
                                    .where((element) => element.missions[element.indexMission].nom == prev.nom)
                                    // On regarde leur status
                                    .map((e) => e.statusMission)
                                    // On retransforme en liste
                                    .toList()
                                    // On en prend le maximum
                                    .reduce(max);
                                  // On récupère la couleur
                                  prev.getCol();
                                  // On met à jour le bénévole
                                  widget.db.updateBenevole(e);
                                  // On met à jour le point
                                  widget.db.updatePoint(p);
                                  // On met à jour le point précédent
                                  widget.db.updatePoint(prev);
                                });
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.mapMarkerAlt,
                                size: (check && e.statusMission == 1) ? 40 : 35,
                                color: (check && e.statusMission == 1)
                                ? Constants.arrivee
                                : Constants.text,
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
                                    : Constants.text,
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
                                  // Le point précédent
                                  Point prev =
                                      findPoint(e.missions[e.indexMission].nom);
                                  // On enlève le bénévole du point où il était avant
                                  prev.numOnPoint = max(prev.numOnPoint - 1, 0);
                                  // On change l'index du point de la mission actuelle
                                  e.indexMission = ind;
                                  // On ajoute la personne aux personnes sur ce point
                                  p.numOnPoint++;
                                  // On change le point actuel
                                  e.pointActuel = p;
                                  // Le bénévole vient d'arriver
                                  e.statusMission = 2;
                                  // Le status du point
                                  p.status = Pben
                                    // On filtre les personnes qui sont sur ce point
                                    .where((element) => element.missions[element.indexMission].nom == p.nom)
                                    // On regarde leur status
                                    .map((e) => e.statusMission)
                                    // On retransforme en liste
                                    .toList()
                                    // On en prend le maximum
                                    .reduce(max);
                                  // On récupère la couleur
                                  p.getCol();
                                  // On met à jour le status du point précédent
                                  prev.status = getPointBen(prev)
                                    // On filtre les personnes qui sont sur ce point
                                    .where((element) => element.missions[element.indexMission].nom == prev.nom)
                                    // On regarde leur status
                                    .map((e) => e.statusMission)
                                    // On retransforme en liste
                                    .toList()
                                    // On en prend le maximum
                                    .reduce(max);
                                  // On récupère la couleur
                                  prev.getCol();
                                  // On met à jour le bénévole
                                  widget.db.updateBenevole(e);
                                  // On met à jour le point
                                  widget.db.updatePoint(p);
                                  // On met à jour le point précédent
                                  widget.db.updatePoint(prev);
                                });
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.trophy,
                                  size:
                                      (check && e.statusMission == 2) ? 40 : 35,
                                  color: (check && e.statusMission == 2)
                                        ? Constants.premier
                                        : Constants.text
                                  ),
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
                                        : Constants.text,
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
                                  // Le point précédent
                                  Point prev =
                                      findPoint(e.missions[e.indexMission].nom);
                                  // On enlève le bénévole du point où il était avant
                                  prev.numOnPoint = max(prev.numOnPoint - 1, 0);
                                  // On change l'index du point de la mission actuelle
                                  e.indexMission = ind;
                                  // On ajoute la personne aux personnes sur ce point
                                  p.numOnPoint++;
                                  // On change le point actuel
                                  e.pointActuel = p;
                                  // Le bénévole vient d'arriver
                                  e.statusMission = 3;
                                  // Le status du point
                                  p.status = Pben
                                    // On filtre les personnes qui sont sur ce point
                                    .where((element) => element.missions[element.indexMission].nom == p.nom)
                                    // On regarde leur status
                                    .map((e) => e.statusMission)
                                    // On retransforme en liste
                                    .toList()
                                    // On en prend le maximum
                                    .reduce(max);
                                  // On récupère la couleur
                                  p.getCol();
                                  // On met à jour le status du point précédent
                                  prev.status = getPointBen(prev)
                                    // On filtre les personnes qui sont sur ce point
                                    .where((element) => element.missions[element.indexMission].nom == prev.nom)
                                    // On regarde leur status
                                    .map((e) => e.statusMission)
                                    // On retransforme en liste
                                    .toList()
                                    // On en prend le maximum
                                    .reduce(max);
                                  // On récupère la couleur
                                  prev.getCol();
                                  // On met à jour le bénévole
                                  widget.db.updateBenevole(e);
                                  // On met à jour le point
                                  widget.db.updatePoint(p);
                                  // On met à jour le point précédent
                                  widget.db.updatePoint(prev);
                                });
                              },
                            icon: FaIcon(
                              FontAwesomeIcons.stopwatch,
                              size: (check && e.statusMission == 3) ? 40 : 35,
                              color: (check && e.statusMission == 3)
                                    ? Constants.dernier
                                    : Constants.text
                              ),
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
                                        : Constants.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: (check && e.statusMission == 3)
                                      ? 15
                                      : 12),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }

  Point findPoint(String nom) {
    for (Point p in widget.posPoints) {
      if (p.nom == nom) {
        return p;
      }
    }
    return Point.empty();
  }

  List<Benevole> getPointBen(Point p) {
    /* Récupère les bénévole qui sont sur un point donné
    param :
          - p (Point) le point

    result :
          - List<Benevole>
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
    Point p = widget.p;
    List<Benevole> Pben = getPointBen(p);
    String position =
        p.lat.toStringAsFixed(6) + ", " + p.long.toStringAsFixed(6);
    return Container(
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
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
                Container(
                  height: 35,
                  child: Text(
                    p.nom,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Constants.background,
                        fontWeight: FontWeight.w900,
                        fontSize: 35),
                  ),
                ),
                // Le nom du bénévole
                Container(
                  height: 65,
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 20,
                        ),
                        Column(children: [
                          Container(
                            height: 45,
                          ),
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
                // Le numéro du bénévole
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
            int k = Pben.indexOf(e);
            return buildCard(e, p, ind, k);
          }).toList())
        ],
      )),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.grey.shade100;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();
    path.moveTo(0, 0);
    final center = new Offset(size.width, 0);
    final startAngle = -3.14;
    final endAngle = -3.14 / 2;
    path.arcTo(new Rect.fromCircle(center: center, radius: 70), startAngle,
        endAngle, true);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
