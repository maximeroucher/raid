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

db : check fichier correct

map : si mpapack vide
      -> zip
      -> dezip ds dossier

2 pt -> mm endroit (dissocier col + pb db)



page tps participants

-> tps participant + qr code maj
  (ben ft tps (s/ check box avec tps = tps tel au check) et raidman scan)



programme pr créer json / zip mappack

refaire mappack

app bénévole (page tps participant / liste mission / liste num autre (msg, tel) / btn arrivée pt / 1er / dernier)
*/
