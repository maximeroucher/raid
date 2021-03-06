import 'package:flutter/material.dart';
import 'package:raidmap/constant.dart';

import 'dialog.dart';
import 'constant.dart';
import 'customPainter.dart';

// La page des paramètres
class paramCard extends StatefulWidget {
  // Regarde si la base de donnée et les images de la carte sont chargée
  bool isDBLoaded, isTileSetLoaded;
  // les fonctions pour supprimer la base de donnée et les cartes
  Function delDB, delMap, addDB, addMap;
  // Le texte du bouton des cartes
  String TileText;

  paramCard(
      {Key key,
      this.isDBLoaded,
      this.isTileSetLoaded,
      this.delDB,
      this.delMap,
      this.addDB,
      this.addMap,
      this.TileText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => paramCardState();
}

class paramCardState extends State<paramCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /**
     * Crée la page des paramètres
     * param :
     *     - context (BuildContext)
     *
     * result :
     *     - Container(Widget)
    */
    return Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            // L'image de fond
            Container(
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/backgroundtest.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                  ),
                  const SizedBox(
                    height: 60,
                    child: Text(
                      "Paramètres",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Constants.background,
                          fontWeight: FontWeight.w900,
                          fontSize: 35),
                    ),
                  ),
                  // Le numéro du bénévole
                  SizedBox(
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // La courbe à gauche
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CustomPaint(
                              painter: CurvePainter(),
                            ),
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
                            const BorderRadius.only(topRight: Radius.circular(70)),
                        color: Colors.grey.shade100,
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 30,
                          ),
                          const Center(
                            child: Text(
                              "Données",
                              style: TextStyle(
                                  color: Constants.darkgrad,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Le texte indiquant si la base de donnée est chargée ou non
                    Text(
                      // Le texte change en fonction de isDBLoaded
                      widget.isDBLoaded ? "Chargées" : "Non chargées",
                      style: TextStyle(
                          // La couleur change en fonction de isDBLoaded
                          color: widget.isDBLoaded
                              ? Constants.lightgrad
                              : Constants.textnotloaded,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    )
                  ],
                ),
                // Espace entre le texte et le bouton
                Container(
                  height: 20,
                ),
                InkWell(
                    onTap: () {
                      widget.isDBLoaded
                          // Le formulaire pour confirmer la suppression
                          ? showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  // Crée la fenêtre de confirmation
                                  CustomDialogBox(
                                      descriptions:
                                          "Supprimer la base de données ?",
                                      title: "Suppression",
                                      onYes: () {
                                        widget.delDB();
                                      }))
                          : widget.addDB();
                    },
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    // Le corps du bouton
                    child: Container(
                      width: 250,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3), //  changes position of shadow
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          // Le gradient de couleur dépend de isDBLoaded
                          colors: widget.isDBLoaded
                              ? [Constants.darkdel, Constants.lightdel]
                              : [Constants.darkgrad, Constants.lightgrad],
                        ),
                      ),
                      // Le texte du bouton
                      child: Text(
                        // Le texte change en fonction de isDBLoaded
                        widget.isDBLoaded
                            ? "Supprimer les données"
                            : "Charger un fichier",
                        style: const TextStyle(
                            color: Constants.background,
                            fontWeight: FontWeight.w900,
                            fontSize: 18),
                      ),
                    ))
              ],
            ),
            Container(
              height: 80,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // le text de la carte
                    const Text(
                      "Cartes",
                      style: TextStyle(
                          color: Constants.darkgrad,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                    // Espace entre le texte et le texte d'indication
                    Container(
                      height: 10,
                    ),
                    // Le texte d'indication
                    Text(
                      // Le texte dépend de isTileSetLoaded
                      widget.isTileSetLoaded ? "Chargées" : "Non chargées",
                      style: TextStyle(
                          // La couleur dépend de isTileSetLoaded
                          color: widget.isTileSetLoaded
                              ? Constants.lightgrad
                              : Constants.textnotloaded,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    )
                  ],
                ),
                // Espace entre le texte et le bouton
                Container(
                  height: 20,
                ),
                InkWell(
                    onTap: () {
                      widget.isTileSetLoaded
                          // Affiche la fenêtre de confirmation
                          ? showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  // Crée la fenêtre de confirmation
                                  CustomDialogBox(
                                      descriptions: "Supprimer les cartes ?",
                                      title: "Suppression",
                                      onYes: () {
                                        widget.delMap();
                                      }))
                          : widget.addMap();
                    },
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                    // Le conteneur du bouton
                    child: Container(
                      width: 250,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          // le gradient de douleur dépend de isTileSetLoaded
                          colors: widget.isTileSetLoaded
                              ? [Constants.darkdel, Constants.lightdel]
                              : [Constants.darkgrad, Constants.lightgrad],
                        ),
                      ),
                      // Le texte du bouton
                      child: Text(
                        widget.TileText,
                        style: const TextStyle(
                            color: Constants.background,
                            fontWeight: FontWeight.w900,
                            fontSize: 18),
                      ),
                    ))
              ],
            ),
          ],
        ));
  }
}
