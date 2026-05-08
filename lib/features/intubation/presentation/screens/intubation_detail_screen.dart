import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/services/pdf_service.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../../patient/domain/entities/patient_entity.dart';
import '../../domain/entities/intubation_entity.dart';
import '../cubit/intubation_cubit.dart';
import '../cubit/intubation_state.dart';
import 'intubation_form_screen.dart';

class IntubationDetailScreen extends StatefulWidget {
  final IntubationEntity intubation;
  final PatientEntity patient;

  const IntubationDetailScreen({
    super.key,
    required this.intubation,
    required this.patient,
  });

  @override
  State<IntubationDetailScreen> createState() => _IntubationDetailScreenState();
}

class _IntubationDetailScreenState extends State<IntubationDetailScreen> {
  static const List<String> _photoLabels = [
    'Vue de face',
    'Vue de profil',
    'Bouche ouverte',
    'DD profil neutre',
    'DD profil en extension',
    'Autre',
  ];

  late IntubationEntity _intubation;

  @override
  void initState() {
    super.initState();
    _intubation = widget.intubation;
  }

  String _cormackDescription(String? grade) {
    return switch (grade) {
      'I' => 'Glotte entièrement visible',
      'II' => 'Seule la partie postérieure est visible',
      'III' => "Seulement l'épiglotte est visible",
      'IV' => "Ni l'épiglotte ni la glotte ne sont visibles",
      _ => '-',
    };
  }

  Color get _riskColor =>
      _intubation.intubationPrevue == 'Difficile'
          ? AppColors.danger
          : AppColors.success;

  List<_LabeledPhoto> get _photos {
    final photos = <_LabeledPhoto>[];
    for (var i = 0;
        i < _intubation.photoPaths.length && i < _photoLabels.length;
        i++) {
      final path = _intubation.photoPaths[i];
      if (path.isEmpty || !File(path).existsSync()) {
        continue;
      }
      photos.add(_LabeledPhoto(label: _photoLabels[i], path: path));
    }
    return photos;
  }

  List<String> _activeAntecedents() {
    final items = <String>[];
    if (_intubation.antecedentIntubationDifficile) {
      items.add("Antécédent d'intubation difficile");
    }
    if (_intubation.saos) {
      items.add('SAOS');
    }
    if (_intubation.diabete) {
      items.add('Diabète');
    }
    if (_intubation.goitre) {
      items.add('Goitre');
    }
    if (_intubation.maladieRhumatismale) {
      items.add('Maladie rhumatismale');
    }
    if (_intubation.traumatismeCervical) {
      items.add('Traumatisme cervical');
    }
    if (_intubation.brulureCervicoFaciale) {
      items.add(
        _intubation.brulureLocalisation?.isNotEmpty == true
            ? 'Brûlure : ${_intubation.brulureLocalisation}'
            : 'Brûlure cervico-faciale',
      );
    }
    if (_intubation.dysmorphieCranioFaciale) {
      items.add(
        _intubation.dysmorphieLocalisation?.isNotEmpty == true
            ? 'Dysmorphie : ${_intubation.dysmorphieLocalisation}'
            : 'Dysmorphie crânio-faciale',
      );
    }
    if (_intubation.tumeurCervicofaciale) {
      items.add(
        _intubation.tumeurLocalisation?.isNotEmpty == true
            ? 'Tumeur : ${_intubation.tumeurLocalisation}'
            : 'Tumeur cervicofaciale',
      );
    }
    if (_intubation.ronflement) {
      items.add('Ronflement');
    }
    if (_intubation.dysphonie) {
      items.add('Dysphonie');
    }
    if (_intubation.dysphagie) {
      items.add('Dysphagie');
    }
    return items;
  }

  Future<void> _openEditScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => IntubationFormScreen(
          patient: widget.patient,
          intubation: _intubation,
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer le dossier'),
          content: const Text(
            "Voulez-vous vraiment supprimer ce dossier d'intubation ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && _intubation.id != null && mounted) {
      await context.read<IntubationCubit>().deleteIntubation(_intubation.id!);
    }
  }

  Future<void> _generatePdf() async {
    try {
      await PdfService.generateAndShare(widget.patient, _intubation);
    } catch (_) {
      if (!mounted) {
        return;
      }
      showErrorSnackBar(
        context,
        'Impossible de générer le PDF pour le moment.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final antecedents = _activeAntecedents();
    final photos = _photos;

    return BlocListener<IntubationCubit, IntubationState>(
      listener: (context, state) {
        if (state is IntubationOperationSuccess &&
            state.intubation.id == _intubation.id) {
          setState(() {
            _intubation = state.intubation;
          });
        } else if (state is IntubationDeleted) {
          Navigator.of(context).pop();
        } else if (state is IntubationError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dossier d'intubation"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(28),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                DateFormatter.toDisplay(_intubation.createdAt),
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: _openEditScreen,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _riskColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _riskColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _intubation.intubationPrevue == 'Difficile'
                        ? 'Intubation Difficile'
                        : 'Intubation Facile',
                    style: TextStyle(
                      color: _riskColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '${DateFormatter.toDisplay(_intubation.createdAt)} · '
                  '${_intubation.nombreTentatives ?? 1} tentative(s)',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 20),
              ExpansionTile(
                initiallyExpanded: true,
                title: const Text('Antécédents médicaux'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  if (antecedents.isEmpty)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Aucun antécédent signalé.'),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: antecedents
                          .map(
                            (item) => Chip(
                              label: Text(item),
                              backgroundColor:
                                  AppColors.surfaceVariant.withValues(alpha: 0.8),
                            ),
                          )
                          .toList(),
                    ),
                  if (_intubation.acteOperatoire?.isNotEmpty == true) ...[
                    const SizedBox(height: 14),
                    InfoRow(
                      label: 'Acte opératoire',
                      value: _intubation.acteOperatoire!,
                    ),
                  ],
                  if (_intubation.scoreStopbang != null)
                    InfoRow(
                      label: 'Score STOPBANG',
                      value: '${_intubation.scoreStopbang}',
                    ),
                ],
              ),
              ExpansionTile(
                title: const Text('Évaluation clinique'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  InfoRow(label: 'ASA', value: _intubation.scoreAsa ?? '-'),
                  InfoRow(
                    label: 'Mallampati',
                    value: _intubation.mallampati ?? '-',
                  ),
                  InfoRow(label: 'DTM', value: _intubation.dtm ?? '-'),
                  InfoRow(
                    label: 'Ouverture buccale',
                    value: _intubation.ouvertureBuccale ?? '-',
                  ),
                  InfoRow(
                    label: 'Tour de cou',
                    value: _intubation.tourDeCou ?? '-',
                  ),
                  InfoRow(
                    label: 'Mobilité cervicale',
                    value: _intubation.mobiliteCervicale ?? '-',
                  ),
                  InfoRow(
                    label: 'Macroglossie',
                    value: _intubation.macroglossie ? 'Oui' : 'Non',
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Risque prévu'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(_intubation.intubationPrevue ?? '-'),
                      backgroundColor: _riskColor.withValues(alpha: 0.18),
                      side: BorderSide(color: _riskColor.withValues(alpha: 0.32)),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text("Déroulement de l'acte"),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  InfoRow(
                    label: "Type d'intubation",
                    value: _intubation.typeIntubation ?? '-',
                  ),
                  InfoRow(
                    label: 'Tentatives',
                    value: '${_intubation.nombreTentatives ?? 1}',
                  ),
                  InfoRow(
                    label: 'Vidéolaryngoscope',
                    value: _intubation.videolaryngoscope ? 'Oui' : 'Non',
                  ),
                  InfoRow(
                    label: "Guide d'Eichmann",
                    value: _intubation.guideEichmann ? 'Oui' : 'Non',
                  ),
                  InfoRow(
                    label: 'Cormack',
                    value: _intubation.scoreCormack ?? '-',
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _cormackDescription(_intubation.scoreCormack),
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Complications'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        _intubation.intubationDifficileReelle
                            ? 'Intubation difficile réelle'
                            : 'Pas de difficulté réelle',
                      ),
                      backgroundColor: _intubation.intubationDifficileReelle
                          ? AppColors.warning.withValues(alpha: 0.18)
                          : AppColors.success.withValues(alpha: 0.18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _intubation.complications?.trim().isNotEmpty == true
                          ? _intubation.complications!
                          : 'Aucune complication signalée',
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Photos'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  if (photos.isEmpty)
                    const EmptyState(
                      icon: Icons.photo_library_outlined,
                      title: 'Aucune photo disponible',
                      subtitle: 'Les photos cliniques apparaîtront ici.',
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: photos.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final photo = photos[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => _PhotoViewerScreen(
                                  imagePath: photo.path,
                                  label: photo.label,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    File(photo.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                photo.label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _generatePdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Générer PDF'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _confirmDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                      child: const Text('Supprimer le dossier'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledPhoto {
  final String label;
  final String path;

  const _LabeledPhoto({
    required this.label,
    required this.path,
  });
}

class _PhotoViewerScreen extends StatelessWidget {
  final String imagePath;
  final String label;

  const _PhotoViewerScreen({
    required this.imagePath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: InteractiveViewer(
        child: Center(
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }
}
