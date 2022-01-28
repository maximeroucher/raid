import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raidmap/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


// La barre de navigation en bas
class BottomNavBarFb5 extends StatelessWidget {
  // les boutons de la barre
  final List<IconBottomBar> l;

  const BottomNavBarFb5({Key key, this.l}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /* Créer la barre
    param :
          - context (BuildContext)

    result :
          - Container(Widget)
    */
    return Container(
      height: 60,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/backgroundtest.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      // La barre
      child: Column(
        children: [
          Container(
            color: Colors.transparent,
            child: SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width,
              // Les boutons de la barre
              child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: this.l),
            ),
          ),
        ],
      )
    );
  }
}


// Les boutons de la barre
class IconBottomBar extends StatefulWidget {
  // Le texte e dessous du bouton
  final String text;
  // L'icône du bouton
  final IconData icon;
  // La fonction quand on clique sur le bouton
  final Function() onPressed;
  // Si on est sur la page liée à ce bouton
  bool selected;

  IconBottomBar({Key key, this.text, this.icon, this.onPressed, this.selected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => IconBottomBarState();
}

class IconBottomBarState extends State<IconBottomBar> {

  @override
  Widget build(BuildContext context) {
    // Détection de clic sur le bouton
    return GestureDetector(
      // On lance alors la focntion donnée
      onTap: widget.onPressed,
      // la zone cliquable
      child: Container(
        width: 80,
        height: 55,
        // la couleur n'est pas transparente, car sinon la zone n'est plus cliquable
        color: Colors.white.withAlpha(1),
          child: widget.selected
          ? Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      height: 7,
                    ),
                  FaIcon(
                    widget.icon,
                    size: 25,
                    // On change la couleur en fonction de la valuer de selected
                    color: Constants.background),
                  Container(
                    height: 2,
                    width: 25,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.all(Radius.circular(2)),
                      color: Constants.background,
                    ),
                  ),
                  Container(
                  ),
                ]
              )
            ]
          )
          : Icon(
              widget.icon,
                size: 25,
                // On change la couleur en fonction de la valuer de selected
                color: Constants.background
            ),
        ),
      );
  }
}
