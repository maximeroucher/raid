import 'package:flutter/material.dart';

import 'point.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Le nom de la table dans la base de donnée
const String tableBenevole = "benevole";

// La classe contenant les noms des colonnes dans la base de données
class BenevoleFields {
  // La liste des noms
  static final List<String> values = [
    id,
    nom,
    surnom,
    num,
    type,
    indexMission,
    statusMission
  ];

  // Le nom des colonnes dans la base de donnée
  static const String id = "id";
  static const String nom = "nom";
  static const String surnom = "surnom";
  static const String num = "num";
  static const String type = "type";
  static const String indexMission = "indexMission";
  static const String statusMission = "statusMission";
}


// La représentation d'un bénévole
class Benevole {
  // Son identifiant
  int id = 0;
  // Son nom
  String nom = "";
  // Son surnom
  String surnom = "";
  // Son numéro
  String num = "";
  // La liste de ses missions
  List<Point> missions = [];
  // Son point actuel (par défaut, le point en (0,0))
  Point pointActuel = Point.empty();
  // Son type
  int type = 0; // 0 aiguilleur, 1 voiture, 2 sportif, 3 raid
  // Le numéro de sa mission actuelle
  int indexMission = 0;
  // L'avancement de sa mission
  int statusMission = 0; // 0 personne, 1 auguilleur en place, 2 ouvreur, 3 fermeur


  Benevole(int Id, String Nom, String Surnom, String Num, List<Point> Missions,
      int Type, int IndexMission, int StatusMission) {
    /**
     * Créer un bénévole à partir des informations données
     *
     * param :
     *     - Id (int) l'identifiant du bénévole
     *     - Nom (String) le nom du bénévole
     *     - Surnom (String) le surnom du bénévole
     *     - Num (String) le numéro de téléphone du bénévole
     *     - Missions (List<Point>) les missions
     *     - Type (int) le type du bénévole
     *     - IndexMission (int) l'index de la mission actuelle du bénévole dans la liste des missions
     *     - StatusMision (int) Le status de la mission du bénévole
     */
    id = Id;
    nom = Nom;
    surnom = Surnom;
    num = Num;
    missions = Missions;
    missions.sort((a, b) => a.dateDebut.compareTo(b.dateDebut));
    // Le point actuel du bénévole est celui correspondant à l'index de la mission si il y a assez de mission
    pointActuel = missions.isNotEmpty ? missions[indexMission] : pointActuel;
    type = Type;
    indexMission = IndexMission;
    statusMission = StatusMission;
  }


  static Benevole fromJson(Map<String, Object> json) =>
    /**
     * Créer un bénévole à partir des informations contenues dans un dictionnaire
     *
     * param :
     *     - json (Map<String, Objet>) le dictionnaire contenant les valeurs permettant de générer un bénévole
     *
     * result :
     *     - Benevole
     */
    Benevole(
        json[BenevoleFields.id] as int,
        json[BenevoleFields.nom] as String,
        json[BenevoleFields.surnom] as String,
        json[BenevoleFields.num] as String,
        // On ne met pas les missions pour l'instant, ce sera fait à la main
        [],
        json[BenevoleFields.type] as int,
        json[BenevoleFields.indexMission] as int,
        json[BenevoleFields.statusMission] as int,
      );

  Map<String, Object> toJson() =>
    /**
     * Crée le dictionnaire représentant le bénévole
     *
     * result :
     *     - Map<String, Objet> le dictionnaire représentant le bénévole
     */
    {
        BenevoleFields.id: id,
        BenevoleFields.nom: nom,
        BenevoleFields.surnom: surnom,
        BenevoleFields.num: num,
        BenevoleFields.type: type,
        BenevoleFields.indexMission: indexMission,
        BenevoleFields.statusMission: statusMission,
      };


  Benevole copy({int id, String nom, String surnom, String num, List<Point> missions,
    Point pointActuel, int type, int indexMission, int statusMissions}) =>
    /**
     * Renvoie un bénévole avec les modifications données
     *
     * param :
     *     - id (int) l'identifiant du bénévole
     *     - nom (String) le nom du bénévole
     *     - surnom (String) le surnom du bénévole
     *     - num (String) le numéro de téléphone du bénévole
     *     - missions (List<Point>) les missions
     *     - pointActuel (Point) le point actuel du bénévole
     *     - type (int) le type du bénévole
     *     - indexMission (int) l'index de la mission actuelle du bénévole dans la liste des missions
     *     - statusMision (int) Le status de la mission du bénévole
     */
      Benevole(
        id ?? this.id,
        nom ?? this.nom,
        surnom ?? this.surnom,
        num ?? this.num,
        missions ?? this.missions,
        type ?? this.type,
        indexMission ?? this.indexMission,
        statusMissions ?? statusMission
      );

  Benevole.empty() {
    /**
     * Génére un bénévole vide, pour éviter des erreurs d'initialisation
     */
  }

  IconData getIcon() {
    /**
     * Renvoie l'icône correspondant au type de bénévole
     *
     * result :
     *     - IconData
     */
    // Si c'est un aiguilleur
    if (type == 0) {
      return FontAwesomeIcons.mapSigns;
    // Si c'est un bénévole voiture
    } else if (type == 1) {
      return FontAwesomeIcons.car;
    // Si c'est un bénévole sportif
    } else if (type == 2) {
      return FontAwesomeIcons.running;
    // Si c'est un raidman
    } else if (type == 3) {
      return FontAwesomeIcons.map;
    // Si c'est le samu
    } else {
      return FontAwesomeIcons.plus;
    }
  }

  bool isType(String query) {
    /**
     * Permet de faire des recherche rapides dans la barre de recherche
     *
     * param :
     *     - query (String) la recherche
     *
     * result :
     *     - bool (si le bénévole s'accorde avec la recherche)
     */
    // Si c'est un aiguilleur
    if (type == 0) {
      // Si query est dans "aiguilleur"
      return "aiguilleur".contains(query);
    // Si c'est un bénévole voiture
    } else if (type == 1) {
      // Si query est dans "voiture"
      return "voiture".contains(query);
    // Si c'est un bénévole sportif
    } else if (type == 2) {
      // Si query est dans "sportif"
      return "sportif".contains(query);
    // Si c'est un raidman
    } else if (type == 3) {
      // Si query est dans "raid"
      return "raid".contains(query);
    // Si c'est le samu
    } else {
      // Si query est dans "samu"
      return "samu".contains(query);
    }
  }
}
