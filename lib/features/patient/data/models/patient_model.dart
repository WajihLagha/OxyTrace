import '../../domain/entities/patient_entity.dart';

class PatientModel extends PatientEntity {
  const PatientModel({
    super.id,
    required super.firstName,
    required super.lastName,
    required super.phone,
    required super.sex,
    required super.birthDate,
    required super.bmi,
    super.isSynced = false,
    required super.createdAt,
    required super.updatedAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'sex': sex,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'bmi': bmi,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'] as int?,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      phone: map['phone'] as String?,
      sex: map['sex'] as String,
      birthDate: DateTime.parse(map['birth_date'] as String),
      bmi: (map['bmi'] as num).toDouble(),
      isSynced: ((map['is_synced'] as int?) ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  factory PatientModel.fromEntity(PatientEntity entity) {
    return PatientModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      sex: entity.sex,
      birthDate: entity.birthDate,
      bmi: entity.bmi,
      isSynced: entity.isSynced,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  PatientModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? sex,
    DateTime? birthDate,
    double? bmi,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      bmi: bmi ?? this.bmi,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
