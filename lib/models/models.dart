class User {
  final int id;
  final String nomComplet;
  final String email;
  final String login;

  User({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.login,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nomComplet: (json['nomComplet'] ?? json['nom_complet'] ?? json['name'] ?? 'User').toString(),
      email: (json['email'] ?? '').toString(),
      login: (json['login'] ?? '').toString(),
    );
  }
}

class Child {
  final int id;
  final String nom;
  final String prenom;
  final String? dateNaissance;
  final String? groupeAge;
  final String statut;

  Child({
    required this.id,
    required this.nom,
    required this.prenom,
    this.dateNaissance,
    this.groupeAge,
    required this.statut,
  });

  String get fullName => '$prenom $nom';

  factory Child.fromJson(Map<String, dynamic> json) {
    var idValue = json['enfant_id'] ?? json['id'];
    int childId = 0;
    if (idValue is int) {
      childId = idValue;
    } else if (idValue != null) {
      childId = int.tryParse(idValue.toString()) ?? 0;
    }

    return Child(
      id: childId,
      nom: (json['nom'] ?? '').toString(),
      prenom: (json['prenom'] ?? '').toString(),
      dateNaissance: json['date_naissance']?.toString(),
      groupeAge: json['groupe_age']?.toString(),
      statut: (json['statut'] ?? 'Actif').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enfant_id': id,
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'date_naissance': dateNaissance,
      'groupe_age': groupeAge,
      'statut': statut,
    };
  }
}

class Attendance {
  final int id;
  final int childId;
  final String date;
  final String? statut;
  final String? heurreArrivee;
  final String? heureRetard;
  final String? heurreDepart;
  final bool repassMidi;
  final bool repasGouter;
  final String? notes;

  Attendance({
    required this.id,
    required this.childId,
    required this.date,
    this.statut,
    this.heurreArrivee,
    this.heureRetard,
    this.heurreDepart,
    required this.repassMidi,
    required this.repasGouter,
    this.notes,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    var idVal = json['id'];
    int id = idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '0') ?? 0;
    
    var childIdVal = json['enfant_id'];
    int childId = childIdVal is int ? childIdVal : int.tryParse(childIdVal?.toString() ?? '0') ?? 0;
    
    return Attendance(
      id: id,
      childId: childId,
      date: (json['date'] ?? '').toString(),
      statut: json['statut']?.toString(),
      heurreArrivee: json['heure_arrivee']?.toString(),
      heureRetard: json['heure_retard']?.toString(),
      heurreDepart: json['heure_depart']?.toString(),
      repassMidi: json['repas_midi'] == true || json['repas_midi'] == 1 || json['repas_midi'] == '1',
      repasGouter: json['repas_gouter'] == true || json['repas_gouter'] == 1 || json['repas_gouter'] == '1',
      notes: json['notes']?.toString(),
    );
  }
}

class Communication {
  final int id;
  final String titre;
  final String message;
  final String dateEnvoi;
  final String typeCommunication;
  final String? nomAuteur;

  Communication({
    required this.id,
    required this.titre,
    required this.message,
    required this.dateEnvoi,
    required this.typeCommunication,
    this.nomAuteur,
  });

  factory Communication.fromJson(Map<String, dynamic> json) {
    var idVal = json['id'];
    int id = idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '0') ?? 0;
    
    return Communication(
      id: id,
      titre: (json['titre'] ?? 'No Title').toString(),
      message: (json['message'] ?? '').toString(),
      dateEnvoi: (json['date_envoi'] ?? '').toString(),
      typeCommunication: (json['type_communication'] ?? 'general').toString(),
      nomAuteur: json['auteur']?.toString() ?? 'School',
    );
  }
}

class Activity {
  final int id;
  final String titre;
  final String? description;
  final String dateDebut;
  final String? dateFin;
  final String? lieu;
  final String? animateur;
  final int? nombreParticipants;
  final String statut;

  Activity({
    required this.id,
    required this.titre,
    this.description,
    required this.dateDebut,
    this.dateFin,
    this.lieu,
    this.animateur,
    this.nombreParticipants,
    required this.statut,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    var idVal = json['id'];
    int id = idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '0') ?? 0;
    
    var countVal = json['nombre_participants'];
    int? count;
    if (countVal is int) {
      count = countVal;
    } else if (countVal != null) {
      count = int.tryParse(countVal.toString());
    }

    return Activity(
      id: id,
      titre: (json['titre'] ?? '').toString(),
      description: json['description']?.toString(),
      dateDebut: (json['date_debut'] ?? '').toString(),
      dateFin: json['date_fin']?.toString(),
      lieu: json['lieu']?.toString(),
      animateur: json['animateur']?.toString(),
      nombreParticipants: count,
      statut: (json['statut'] ?? 'Planifiée').toString(),
    );
  }
}

class Payment {
  final int id;
  final int childId;
  final double montant;
  final String datePaiement;
  final String methode;
  final String statut;
  final String? reference;

  Payment({
    required this.id,
    required this.childId,
    required this.montant,
    required this.datePaiement,
    required this.methode,
    required this.statut,
    this.reference,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    var idVal = json['id'];
    int id = idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '0') ?? 0;
    
    var childIdVal = json['enfant_id'];
    int childId = childIdVal is int ? childIdVal : int.tryParse(childIdVal?.toString() ?? '0') ?? 0;
    
    var montantVal = json['montant'];
    double montant = 0.0;
    if (montantVal is double) {
      montant = montantVal;
    } else if (montantVal is int) {
      montant = montantVal.toDouble();
    } else if (montantVal != null) {
      montant = double.tryParse(montantVal.toString()) ?? 0.0;
    }

    return Payment(
      id: id,
      childId: childId,
      montant: montant,
      datePaiement: (json['date_paiement'] ?? '').toString(),
      methode: (json['methode'] ?? 'Unknown').toString(),
      statut: (json['statut'] ?? 'Pending').toString(),
      reference: json['reference']?.toString(),
    );
  }
}
