import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../features/intubation/domain/entities/intubation_entity.dart';
import '../../features/patient/domain/entities/patient_entity.dart';

class PdfService {
  static const List<String> _photoLabels = [
    'Vue de face',
    'Vue de profil',
    'Bouche ouverte',
    'LIP test face',
    'DD vue profil neutre',
    'DD vue profil en extension',
  ];

  static Future<void> generateAndShare(
    PatientEntity patient,
    IntubationEntity intubation,
  ) async {
    final document = pw.Document();
    final positiveAntecedents = _buildPositiveAntecedents(intubation);
    final logoBytes = await rootBundle.load(AppAssets.logo);
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Image(logoImage, width: 40, height: 40),
                pw.SizedBox(width: 12),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      AppStrings.appName,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(AppStrings.hospitalName),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              "Dossier d'Intubation Trachéale",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Date : ${DateFormatter.toDisplay(intubation.createdAt)}'),
            pw.SizedBox(height: 18),
            pw.Text(
              'Informations patient',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              data: [
                ['Nom', 'Prénom', 'Âge', 'Sexe', 'BMI'],
                [
                  patient.lastName,
                  patient.firstName,
                  '${patient.age} ans',
                  patient.sex,
                  patient.bmi.toStringAsFixed(1),
                ],
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              'Antécédents médicaux',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            if (positiveAntecedents.isEmpty)
              pw.Text('Aucun antécédent signalé')
            else
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: positiveAntecedents
                    .map((item) => pw.Bullet(text: item))
                    .toList(),
              ),
            if (intubation.acteOperatoire?.isNotEmpty == true) ...[
              pw.SizedBox(height: 8),
              pw.Text('Acte opératoire : ${intubation.acteOperatoire}'),
            ],
            if (intubation.scoreStopbang != null) ...[
              pw.SizedBox(height: 4),
              pw.Text('Score STOPBANG : ${intubation.scoreStopbang}'),
            ],
            pw.SizedBox(height: 18),
            pw.Text(
              'Évaluation clinique pré-intubation',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              data: [
                ['Paramètre', 'Valeur'],
                ['ASA', intubation.scoreAsa ?? '-'],
                ['Mallampati', intubation.mallampati ?? '-'],
                ['DTM', intubation.dtm ?? '-'],
                ['Ouverture buccale', intubation.ouvertureBuccale ?? '-'],
                ['Tour de cou', intubation.tourDeCou ?? '-'],
                ['Mobilité cervicale', intubation.mobiliteCervicale ?? '-'],
                ['Macroglossie', intubation.macroglossie ? 'Oui' : 'Non'],
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              'Risque prévu',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              intubation.intubationPrevue?.toUpperCase() ?? 'NON PRÉCISÉ',
              style: pw.TextStyle(
                color: intubation.intubationPrevue == 'Difficile'
                    ? PdfColors.red
                    : PdfColors.green,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              "Déroulement de l'acte",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              data: [
                [
                  'Type',
                  'Tentatives',
                  'Vidéolaryngoscope',
                  'Guide Eichmann',
                  'Cormack',
                ],
                [
                  intubation.typeIntubation ?? '-',
                  '${intubation.nombreTentatives ?? 1}',
                  intubation.videolaryngoscope ? 'Oui' : 'Non',
                  intubation.guideEichmann ? 'Oui' : 'Non',
                  intubation.scoreCormack ?? '-',
                ],
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              'Complications',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              intubation.intubationDifficileReelle
                  ? 'Intubation difficile réelle : Oui'
                  : 'Intubation difficile réelle : Non',
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              intubation.complications?.trim().isNotEmpty == true
                  ? intubation.complications!
                  : 'RAS',
            ),
            if (intubation.audioPath?.isNotEmpty == true) ...[
              pw.SizedBox(height: 8),
              pw.Text('Enregistrement audio disponible'),
            ],
          ];
        },
      ),
    );

    final photos = _buildPhotoEntries(intubation.photoPaths);
    if (photos.isNotEmpty) {
      final photoWidgets = <pw.Widget>[];
      for (var i = 0; i < photos.length; i += 2) {
        final rowChildren = <pw.Widget>[
          _PhotoCard(label: photos[i].label, path: photos[i].path),
        ];
        if (i + 1 < photos.length) {
          rowChildren.add(
            _PhotoCard(label: photos[i + 1].label, path: photos[i + 1].path),
          );
        } else {
          rowChildren.add(pw.SizedBox());
        }

        photoWidgets.add(
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: rowChildren[0]),
              pw.SizedBox(width: 12),
              pw.Expanded(child: rowChildren[1]),
            ],
          ),
        );
        photoWidgets.add(pw.SizedBox(height: 12));
      }

      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Text(
              'Photos cliniques',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            ...photoWidgets,
          ],
        ),
      );
    }

    final tempDirectory = await getTemporaryDirectory();
    final sanitizedLastName = patient.lastName.replaceAll(' ', '_');
    final file = File(
      '${tempDirectory.path}/dossier_intubation_${sanitizedLastName}_${intubation.id ?? 0}.pdf',
    );
    await file.writeAsBytes(await document.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Dossier d'intubation - ${patient.fullName}",
    );
  }

  static List<String> _buildPositiveAntecedents(IntubationEntity intubation) {
    final items = <String>[];

    if (intubation.antecedentIntubationDifficile) {
      items.add("Antécédent d'intubation difficile");
    }
    if (intubation.saos) {
      items.add('SAOS');
    }
    if (intubation.diabete) {
      items.add('Diabète');
    }
    if (intubation.goitre) {
      items.add('Goitre');
    }
    if (intubation.maladieRhumatismale) {
      items.add('Maladie rhumatismale');
    }
    if (intubation.traumatismeCervical) {
      items.add('Traumatisme cervical');
    }
    if (intubation.brulureCervicoFaciale) {
      items.add(
        'Brûlure cervico-faciale'
        '${intubation.brulureLocalisation != null ? ' (${intubation.brulureLocalisation})' : ''}',
      );
    }
    if (intubation.dysmorphieCranioFaciale) {
      items.add(
        'Dysmorphie crânio-faciale'
        '${intubation.dysmorphieLocalisation != null ? ' (${intubation.dysmorphieLocalisation})' : ''}',
      );
    }
    if (intubation.tumeurCervicofaciale) {
      items.add(
        'Tumeur cervicofaciale'
        '${intubation.tumeurLocalisation != null ? ' (${intubation.tumeurLocalisation})' : ''}',
      );
    }
    if (intubation.ronflement) {
      items.add('Ronflement');
    }
    if (intubation.dysphonie) {
      items.add('Dysphonie');
    }
    if (intubation.dysphagie) {
      items.add('Dysphagie');
    }

    return items;
  }

  static List<_PhotoEntry> _buildPhotoEntries(List<String> photoPaths) {
    final entries = <_PhotoEntry>[];

    for (var i = 0; i < photoPaths.length && i < _photoLabels.length; i++) {
      final path = photoPaths[i];
      if (path.isEmpty) {
        continue;
      }

      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }

      entries.add(_PhotoEntry(label: _photoLabels[i], path: path));
    }

    return entries;
  }
}

class _PhotoEntry {
  final String label;
  final String path;

  const _PhotoEntry({
    required this.label,
    required this.path,
  });
}

class _PhotoCard extends pw.StatelessWidget {
  final String label;
  final String path;

  _PhotoCard({
    required this.label,
    required this.path,
  });

  @override
  pw.Widget build(pw.Context context) {
    final file = File(path);
    final image = pw.MemoryImage(file.readAsBytesSync());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: 180,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
          ),
          child: pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(label),
      ],
    );
  }
}
