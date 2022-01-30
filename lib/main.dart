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

31/01

Naviagtion

--------------------------------------------------------------------------------

./02

TEST + RÉU° : (Éclair : IOS + autres test)


2 pt -> mm endroit (dissocier col + pb db) (normt pas de pb / dmd)


recep° + pasring msg (dmd)


page tps participants (dmd avant)

-> tps participant + qr code maj
  (ben ft tps (s/ check box avec tps = tps tel au check) et raidman scan)

app bénévole (liste mission / liste num autre (msg, tel) / btn arrivée pt / 1er / dernier // page tps participant)

--------------------------------------------------------------------------------

./02

programme pr créer json
*/
