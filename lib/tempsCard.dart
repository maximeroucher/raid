import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raidmap/constant.dart';
import 'package:custom_check_box/custom_check_box.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dialog.dart';
import 'constant.dart';
import 'customPainter.dart';
import 'equipe.dart';
import 'database.dart';

// La page des paramètres
class tempsCard extends StatefulWidget {
  // Les différentes épreuves possibles
  List<String> epreuves = [];
  // la liste des équipes
  List<Equipe> eq;
  // Le nom de l'épreuve actuelle
  String nomEpreuve = "";
  // la base de donnée
  DatabaseManager db;

  // Le type de temps (0 = départ, 1 =  arrivé)
  int type = 0;

  tempsCard({Key key, this.eq, this.nomEpreuve, this.epreuves, this.db})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => tempsCardState();
}

class tempsCardState extends State<tempsCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /* Crée la page des paramètres
    param :
          - context (BuildContext)

    result :
          - Container(Widget)
    */
    return Container(
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
            child: Column(
          children: [
            // L'image de fond
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
                    height: 55,
                    child: Text(
                      "Temps",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Constants.background,
                          fontWeight: FontWeight.w900,
                          fontSize: 35),
                    ),
                  ),
                  Container(
                      height: 45,
                      child: Column(
                        children: [
                          // L'espace entre "Temps" et le nom de l'épreuve
                          Container(
                            height: 10,
                          ),
                          // Ouvre une fenêtre pour changer le nom de l'épreuve
                          GestureDetector(
                            child: Container(
                              height: 35,
                              width: 200,
                              child: Text(
                                // Le nom de l'épreuve que l'on peut changer
                                widget.nomEpreuve,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Constants.background,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                            onTap: () {
                              // La fenêtre de changement de nom
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      SimpleDialog(
                                        title: Text(
                                          "Épreuve",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Constants.darkgrad,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        // Les différents choix d'épreuve
                                        children: widget.epreuves
                                            .map((e) => SimpleDialogOption(
                                                  child: Container(
                                                    child: Text(
                                                      e,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            Constants.lightgrad,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                  // On change le nom quand on clique dessus et on ferme la fenêtre
                                                  onPressed: () {
                                                    setState(() {
                                                      widget.nomEpreuve = e;
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                ))
                                            .toList(),
                                      ));
                            },
                          )
                        ],
                      )),
                  // Le numéro du bénévole
                  Container(
                      height: 70,
                      // Placement des boutons
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // La courbe à gauche
                          Container(
                            width: 70,
                            height: 70,
                            child: CustomPaint(
                              painter: CurvePainter(),
                            ),
                          ),
                          // Les boutons départ / arrivée
                          Column(
                            children: [
                              // Espace entre le texte et le bouton
                              Container(
                                height: 5,
                              ),
                              Container(
                                width: 100,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  // la couleur change avec le choix
                                  color: (widget.type == 1)
                                      ? Colors.transparent
                                      : Constants.background,
                                ),
                                child: TextButton(
                                    child: Text(
                                      "Départ",
                                      style: TextStyle(
                                          // la couleur change avec le choix
                                          color: (widget.type == 1)
                                              ? Constants.background
                                              : Constants.darkgrad,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    // On enlève l'animation
                                    style: ButtonStyle(
                                      splashFactory: NoSplash.splashFactory,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        // On change pour départ
                                        widget.type = 0;
                                      });
                                    }),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              // Espace entre le texte et le bouton
                              Container(
                                height: 5,
                              ),
                              Container(
                                width: 100,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  // la couleur change avec le choix
                                  color: (widget.type == 0)
                                      ? Colors.transparent
                                      : Constants.background,
                                ),
                                child: TextButton(
                                    child: Text(
                                      "Arrivée",
                                      style: TextStyle(
                                          // la couleur change avec le choix
                                          color: (widget.type == 0)
                                              ? Constants.background
                                              : Constants.darkgrad,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    // On enlève l'animation
                                    style: ButtonStyle(
                                      splashFactory: NoSplash.splashFactory,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        // On change pour arrivée
                                        widget.type = 1;
                                      });
                                    }),
                              ),
                            ],
                          ),
                          Container(
                            width: 70,
                          ),
                        ],
                      )),
                  // La courbe à droite
                  Container(
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.only(topRight: Radius.circular(70)),
                        color: Colors.grey.shade100,
                      ),
                      child: Column(children: [
                        Container(
                          height: 35,
                        ),
                        Text(
                          "Équipes",
                          style: TextStyle(
                              color: Constants.darkgrad,
                              fontWeight: FontWeight.w900,
                              fontSize: 25),
                        )
                      ]))
                ],
              ),
            ),
            // La liste des équipes
            Column(
                children: sort().map((e) {
              int i = widget.eq.indexOf(e);
              return buildCard(e, i);
            }).toList())
          ],
        )));
  }

  List<Equipe> sort() {
    widget.eq.sort((a, b) => compare(a, b));
    return widget.eq;
  }

  int compare(Equipe a, Equipe b) {
    bool astopped = a.temps[widget.type][widget.nomEpreuve] != null;
    bool bstopped = b.temps[widget.type][widget.nomEpreuve] != null;
    if (astopped) {
      if (bstopped) {
        if (a.num < b.num) {
          return -1;
        } else {
          return 1;
        }
      }
      return 1;
    } else {
      if (bstopped) {
        return -1;
      } else {
        if (a.num < b.num) {
          return -1;
        } else {
          return 1;
        }
      }
    }
  }

  Widget buildCard(Equipe e, int i) {
    // Si on a arrêter le chrono de cette équipe
    bool stopped = e.temps[widget.type][widget.nomEpreuve] != null;
    return Container(
        // Le cadre
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
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          // Espace avec le haut du cadre
                          Container(
                            height: 15,
                          ),
                          Row(
                            // Placement des textes
                            children: [
                              // Espaces avec le bord gauche
                              Container(
                                width: 20,
                              ),
                              // Le numéro de l'équipe
                              Text(
                                "Équipe " + e.num.toString(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Constants.arrivee,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                              ),
                              // Espace entre le nom et le type
                              Container(
                                width: 15,
                              ),
                              // le type de course de l'équipe
                              Text(
                                e.getTypeString(),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Constants.arrivee,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          Container(
                            height: 13,
                          ),
                          Row(
                            // Placement du texte
                            children: [
                              // Espaces avec le bord gauche
                              Container(
                                width: 20,
                              ),
                              // Le nom de l'équipe
                              Text(
                                e.nom,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Constants.premier,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                              ),
                            ],
                          ),
                          Container(
                            height: 17,
                          ),
                          Row(
                            // Placement du texte
                            children: [
                              // Espaces avec le bord gauche
                              Container(
                                width: 20,
                              ),
                              // L'icône du chrono
                              FaIcon(
                                FontAwesomeIcons.stopwatch,
                                size: 20,
                                color: Constants.dernier,
                              ),
                              // Espace avec le texte
                              Container(
                                width: 10,
                              ),
                              // Le temps
                              Text(
                                stopped
                                    ? e.temps[widget.type][widget.nomEpreuve]
                                            .hour
                                            .toString()
                                            .padLeft(2, '0') +
                                        ":" +
                                        e.temps[widget.type][widget.nomEpreuve]
                                            .minute
                                            .toString()
                                            .padLeft(2, '0') +
                                        ":" +
                                        e.temps[widget.type][widget.nomEpreuve]
                                            .second
                                            .toString()
                                            .padLeft(2, '0')
                                    : "",
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    color: Constants.dernier,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    // La Checkbox
                    Container(
                      width: 70,
                      child: CustomCheckBox(
                        value: stopped,
                        shouldShowBorder: true,
                        borderColor: Constants.darkgrad,
                        checkedFillColor: Constants.lightgrad,
                        splashRadius: 40,
                        borderRadius: 8,
                        borderWidth: 1,
                        checkBoxSize: 30,
                        onChanged: (val) {
                          // Si c'est pour retirer le temps
                          if (stopped) {
                            // On demande avec une fenêtre ded confirmation
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    // Crée la fenêtre de confirmation
                                    CustomDialogBox(
                                        descriptions: "Supprimer le temps ?",
                                        title: "Suppression",
                                        onYes: () {
                                          setState(() {
                                            // On supprime le temps
                                            e.temps[widget.type]
                                                [widget.nomEpreuve] = null;
                                            widget.db.updateEquipe(e);
                                            sleep(Duration(milliseconds: 100));
                                          });
                                        }));
                          } else {
                            setState(() {
                              // On ajoute le temps
                              e.temps[widget.type][widget.nomEpreuve] =
                                  DateTime.now();
                              widget.db.updateEquipe(e);
                              sleep(Duration(milliseconds: 100));
                            });
                          }
                        },
                      ),
                    )
                  ],
                ))));
  }
}
