// Cette classe sert uniquement pour la base de donnée afin de lier les bénévoles à leurs missions

// Le nom de la table dans la base de donnée
final String tableLien = "lien";

// La classe contenant les noms des colonnes dans la base de données
class LienFields {
  // La liste des noms
  static final List<String> values = [
    ben,
    mission,
  ];

  // Le nom des colonnes dans la base de donnée
  static final String ben = "benevole";
  static final String mission = "mission";
}

// La représentation d'un lien entre un bénévole et une mission
class Lien {
  // Le bénévole (son identifiant)
  int ben = 0;
  // La mission (son identifiant)
  int mission = 0;


  Lien(int B, int M)
  /* Crée un lien entre le bénévole donné et la mission donnée
  */
  {
    ben = B;
    mission = M;
  }

  static Lien fromJson(Map<String, Object> json) =>
  /* Crée un lien entre le bénévole donné et la mission donnée au format dictionnaire
  */
    Lien(
      json[LienFields.ben] as int,
      json[LienFields.mission] as int,
    );

  Map<String, Object> toJson() =>
  /* Crée le dictionnaire représentant le lien
  */
    {
      LienFields.ben: ben,
      LienFields.mission: mission,
    };
}
