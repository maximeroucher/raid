import 'package:flutter/material.dart';
import 'constant.dart';

// Le nom de la table dans la base de donnée
final String tableEquipe = "equipe";

// La classe contenant les noms des colonnes dans la base de données
class EquipeFields {
  // La liste des noms
  static final List<String> values = [
    id,
    num,
    nom,
    type,
  ];

  // Le nom des colonnes dans la base de donnée
  static final String id = "id";
  static final String nom = "nom";
  static final String num = "num";
  static final String type = "type";
}

// Représentation d'une équipe
class Equipe {
  // L'identifiant
  int id = 0;
  // le numéro
  int num = 1;
  // Le nom de l'équipe
  String nom = "";
  // Le type de courses auxquelles l'équipe participe
  int type = 0; // 0 Challenge, 1 débutant, 2 sportif, 3 expert
  // Les temps de l'équipe
  List<Map<String, DateTime>> temps;

  Equipe(int Id, int Num, String Nom, int Type)
  /* Crée une équipe avec les paramètres donnés
  */
  {
    id = Id;
    num = Num;
    nom = Nom;
    type = Type;
    // Aucun temps n'est enregistré par défaut
    temps = [
      {
        "Trail 1": null,
        "Trail 2": null,
        "VTT 1": null,
        "VTT 2": null,
        "Run & Bike": null,
      },
            {
        "Trail 1": null,
        "Trail 2": null,
        "VTT 1": null,
        "VTT 2": null,
        "Run & Bike": null,
      }
    ];
  }

  // Crée une équipe vide (pour éviter des erreurs d'objet non défini)
  Equipe.empty() {}

  static Equipe fromJson(Map<String, Object> json) =>
      /* Crée une équipe avec les paramètres donnés au format dictionnaire
  */
      Equipe(
        json[EquipeFields.id] as int,
        json[EquipeFields.num] as int,
        json[EquipeFields.nom] as String,
        json[EquipeFields.type] as int,
      );

  Map<String, Object> toJson() =>
      // Transforme une équipe en dicionnaire
      {
        EquipeFields.id: id,
        EquipeFields.num: num,
        EquipeFields.nom: nom,
        EquipeFields.type: type,
      };

  Equipe copy({int id, int num, String nom, int type}) =>
      // Copie l'équipe en changeant les données données
      Equipe(
          id ?? this.id, num ?? this.num, nom ?? this.nom, type ?? this.type);

  String getTypeString() {
    /* Retourne le texte associé au type de course
    */
    if (type == 3) {
      return "(Expert)";
    } else if (type == 2) {
      return "(Sportif)";
    } else if (type == 1) {
      return "(Débutant)";
    } else {
      return "";
    }
  }
}
