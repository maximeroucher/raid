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
  List<String> ep;

  Equipe(int Id, int Num, String Nom, int Type, List<String> listeEp)
  /* Crée une équipe avec les paramètres donnés
  */
  {
    id = Id;
    num = Num;
    nom = Nom;
    type = Type;
    ep = listeEp;
    // Aucun temps n'est enregistré par défaut
    temps = [genTable(0), genTable(1)];
  }

  Map<String, DateTime> genTable(int type) {
    Map<String, DateTime> resp = {};
    this.ep.map((e) => resp[e] = null).toList();
    return resp;
  }

  // Crée une équipe vide (pour éviter des erreurs d'objet non défini)
  Equipe.empty() {}

  static Equipe fromJson(Map<String, Object> json, List<String> listeEp) { TODO: 
    /* Crée une équipe avec les paramètres donnés au format dictionnaire
    */
    Equipe e = Equipe(
        json[EquipeFields.id] as int,
        json[EquipeFields.num] as int,
        json[EquipeFields.nom] as String,
        json[EquipeFields.type] as int,
        listeEp);

    return e;
  }

  Map<String, Object> toJson() {
    // Transforme une équipe en dicionnaire
    Map<String, Object> resp = {
      EquipeFields.id: id,
      EquipeFields.num: num,
      EquipeFields.nom: nom,
      EquipeFields.type: type,
    };
    for (int x = 0; x < this.temps.length; x++) {
      for (String s in this.ep) {
        resp[(s + x.toString()).replaceAll(" ", "_").replaceAll("&", "\$")] =
            this.temps[x][s].toString();
      }
    }
    return resp;
  }

  Equipe copy({int id, int num, String nom, int type, List<String> listeEp}) =>
      // Copie l'équipe en changeant les données données
      Equipe(id ?? this.id, num ?? this.num, nom ?? this.nom, type ?? this.type,
          listeEp ?? this.ep);

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
