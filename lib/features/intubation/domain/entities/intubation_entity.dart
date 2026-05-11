import 'package:equatable/equatable.dart';

class IntubationEntity extends Equatable {
  final int? id;
  final int patientId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool antecedentIntubationDifficile;
  final bool saos;
  final bool diabete;
  final bool goitre;
  final bool maladieRhumatismale;
  final bool traumatismeCervical;
  final bool brulureCervicoFaciale;
  final String? brulureLocalisation;
  final bool dysmorphieCranioFaciale;
  final String? dysmorphieLocalisation;
  final bool tumeurCervicofaciale;
  final String? tumeurLocalisation;
  final bool ronflement;
  final bool dysphonie;
  final bool dysphagie;
  final String? acteOperatoire;
  final int? scoreStopbang;
  final String? mallampati;
  final String? dtm;
  final String? ouvertureBuccale;
  final String? tourDeCou;
  final String? mobiliteCervicale;
  final bool macroglossie;
  final String? scoreAsa;
  final String? intubationPrevue;
  final String? typeIntubation;
  final int? nombreTentatives;
  final bool videolaryngoscope;
  final bool guideEichmann;
  final String? scoreCormack;
  final bool intubationDifficileReelle;
  final String? complications;
  final List<String> photoPaths;
  final String? audioPath;

  const IntubationEntity({
    this.id,
    required this.patientId,
    required this.createdAt,
    required this.updatedAt,
    this.antecedentIntubationDifficile = false,
    this.saos = false,
    this.diabete = false,
    this.goitre = false,
    this.maladieRhumatismale = false,
    this.traumatismeCervical = false,
    this.brulureCervicoFaciale = false,
    this.brulureLocalisation,
    this.dysmorphieCranioFaciale = false,
    this.dysmorphieLocalisation,
    this.tumeurCervicofaciale = false,
    this.tumeurLocalisation,
    this.ronflement = false,
    this.dysphonie = false,
    this.dysphagie = false,
    this.acteOperatoire,
    this.scoreStopbang,
    this.mallampati,
    this.dtm,
    this.ouvertureBuccale,
    this.tourDeCou,
    this.mobiliteCervicale,
    this.macroglossie = false,
    this.scoreAsa,
    this.intubationPrevue,
    this.typeIntubation,
    this.nombreTentatives,
    this.videolaryngoscope = false,
    this.guideEichmann = false,
    this.scoreCormack,
    this.intubationDifficileReelle = false,
    this.complications,
    this.photoPaths = const [],
    this.audioPath,
  });

  IntubationEntity copyWith({
    int? id,
    int? patientId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? antecedentIntubationDifficile,
    bool? saos,
    bool? diabete,
    bool? goitre,
    bool? maladieRhumatismale,
    bool? traumatismeCervical,
    bool? brulureCervicoFaciale,
    String? brulureLocalisation,
    bool clearBrulureLocalisation = false,
    bool? dysmorphieCranioFaciale,
    String? dysmorphieLocalisation,
    bool clearDysmorphieLocalisation = false,
    bool? tumeurCervicofaciale,
    String? tumeurLocalisation,
    bool clearTumeurLocalisation = false,
    bool? ronflement,
    bool? dysphonie,
    bool? dysphagie,
    String? acteOperatoire,
    bool clearActeOperatoire = false,
    int? scoreStopbang,
    bool clearScoreStopbang = false,
    String? mallampati,
    String? dtm,
    String? ouvertureBuccale,
    String? tourDeCou,
    String? mobiliteCervicale,
    bool? macroglossie,
    String? scoreAsa,
    String? intubationPrevue,
    String? typeIntubation,
    int? nombreTentatives,
    bool? videolaryngoscope,
    bool? guideEichmann,
    String? scoreCormack,
    bool? intubationDifficileReelle,
    String? complications,
    bool clearComplications = false,
    List<String>? photoPaths,
    String? audioPath,
    bool clearAudioPath = false,
  }) {
    return IntubationEntity(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      antecedentIntubationDifficile:
          antecedentIntubationDifficile ?? this.antecedentIntubationDifficile,
      saos: saos ?? this.saos,
      diabete: diabete ?? this.diabete,
      goitre: goitre ?? this.goitre,
      maladieRhumatismale:
          maladieRhumatismale ?? this.maladieRhumatismale,
      traumatismeCervical: traumatismeCervical ?? this.traumatismeCervical,
      brulureCervicoFaciale:
          brulureCervicoFaciale ?? this.brulureCervicoFaciale,
      brulureLocalisation: clearBrulureLocalisation
          ? null
          : brulureLocalisation ?? this.brulureLocalisation,
      dysmorphieCranioFaciale:
          dysmorphieCranioFaciale ?? this.dysmorphieCranioFaciale,
      dysmorphieLocalisation: clearDysmorphieLocalisation
          ? null
          : dysmorphieLocalisation ?? this.dysmorphieLocalisation,
      tumeurCervicofaciale:
          tumeurCervicofaciale ?? this.tumeurCervicofaciale,
      tumeurLocalisation: clearTumeurLocalisation
          ? null
          : tumeurLocalisation ?? this.tumeurLocalisation,
      ronflement: ronflement ?? this.ronflement,
      dysphonie: dysphonie ?? this.dysphonie,
      dysphagie: dysphagie ?? this.dysphagie,
      acteOperatoire:
          clearActeOperatoire ? null : acteOperatoire ?? this.acteOperatoire,
      scoreStopbang:
          clearScoreStopbang ? null : scoreStopbang ?? this.scoreStopbang,
      mallampati: mallampati ?? this.mallampati,
      dtm: dtm ?? this.dtm,
      ouvertureBuccale: ouvertureBuccale ?? this.ouvertureBuccale,
      tourDeCou: tourDeCou ?? this.tourDeCou,
      mobiliteCervicale: mobiliteCervicale ?? this.mobiliteCervicale,
      macroglossie: macroglossie ?? this.macroglossie,
      scoreAsa: scoreAsa ?? this.scoreAsa,
      intubationPrevue: intubationPrevue ?? this.intubationPrevue,
      typeIntubation: typeIntubation ?? this.typeIntubation,
      nombreTentatives: nombreTentatives ?? this.nombreTentatives,
      videolaryngoscope: videolaryngoscope ?? this.videolaryngoscope,
      guideEichmann: guideEichmann ?? this.guideEichmann,
      scoreCormack: scoreCormack ?? this.scoreCormack,
      intubationDifficileReelle:
          intubationDifficileReelle ?? this.intubationDifficileReelle,
      complications:
          clearComplications ? null : complications ?? this.complications,
      photoPaths: photoPaths ?? this.photoPaths,
      audioPath: clearAudioPath ? null : audioPath ?? this.audioPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        createdAt,
        updatedAt,
        antecedentIntubationDifficile,
        saos,
        diabete,
        goitre,
        maladieRhumatismale,
        traumatismeCervical,
        brulureCervicoFaciale,
        brulureLocalisation,
        dysmorphieCranioFaciale,
        dysmorphieLocalisation,
        tumeurCervicofaciale,
        tumeurLocalisation,
        ronflement,
        dysphonie,
        dysphagie,
        acteOperatoire,
        scoreStopbang,
        mallampati,
        dtm,
        ouvertureBuccale,
        tourDeCou,
        mobiliteCervicale,
        macroglossie,
        scoreAsa,
        intubationPrevue,
        typeIntubation,
        nombreTentatives,
        videolaryngoscope,
        guideEichmann,
        scoreCormack,
        intubationDifficileReelle,
        complications,
        photoPaths,
        audioPath,
      ];
}
