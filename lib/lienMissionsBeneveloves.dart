// Cette classe sert uniquement pour la base de donnée afin de lier les bénévoles à leurs missions

// Le nom de la table dans la base de donnée
const String tableLien = "lien";

// La classe contenant les noms des colonnes dans la base de données
class LienFields {
  // La liste des noms
  static final List<String> values = [
    ben,
    mission,
    dateDebut,
    dateFin,
  ];

  // Le nom des colonnes dans la base de donnée
  static const String ben = "benevole";
  static const String mission = "mission";
  static const String dateDebut = "dateDebut";
  static const String dateFin = "dateFin";
}

// La représentation d'un lien entre un bénévole et une mission
class Lien {
  // Le bénévole (son identifiant)
  int ben = 0;
  // La mission (son identifiant)
  int mission = 0;
  // la date de début de mission
  DateTime dateDebut;
  // La date de fin de mission
  DateTime dateFin;

  Lien(int Ben, int Mission, DateTime DateDebut, DateTime DateFin)
  /**
   * Crée un lien entre le bénévole donné et la mission donnée
   *
   * param :
   *     - Ben (int) l'identifiant du bénévole
   *     - Mission (int) l'identifiant de la mission
   */
  {
    ben = Ben;
    mission = Mission;
    dateDebut = DateDebut;
    dateFin = DateFin;
  }

  static Lien fromJson(Map<String, Object> json) =>
      /**
   * Crée un lien entre le bénévole donné et la mission donnée au format dictionnaire
   *
   * param :
   *     - json (Map<String, Objet>) le dictionnaire contenant les valeurs permettant de générer un lien
   *
   * result :
   *     - Lien
  */
      Lien(
        json[LienFields.ben] as int,
        json[LienFields.mission] as int,
        DateTime.parse(json[LienFields.dateDebut] as String),
        DateTime.parse(json[LienFields.dateFin] as String),
      );

  Map<String, Object> toJson() =>
      /**
     * Transforme un lien en dicionnaire
     *
     * result :
     *     - Map<String, Objet> le dictionnaire représentant le lien
     */
      {
        LienFields.ben: ben,
        LienFields.mission: mission,
        LienFields.dateDebut: dateDebut.toString(),
        LienFields.dateFin: dateFin.toString(),
      };
}
