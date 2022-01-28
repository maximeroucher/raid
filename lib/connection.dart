import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';


// Gestionnaire d'état de connectivité
class MyConnectivity {
  MyConnectivity._();

  // L'instance, le moyen d'accéder à cette classe
  static final _instance = MyConnectivity._();
  // La fonction qui renvoie l'instance
  static MyConnectivity get instance => _instance;
  // Un objet de la class connectivity
  final _connectivity = Connectivity();
  // L'objet permettant de toujours pouvoir connaitre l'état du réseau
  final _controller = StreamController.broadcast();
  // La fonction qui renvoie le flux d'information
  Stream get myStream => _controller.stream;


  void initialise() async {
    /* Initialise l'observateur de la connection
    */
    // L'objet permettant de savoir si on est connecté
    ConnectivityResult result = await _connectivity.checkConnectivity();
    // On regarde si on est connecté
    _checkStatus(result);
    // Met à jour à chaque changement de valeur de _connectivity
    _connectivity.onConnectivityChanged.listen((result) {
      // On regarde si on est connecté
      _checkStatus(result);
    });
  }


  void _checkStatus(ConnectivityResult result) async {
    /* Permet de connaitre le status de la connexion
    */
    // Par défaut, on est hors-ligne
    bool isOnline = false;
    // On essaie de se connecter à Internet
    try {
      final result = await InternetAddress.lookup('example.com');
      // On regarde si la réponse est vide, dans ce cas on est hors-ligne
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    // Si on y arrive pas c'est que l'on est hors-ligne
    } on SocketException catch (_) {
      isOnline = false;
    }
    // On met à jour la valeur de _controller
    _controller.sink.add({result: isOnline});
  }

  // Cette fonction met fin à l'observation de la connexion
  void disposeStream() => _controller.close();
}