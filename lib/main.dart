import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

/* TODO:

Json doit changer de nom ou desinstaller app (sinon pb cache)

29/01

progressbar (+ toast)
--------------------------------------------------------------------------------
30/01

db : check fichier correct (verif pdt lecture et parsing juste try / catch)
    -> toast sinon

map : verif bon format img

mode : -> verif.json == 1,
       -> offline
       else
       -> online (+ save map (si tps pr devt) ./02)

--------------------------------------------------------------------------------

./02

refaire mappack (tt ds rayon 2h -> 1 seul mappack pr tjr)


TEST + RÉU° : (Éclair : IOS + autres test)


2 pt -> mm endroit (dissocier col + pb db) (normt pas de pb / dmd)


recep° + pasring msg (dmd)


page tps participants (dmd avant)

-> tps participant + qr code maj
  (ben ft tps (s/ check box avec tps = tps tel au check) et raidman scan)

app bénévole (liste mission / liste num autre (msg, tel) / btn arrivée pt / 1er / dernier // page tps participant)

--------------------------------------------------------------------------------

./02

programme pr créer json (zip mappack)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


Éclair

./02

Site Raid + Forum

*/
