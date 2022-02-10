import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'constant.dart';

// Le nom de la table dans la base de donnée
final String tablePoint = "point";

// La classe contenant les noms des colonnes dans la base de données
class PointFields {
  // La liste des noms
  static final List<String> values = [
    id,
    lat,
    long,
    nom,
    status,
    type,
    dateDebut,
    dateFin,
    numOnPoint,
    pointPrec
  ];

  // Le nom des colonnes dans la base de donnée
  static final String dateDebut = "dateDebut";
  static final String dateFin = "dateFin";
  static final String id = "id";
  static final String lat = "lat";
  static final String long = "long";
  static final String nom = "nom";
  static final String numOnPoint = "numOnPoint";
  static final String pointPrec = "pointPrec";
  static final String status = "status";
  static final String type = "type";
}

// Représentation d'une mission
class Point {
  // La couleur du point par défaut
  Color col = Color(0xFF333333);
  // La date de début de mission
  DateTime dateDebut = DateTime.utc(0, 0, 0, 0, 0);
  // La date de fin de mission
  DateTime dateFin = DateTime.utc(0, 0, 0, 0, 0);
  // L'identifiant
  int id = 0;
  // La latitude du point
  double lat = 0.0;
  // La longitude du point
  double long = 0.0;
  // Le nom du point
  String nom = "";
  // le nombre de bénévole sur ce point à cet instant
  int numOnPoint = 0;
  // Le point précédent (utile pour tracer les chemins entre points)
  String pointPrec = "";
  // la position du point (On ne peut pas sauvergarder les coordonnées sous ce format, d'où la décomposition en latitude et longitude)
  LatLng pos = LatLng(0.0, 0.0);
  // Le status du point
  int status = 0; // 0 personne, 1 auguilleur en place, 2 ouvreur, 3 fermeur
  // Le type de point
  int type = 0; // 0 pt aiguillage, 1 pt ravito / camping ...

  Point(int Id, double Lat, double Long, String Nom, int Type, int Status,
      DateTime DateDebut, DateTime DateFin, int NumOnPoint, String PointPrec)
  /**
   * Crée un point avec les paramètres donnés
   *
   * param :
   *     - Id (int) l'identifiant du point
   *     - Lat (double) la latitude du point
   *     - Long (double) la longitude du point
   *     - Nom (String) le nom du point
   *     - Type (int) le type du point
   *     - Status (int) le status du point
   *     - DateDebut (DateTime)
   *     - DateFin (DateTime)
   *     - NumOnPoint (int) le nombre de bénévole actuellement sur le point
   *     - PointPrec (String) le nom du point précédent dans l'ordre ded la course
   */
  {
    id = Id;
    lat = Lat;
    long = Long;
    pos = LatLng(lat, long);
    nom = Nom;
    status = Status;
    type = Type;
    dateDebut = DateDebut;
    dateFin = DateFin;
    numOnPoint = NumOnPoint;
    pointPrec = PointPrec;
    // On charge la couleur du point
    getCol();
  }

  Point.empty() {
    /**
     * Crée un point vide, pour éviter des erreurs d'objet non défini
     */
  }

  static Point fromJson(Map<String, Object> json) =>
    /**
     * Créer un point à partir des informations contenues dans un dictionnaire
     *
     * param :
     *     - json (Map<String, Objet>) le dictionnaire contenant les valeurs permettant de générer un point
     *
     * result :
     *     - Point
     */
      Point(
        json[PointFields.id] as int,
        json[PointFields.lat] as double,
        json[PointFields.long] as double,
        json[PointFields.nom] as String,
        json[PointFields.type] as int,
        json[PointFields.status] as int,
        // On reconvertit le texte en objet date
        DateTime.parse(json[PointFields.dateDebut] as String),
        DateTime.parse(json[PointFields.dateFin] as String),
        json[PointFields.numOnPoint] as int,
        json[PointFields.pointPrec] as String,
      );

  Map<String, Object> toJson() =>
    /**
     * Crée le dictionnaire représentant le point
     *
     * result :
     *     - Map<String, Objet> le dictionnaire représentant le point
     */
      {
        PointFields.id: id,
        PointFields.lat: lat,
        PointFields.long: long,
        PointFields.nom: nom,
        PointFields.type: type,
        PointFields.status: status,
        PointFields.dateDebut: dateDebut.toString(),
        PointFields.dateFin: dateFin.toString(),
        PointFields.numOnPoint: numOnPoint,
        PointFields.pointPrec: pointPrec
      };

  Point copy(
          {int id,
          double lat,
          double long,
          String nom,
          int status,
          int type,
          DateTime dateDebut,
          DateTime dateFin,
          int numOnPoint,
          String pointPrec,
          String pointSuiv}) =>
      /**
     * Renvoie un point avec les modifications données
     *
     * param :
     *     - id (int) l'identifiant du point
     *     - lat (double) la latitude du point
     *     - long (double) la longitude du point
     *     - nom (String) le nom du point
     *     - type (int) le type du point
     *     - status (int) le status du point
     *     - dateDebut (DateTime)
     *     - dateFin (DateTime)
     *     - numOnPoint (int) le nombre de bénévole actuellement sur le point
     *     - pointPrec (String) le nom du point précédent dans l'ordre ded la course
     */
      Point(
          id ?? this.id,
          lat ?? this.lat,
          long ?? this.long,
          nom ?? this.nom,
          type ?? this.type,
          status ?? this.status,
          dateDebut ?? this.dateDebut,
          dateFin ?? this.dateFin,
          numOnPoint ?? this.numOnPoint,
          pointPrec ?? this.pointPrec);

  void getCol() {
    /**
     * Change la couleur du point en fonction de son status et de son type
     */
    // S'il n'y a personne
    if (status == 0) {
      col = Constants.personne;
      // Si au moins un bénévole est arrivé
    } else if (status == 1) {
      col = Constants.arrivee;
      // Si les ouvreurs sont passé
    } else if (status == 2) {
      col = Constants.premier;
      // Si les fermeurs sont passé
    } else {
      col = Constants.dernier;
    }
  }
}
