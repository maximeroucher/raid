import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

/* TODO:

Json doit changer de nom ou desinstaller app (sinon pb cache)

10/02 : != tps pr mm pt (chgt datedebut / fin (tabledate (id ben, nom pt, dadedebut, detafin)))


test IOS

pb : map oline charge qd mm
----

Pb : imp avoir tte map

Amélio° : anima°

A faire : verif nom fichier (fait normt mais pas tester)
          test (p-ê IOS, voir avec Eclair)
          Créa° de zip des maps par zone pr Raid apres
          programme pr crée base de donnée à télécharger


Possible :

  tps participants :
    cocher : ++ pas besoin de co
             ++ moins de perte de temps
             -- il faut un respo chrono qui coche tlm

    QR Code : ++ plus besoin de Raidman
              ++ juste besoin de scanner
              -- juste bénévole avec l'appli
              -- suret pas prêt pr la challenge


  parsing msg + appli benevole :
    ++ appli pr tlm au raid car pas besoin taper msg à la main
    ++ pas de pb pr trouver num de qui que ce soit
    -- tlm doit avoir l'appli + base de données


app bénévole (liste mission / liste num autre (msg, tel) / btn arrivée pt / 1er / dernier // page tps participant)

--------------------------------------------------------------------------------

./02

programme pr créer json
*/
