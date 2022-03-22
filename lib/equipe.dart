// Le nom de la table dans la base de donnée
const String tableEquipe = "equipe";

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
  static const String id = "id";
  static const String nom = "nom";
  static const String num = "num";
  static const String type = "type";
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

  Equipe(int Id, int Num, String Nom, int Type, List<String> listeEp) {
    /**
   * Crée une équipe avec les paramètres donnés
   *
   * param :
   *     - Id (int) l'identifiant de l'équipe
   *     - Num (int) le numéro de l'équipe
   *     - Nom (String) le nom de l'équipe
   *     - Type (int) le type de parcours que fait l'équipe
   *     - listeEp (List<String>) la liste des épreuves
  */
    id = Id;
    num = Num;
    nom = Nom;
    type = Type;
    ep = listeEp;
    // Aucun temps n'est enregistré par défaut
    temps = [genTable(0), genTable(1)];
  }

  Map<String, DateTime> genTable(int type) {
    /**
     * Génère le dictionnaire du temps des épreuves 0 pour le départ et 1 pour l'arrivée
     */
    Map<String, DateTime> resp = {};
    ep.map((e) => resp[e] = null).toList();
    return resp;
  }

  Equipe.empty() {
    /**
     * Crée une équipe vide, pour éviter des erreurs d'objet non défini
     */
  }

  static Equipe fromJson(Map<String, Object> json, List<String> listeEp) {
    /**
     * Crée une équipe avec les paramètres donnés au format dictionnaire
     *
     * param :
     *     - json (Map<String, Objet>) le dictionnaire contenant les valeurs permettant de générer une équipe
     *     - listeEp (List<Strin>) la liste des épreuves
     *
     * result :
     *     Equipe
    */
    // On crée une équipe de manière classique
    Equipe e = Equipe(
        json[EquipeFields.id] as int,
        json[EquipeFields.num] as int,
        json[EquipeFields.nom] as String,
        json[EquipeFields.type] as int,
        listeEp);
    // Pour chaque clée du dictionnaire
    for (String key in json.keys) {
      // Si c'est une épreuve
      if (!EquipeFields.values.contains(key)) {
        // On reformatte la clée pour le dictionnaire
        var ckey = key.replaceAll("_", " ").replaceAll("\$", "&");
        // On regarde dans quel tableau doit être stocké le temps
        int pos = int.parse(ckey.substring(ckey.length - 1));
        // On récupère le nom de l'épreuve
        String ep = ckey.substring(0, ckey.length - 1);
        // S'il y a un temps, on le met à sa place
        if (json[key] != "null") {
          e.temps[pos][ep] = DateTime.parse(json[key] as String);
          // Sinon on met null
        } else {
          e.temps[pos][ep] = null;
        }
      }
    }
    return e;
  }

  Map<String, Object> toJson() {
    /**
     * Transforme une équipe en dicionnaire
     *
     * result :
     *     - Map<String, Objet> le dictionnaire représentant l'équipe
     */
    // On crée le dictionnaire avec les colonnes connues
    Map<String, Object> resp = {
      EquipeFields.id: id,
      EquipeFields.num: num,
      EquipeFields.nom: nom,
      EquipeFields.type: type,
    };
    // Pour les départs et arrivée
    for (int x = 0; x < temps.length; x++) {
      // Pour chaque épreuve
      for (String s in temps[x].keys) {
        // On met dans le dictionnaire la valeur du temps
        resp[(s + x.toString()).replaceAll(" ", "_").replaceAll("&", "\$")] =
            temps[x][s].toString();
      }
    }
    return resp;
  }

  Equipe copy({int id, int num, String nom, int type, List<String> listeEp}) =>
      /**
       * Copie l'équipe en changeant les données données
       *
       * param :
       *     - Id (int) l'identifiant de l'équipe
       *     - Num (int) le numéro de l'équipe
       *     - Nom (String) le nom de l'équipe
       *     - Type (int) le type de parcours que fait l'équipe
       *     - listeEp (List<String>) la liste des épreuves
       *
       * result :
       *     - Equipe
       */
      Equipe(id ?? this.id, num ?? this.num, nom ?? this.nom, type ?? this.type,
          listeEp ?? ep);

  String getTypeString() {
    /**
     * Retourne le texte associé au type de course
     *
     * result :
     *     - String
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
