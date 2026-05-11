import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/segmented_selector.dart';
import '../../../../shared/widgets/step_progress_bar.dart';
import '../../../patient/domain/entities/patient_entity.dart';
import '../../domain/entities/intubation_entity.dart';
import '../cubit/intubation_cubit.dart';
import '../cubit/intubation_state.dart';

class IntubationFormScreen extends StatefulWidget {
  final PatientEntity patient;
  final IntubationEntity? intubation;

  const IntubationFormScreen({
    super.key,
    required this.patient,
    this.intubation,
  });

  @override
  State<IntubationFormScreen> createState() => _IntubationFormScreenState();
}

class _IntubationFormScreenState extends State<IntubationFormScreen> {
  static const List<String> _stepTitles = [
    'Antécédents médicaux',
    'Évaluation clinique',
    'Évaluation du risque',
    'Données per-intubation',
    'Difficultés et complications',
    'Données complémentaires',
  ];

  static const List<String> _photoLabels = [
    'Vue de face',
    'Vue de profil',
    'Bouche ouverte',
    'LIP test face',
    'DD vue profil neutre',
    'DD vue profil en extension',
  ];

  static const List<String> _phonemes = ['أ', 'خ', 'ه', 'ح', 'غ', 'ع'];

  final PageController _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  final TextEditingController _brulureController = TextEditingController();
  final TextEditingController _dysmorphieController = TextEditingController();
  final TextEditingController _tumeurController = TextEditingController();
  final TextEditingController _acteController = TextEditingController();
  final TextEditingController _complicationsController =
      TextEditingController();

  Timer? _phonemeTimer;
  Timer? _recordingTimeoutTimer;

  late IntubationEntity _draft;
  int _currentStep = 0;
  int? _activePhonemeIndex;
  bool _showStep2Errors = false;
  bool _showStep3Errors = false;
  bool _showStep4Errors = false;
  bool _isRecording = false;
  bool _hasRecording = false;
  String? _localAudioPath;

  bool get _isEditMode => widget.intubation != null;

  @override
  void initState() {
    super.initState();
    _draft = _buildInitialDraft();
    _brulureController.text = _draft.brulureLocalisation ?? '';
    _dysmorphieController.text = _draft.dysmorphieLocalisation ?? '';
    _tumeurController.text = _draft.tumeurLocalisation ?? '';
    _acteController.text = _draft.acteOperatoire ?? '';
    _complicationsController.text = _draft.complications ?? '';
    _localAudioPath = _draft.audioPath;
    _hasRecording = _localAudioPath?.isNotEmpty == true;
  }

  @override
  void dispose() {
    _phonemeTimer?.cancel();
    _recordingTimeoutTimer?.cancel();
    _pageController.dispose();
    _brulureController.dispose();
    _dysmorphieController.dispose();
    _tumeurController.dispose();
    _acteController.dispose();
    _complicationsController.dispose();
    _audioRecorder.dispose();
    _player.dispose();
    super.dispose();
  }

  IntubationEntity _buildInitialDraft() {
    final existing = widget.intubation;
    if (existing != null) {
      return existing.copyWith(
        photoPaths: _normalizePhotoPaths(existing.photoPaths),
      );
    }

    final now = DateTime.now();
    return IntubationEntity(
      patientId: widget.patient.id!,
      createdAt: now,
      updatedAt: now,
      nombreTentatives: 1,
      photoPaths: List<String>.filled(_photoLabels.length, ''),
    );
  }

  List<String> _normalizePhotoPaths(List<String> source) {
    final normalized = List<String>.filled(_photoLabels.length, '');
    for (var i = 0; i < source.length && i < normalized.length; i++) {
      normalized[i] = source[i];
    }
    return normalized;
  }

  Future<void> _goToStep(int index) async {
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentStep = index;
    });
  }

  Future<void> _previousStep() async {
    if (_currentStep == 0) {
      return;
    }

    await _goToStep(_currentStep - 1);
  }

  Future<void> _nextStep() async {
    final isValid = _validateCurrentStep();
    if (!isValid) {
      return;
    }

    if (_currentStep < _stepTitles.length - 1) {
      await _goToStep(_currentStep + 1);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        final isValid = _draft.scoreAsa != null &&
            _draft.mallampati != null &&
            _draft.dtm != null &&
            _draft.ouvertureBuccale != null &&
            _draft.tourDeCou != null &&
            _draft.mobiliteCervicale != null;
        setState(() {
          _showStep2Errors = !isValid;
        });
        return isValid;
      case 2:
        final isValid = _draft.intubationPrevue != null;
        setState(() {
          _showStep3Errors = !isValid;
        });
        return isValid;
      case 3:
        final isValid = _draft.typeIntubation != null &&
            _draft.scoreCormack != null &&
            (_draft.nombreTentatives ?? 0) >= 1;
        setState(() {
          _showStep4Errors = !isValid;
        });
        return isValid;
      default:
        return true;
    }
  }

  List<String> _missingSections() {
    final missing = <String>[];

    if (_draft.scoreAsa == null ||
        _draft.mallampati == null ||
        _draft.dtm == null ||
        _draft.ouvertureBuccale == null ||
        _draft.tourDeCou == null ||
        _draft.mobiliteCervicale == null) {
      missing.add('Évaluation clinique');
    }

    if (_draft.intubationPrevue == null) {
      missing.add('Évaluation du risque');
    }

    if (_draft.typeIntubation == null ||
        _draft.scoreCormack == null ||
        (_draft.nombreTentatives ?? 0) < 1) {
      missing.add('Données per-intubation');
    }

    return missing;
  }

  Future<void> _saveIntubation() async {
    setState(() {
      _showStep2Errors = true;
      _showStep3Errors = true;
      _showStep4Errors = true;
    });

    final missingSections = _missingSections();
    if (missingSections.isNotEmpty) {
      showErrorSnackBar(
        context,
        'Sections incomplètes : ${missingSections.join(', ')}.',
      );
      return;
    }

    final payload = _draft.copyWith(
      updatedAt: DateTime.now(),
      audioPath: _localAudioPath,
      clearAudioPath: _localAudioPath == null || _localAudioPath!.isEmpty,
    );

    if (_isEditMode) {
      await context.read<IntubationCubit>().updateIntubation(payload);
      return;
    }

    await context.read<IntubationCubit>().createIntubation(payload);
  }

  Future<void> _pickImage(int index) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.of(bottomSheetContext).pop(
                  ImageSource.camera,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Navigator.of(bottomSheetContext).pop(
                  ImageSource.gallery,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      final documentsDirectory = await getApplicationDocumentsDirectory();
      final imagesDirectory = Directory(
        '${documentsDirectory.path}/intubation_photos',
      );
      await imagesDirectory.create(recursive: true);

      final extension = pickedFile.path.contains('.')
          ? pickedFile.path.split('.').last
          : 'jpg';
      final destinationPath =
          '${imagesDirectory.path}/patient_${widget.patient.id}_'
          'slot_${index}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final savedFile = await File(pickedFile.path).copy(destinationPath);
      final updatedPaths = _normalizePhotoPaths(_draft.photoPaths);
      final previousPath = updatedPaths[index];
      updatedPaths[index] = savedFile.path;

      if (previousPath.isNotEmpty && previousPath != savedFile.path) {
        final previousFile = File(previousPath);
        if (await previousFile.exists()) {
          await previousFile.delete();
        }
      }

      setState(() {
        _draft = _draft.copyWith(photoPaths: updatedPaths);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      showErrorSnackBar(
        context,
        "Impossible d'ajouter la photo pour le moment.",
      );
    }
  }

  Future<void> _removeImage(int index) async {
    final updatedPaths = _normalizePhotoPaths(_draft.photoPaths);
    final path = updatedPaths[index];
    updatedPaths[index] = '';

    try {
      if (path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {}

    if (!mounted) {
      return;
    }

    setState(() {
      _draft = _draft.copyWith(photoPaths: updatedPaths);
    });
  }

  Future<void> _startRecording() async {
    if (_isRecording) {
      return;
    }

    final permissionStatus = await Permission.microphone.request();
    if (!permissionStatus.isGranted) {
      if (!mounted) {
        return;
      }
      showErrorSnackBar(
        context,
        'Veuillez autoriser le microphone pour enregistrer.',
      );
      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) {
        return;
      }
      showErrorSnackBar(
        context,
        "Le microphone n'est pas disponible pour le moment.",
      );
      return;
    }

    try {
      await _player.stop();

      final documentsDirectory = await getApplicationDocumentsDirectory();
      final audioDirectory = Directory(
        '${documentsDirectory.path}/intubation_audio',
      );
      await audioDirectory.create(recursive: true);

      final audioPath =
          '${audioDirectory.path}/intubation_'
          '${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(),
        path: audioPath,
      );

      _phonemeTimer?.cancel();
      _recordingTimeoutTimer?.cancel();

      setState(() {
        _isRecording = true;
        _activePhonemeIndex = 0;
      });

      _phonemeTimer = Timer.periodic(
        const Duration(milliseconds: 1500),
        (timer) {
          if (!mounted || !_isRecording) {
            timer.cancel();
            return;
          }

          setState(() {
            _activePhonemeIndex =
                (_activePhonemeIndex == null || _activePhonemeIndex == 5)
                    ? 0
                    : _activePhonemeIndex! + 1;
          });
        },
      );

      _recordingTimeoutTimer = Timer(
        const Duration(seconds: 10),
        _stopRecording,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      showErrorSnackBar(
        context,
        "Impossible de démarrer l'enregistrement.",
      );
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) {
      return;
    }

    try {
      _phonemeTimer?.cancel();
      _recordingTimeoutTimer?.cancel();
      final recordedPath = await _audioRecorder.stop();

      if (!mounted) {
        return;
      }

      setState(() {
        _isRecording = false;
        _activePhonemeIndex = null;
        if (recordedPath != null && recordedPath.isNotEmpty) {
          _localAudioPath = recordedPath;
          _hasRecording = true;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isRecording = false;
        _activePhonemeIndex = null;
      });
      showErrorSnackBar(
        context,
        "Impossible d'arrêter l'enregistrement.",
      );
    }
  }

  Future<void> _playRecording() async {
    final audioPath = _localAudioPath;
    if (audioPath == null || audioPath.isEmpty) {
      return;
    }

    try {
      await _player.stop();
      await _player.setFilePath(audioPath);
      await _player.play();
    } catch (_) {
      if (!mounted) {
        return;
      }
      showErrorSnackBar(
        context,
        "Impossible de lire l'enregistrement.",
      );
    }
  }

  Future<void> _deleteRecording() async {
    final audioPath = _localAudioPath;

    if (_isRecording) {
      await _stopRecording();
    }

    await _player.stop();

    if (audioPath != null && audioPath.isNotEmpty) {
      try {
        final file = File(audioPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _localAudioPath = null;
      _hasRecording = false;
      _activePhonemeIndex = null;
    });
  }

  void _showMallampatiInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Classification de Mallampati'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('I : Luette, voile du palais et piliers visibles.'),
              SizedBox(height: 8),
              Text('II : Luette et voile du palais partiellement visibles.'),
              SizedBox(height: 8),
              Text('III : Seule la base de la luette est visible.'),
              SizedBox(height: 8),
              Text('IV : Palais mou non visible.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IntubationCubit, IntubationState>(
      listener: (context, state) {
        if (state is IntubationOperationSuccess) {
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).pop();
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
        } else if (state is IntubationError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: BlocBuilder<IntubationCubit, IntubationState>(
        builder: (context, state) {
          final isLoading = state is IntubationLoading;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                _isEditMode
                    ? "Modifier le dossier d'intubation"
                    : "Nouveau dossier d'intubation",
              ),
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: StepProgressBar(
                          totalSteps: _stepTitles.length,
                          currentStep: _currentStep,
                          stepTitles: _stepTitles,
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _MedicalHistoryStep(
                              draft: _draft,
                              brulureController: _brulureController,
                              dysmorphieController: _dysmorphieController,
                              tumeurController: _tumeurController,
                              acteController: _acteController,
                              onDraftChanged: (draft) {
                                setState(() {
                                  _draft = draft;
                                });
                              },
                            ),
                            _ClinicalEvaluationStep(
                              draft: _draft,
                              showErrors: _showStep2Errors,
                              onMallampatiInfoPressed: _showMallampatiInfo,
                              onDraftChanged: (draft) {
                                setState(() {
                                  _draft = draft;
                                });
                              },
                            ),
                            _RiskAssessmentStep(
                              draft: _draft,
                              showErrors: _showStep3Errors,
                              onDraftChanged: (draft) {
                                setState(() {
                                  _draft = draft;
                                });
                              },
                            ),
                            _ProcedureDataStep(
                              draft: _draft,
                              showErrors: _showStep4Errors,
                              onDraftChanged: (draft) {
                                setState(() {
                                  _draft = draft;
                                });
                              },
                            ),
                            _ComplicationsStep(
                              draft: _draft,
                              complicationsController: _complicationsController,
                              onDraftChanged: (draft) {
                                setState(() {
                                  _draft = draft;
                                });
                              },
                            ),
                            _AdditionalDataStep(
                              patient: widget.patient,
                              draft: _draft,
                              photoLabels: _photoLabels,
                              phonemes: _phonemes,
                              isRecording: _isRecording,
                              hasRecording: _hasRecording,
                              localAudioPath: _localAudioPath,
                              activePhonemeIndex: _activePhonemeIndex,
                              onImageTap: _pickImage,
                              onImageDelete: _removeImage,
                              onStartRecording: _startRecording,
                              onStopRecording: _stopRecording,
                              onPlayRecording: _playRecording,
                              onDeleteRecording: _deleteRecording,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: const Border(
                          top: BorderSide(color: AppColors.surfaceVariant),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isLoading ? null : _previousStep,
                                  child: const Text('Précédent'),
                                ),
                              )
                            else
                              const Spacer(),
                            const SizedBox(width: 12),
                            Text(
                              '${_currentStep + 1} / ${_stepTitles.length}',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _currentStep == _stepTitles.length - 1
                                  ? AppButton(
                                      label: 'Enregistrer',
                                      isLoading: isLoading,
                                      onPressed: isLoading ? null : _saveIntubation,
                                    )
                                  : ElevatedButton(
                                      onPressed: isLoading ? null : _nextStep,
                                      child: const Text('Suivant'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MedicalHistoryStep extends StatelessWidget {
  final IntubationEntity draft;
  final TextEditingController brulureController;
  final TextEditingController dysmorphieController;
  final TextEditingController tumeurController;
  final TextEditingController acteController;
  final ValueChanged<IntubationEntity> onDraftChanged;

  const _MedicalHistoryStep({
    required this.draft,
    required this.brulureController,
    required this.dysmorphieController,
    required this.tumeurController,
    required this.acteController,
    required this.onDraftChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Text(
          'Antécédents médicaux & facteurs de risque',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _SwitchCard(
          title: "Antécédent d'intubation difficile",
          value: draft.antecedentIntubationDifficile,
          onChanged: (value) => onDraftChanged(
            draft.copyWith(antecedentIntubationDifficile: value),
          ),
        ),
        _SwitchCard(
          title: "SAOS (Syndrome d'apnée obstructive du sommeil)",
          value: draft.saos,
          onChanged: (value) => onDraftChanged(draft.copyWith(saos: value)),
        ),
        _SwitchCard(
          title: 'Diabète',
          value: draft.diabete,
          onChanged: (value) => onDraftChanged(draft.copyWith(diabete: value)),
        ),
        _SwitchCard(
          title: 'Goitre',
          value: draft.goitre,
          onChanged: (value) => onDraftChanged(draft.copyWith(goitre: value)),
        ),
        _SwitchCard(
          title: 'Maladie rhumatismale',
          value: draft.maladieRhumatismale,
          onChanged: (value) => onDraftChanged(
            draft.copyWith(maladieRhumatismale: value),
          ),
        ),
        _SwitchCard(
          title: 'Traumatisme ou irradiation cervicale',
          value: draft.traumatismeCervical,
          onChanged: (value) => onDraftChanged(
            draft.copyWith(traumatismeCervical: value),
          ),
        ),
        _SwitchCard(
          title: 'Brûlure cervico-faciale',
          value: draft.brulureCervicoFaciale,
          onChanged: (value) {
            if (!value) {
              brulureController.clear();
            }
            onDraftChanged(
              draft.copyWith(
                brulureCervicoFaciale: value,
                brulureLocalisation: value ? draft.brulureLocalisation : null,
                clearBrulureLocalisation: !value,
              ),
            );
          },
        ),
        if (draft.brulureCervicoFaciale) ...[
          const SizedBox(height: 8),
          AppTextField(
            controller: brulureController,
            label: 'Localisation de la brûlure',
            onChanged: (value) => onDraftChanged(
              draft.copyWith(
                brulureLocalisation: value.trim().isEmpty ? null : value.trim(),
                clearBrulureLocalisation: value.trim().isEmpty,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        _SwitchCard(
          title: 'Dysmorphie ou traumatisme crâniofacial',
          value: draft.dysmorphieCranioFaciale,
          onChanged: (value) {
            if (!value) {
              dysmorphieController.clear();
            }
            onDraftChanged(
              draft.copyWith(
                dysmorphieCranioFaciale: value,
                dysmorphieLocalisation:
                    value ? draft.dysmorphieLocalisation : null,
                clearDysmorphieLocalisation: !value,
              ),
            );
          },
        ),
        if (draft.dysmorphieCranioFaciale) ...[
          const SizedBox(height: 8),
          AppTextField(
            controller: dysmorphieController,
            label: 'Localisation',
            onChanged: (value) => onDraftChanged(
              draft.copyWith(
                dysmorphieLocalisation:
                    value.trim().isEmpty ? null : value.trim(),
                clearDysmorphieLocalisation: value.trim().isEmpty,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        _SwitchCard(
          title: 'Tumeur cervicofaciale',
          value: draft.tumeurCervicofaciale,
          onChanged: (value) {
            if (!value) {
              tumeurController.clear();
            }
            onDraftChanged(
              draft.copyWith(
                tumeurCervicofaciale: value,
                tumeurLocalisation: value ? draft.tumeurLocalisation : null,
                clearTumeurLocalisation: !value,
              ),
            );
          },
        ),
        if (draft.tumeurCervicofaciale) ...[
          const SizedBox(height: 8),
          AppTextField(
            controller: tumeurController,
            label: 'Localisation de la tumeur',
            onChanged: (value) => onDraftChanged(
              draft.copyWith(
                tumeurLocalisation: value.trim().isEmpty ? null : value.trim(),
                clearTumeurLocalisation: value.trim().isEmpty,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        Text(
          'Symptômes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        _SwitchCard(
          title: 'Ronflement',
          value: draft.ronflement,
          onChanged: (value) => onDraftChanged(
            draft.copyWith(ronflement: value),
          ),
        ),
        _SwitchCard(
          title: 'Dysphonie',
          value: draft.dysphonie,
          onChanged: (value) => onDraftChanged(
            draft.copyWith(dysphonie: value),
          ),
        ),
        _SwitchCard(
          title: 'Dysphagie',
          value: draft.dysphagie,
          onChanged: (value) => onDraftChanged(
            draft.copyWith(dysphagie: value),
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: acteController,
          label: 'Acte opératoire',
          hintText: 'Ex: cholécystectomie',
          onChanged: (value) => onDraftChanged(
            draft.copyWith(
              acteOperatoire: value.trim().isEmpty ? null : value.trim(),
              clearActeOperatoire: value.trim().isEmpty,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Score STOPBANG',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            9,
            (index) => ChoiceChip(
              label: Text('$index'),
              selected: draft.scoreStopbang == index,
              selectedColor: AppColors.primary,
              onSelected: (_) => onDraftChanged(
                draft.copyWith(
                  scoreStopbang: draft.scoreStopbang == index ? null : index,
                  clearScoreStopbang: draft.scoreStopbang == index,
                ),
              ),
              labelStyle: TextStyle(
                color: draft.scoreStopbang == index
                    ? Colors.white
                    : AppColors.muted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClinicalEvaluationStep extends StatelessWidget {
  final IntubationEntity draft;
  final bool showErrors;
  final VoidCallback onMallampatiInfoPressed;
  final ValueChanged<IntubationEntity> onDraftChanged;

  const _ClinicalEvaluationStep({
    required this.draft,
    required this.showErrors,
    required this.onMallampatiInfoPressed,
    required this.onDraftChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Text(
          'Évaluation clinique pré-intubation',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        SegmentedSelector(
          label: 'Score ASA',
          options: const ['I', 'II', 'III'],
          selected: draft.scoreAsa,
          required: true,
          showError: showErrors,
          onSelect: (value) => onDraftChanged(draft.copyWith(scoreAsa: value)),
        ),
        const SizedBox(height: 20),
        SegmentedSelector(
          label: 'Mallampati',
          options: const ['I', 'II', 'III', 'IV'],
          selected: draft.mallampati,
          required: true,
          showError: showErrors,
          trailing: IconButton(
            onPressed: onMallampatiInfoPressed,
            icon: const Icon(Icons.info_outline, size: 20),
          ),
          onSelect: (value) =>
              onDraftChanged(draft.copyWith(mallampati: value)),
        ),
        const SizedBox(height: 20),
        SegmentedSelector(
          label: 'Distance thyromentonnière (DTM)',
          options: const ['< 6 cm', '> 6 cm'],
          selected: draft.dtm,
          required: true,
          showError: showErrors,
          onSelect: (value) => onDraftChanged(draft.copyWith(dtm: value)),
        ),
        const SizedBox(height: 20),
        SegmentedSelector(
          label: 'Ouverture buccale',
          options: const ['< 35 mm', '> 35 mm'],
          selected: draft.ouvertureBuccale,
          required: true,
          showError: showErrors,
          onSelect: (value) =>
              onDraftChanged(draft.copyWith(ouvertureBuccale: value)),
        ),
        const SizedBox(height: 20),
        SegmentedSelector(
          label: 'Tour de cou',
          options: const ['< 45 cm', '> 45 cm'],
          selected: draft.tourDeCou,
          required: true,
          showError: showErrors,
          onSelect: (value) =>
              onDraftChanged(draft.copyWith(tourDeCou: value)),
        ),
        const SizedBox(height: 20),
        SegmentedSelector(
          label: 'Mobilité cervicale',
          options: const ['Souple', 'Raide'],
          selected: draft.mobiliteCervicale,
          required: true,
          showError: showErrors,
          onSelect: (value) =>
              onDraftChanged(draft.copyWith(mobiliteCervicale: value)),
        ),
        const SizedBox(height: 16),
        _SwitchCard(
          title: 'Macroglossie',
          value: draft.macroglossie,
          onChanged: (value) =>
              onDraftChanged(draft.copyWith(macroglossie: value)),
        ),
      ],
    );
  }
}

class _RiskAssessmentStep extends StatelessWidget {
  final IntubationEntity draft;
  final bool showErrors;
  final ValueChanged<IntubationEntity> onDraftChanged;

  const _RiskAssessmentStep({
    required this.draft,
    required this.showErrors,
    required this.onDraftChanged,
  });

  @override
  Widget build(BuildContext context) {
    final recommendation = switch (draft.intubationPrevue) {
      'Facile' => _InfoCardData(
          color: AppColors.success,
          icon: Icons.check_circle_outline,
          text: 'Intubation standard prévue. Procédure habituelle.',
        ),
      'Difficile' => _InfoCardData(
          color: AppColors.warning,
          icon: Icons.warning_amber_rounded,
          text:
              'Intubation difficile anticipée. Prévoir du matériel alternatif.',
        ),
      _ => _InfoCardData(
          color: AppColors.muted,
          icon: Icons.info_outline,
          text:
              'Sélectionnez une option pour voir les recommandations.',
        ),
    };

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Text(
          "Évaluation du risque d'intubation",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        SegmentedSelector(
          label: 'Intubation prévue',
          options: const ['Facile', 'Difficile'],
          selected: draft.intubationPrevue,
          required: true,
          showError: showErrors,
          onSelect: (value) =>
              onDraftChanged(draft.copyWith(intubationPrevue: value)),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: recommendation.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: recommendation.color.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(recommendation.icon, color: recommendation.color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recommendation.text,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProcedureDataStep extends StatelessWidget {
  final IntubationEntity draft;
  final bool showErrors;
  final ValueChanged<IntubationEntity> onDraftChanged;

  const _ProcedureDataStep({
    required this.draft,
    required this.showErrors,
    required this.onDraftChanged,
  });

  String? get _cormackDescription => switch (draft.scoreCormack) {
        'I' => 'Glotte entièrement visible',
        'II' => 'Seule la partie postérieure est visible',
        'III' => "Seulement l'épiglotte est visible",
        'IV' => "Ni l'épiglotte ni la glotte ne sont visibles",
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Text(
          "Déroulement de l'acte",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        SegmentedSelector(
          label: "Type d'intubation",
          options: const ['Orale', 'Nasale'],
          selected: draft.typeIntubation,
          required: true,
          showError: showErrors,
          onSelect: (value) =>
              onDraftChanged(draft.copyWith(typeIntubation: value)),
        ),
        const SizedBox(height: 20),
        Text(
          'Nombre de tentatives',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 12),
        _CounterSelector(
          value: draft.nombreTentatives ?? 1,
          onChanged: (value) =>
              onDraftChanged(draft.copyWith(nombreTentatives: value)),
        ),
        const SizedBox(height: 20),
        _SwitchCard(
          title: 'Vidéolaryngoscope utilisé',
          value: draft.videolaryngoscope,
          onChanged: (value) =>
              onDraftChanged(draft.copyWith(videolaryngoscope: value)),
        ),
        _SwitchCard(
          title: "Guide d'Eichmann utilisé",
          value: draft.guideEichmann,
          onChanged: (value) =>
              onDraftChanged(draft.copyWith(guideEichmann: value)),
        ),
        const SizedBox(height: 16),
        SegmentedSelector(
          label: 'Score de Cormack',
          options: const ['I', 'II', 'III', 'IV'],
          selected: draft.scoreCormack,
          required: true,
          showError: showErrors,
          onSelect: (value) =>
              onDraftChanged(draft.copyWith(scoreCormack: value)),
        ),
        if (_cormackDescription != null) ...[
          const SizedBox(height: 10),
          Text(
            _cormackDescription!,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

class _ComplicationsStep extends StatelessWidget {
  final IntubationEntity draft;
  final TextEditingController complicationsController;
  final ValueChanged<IntubationEntity> onDraftChanged;

  const _ComplicationsStep({
    required this.draft,
    required this.complicationsController,
    required this.onDraftChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Text(
          'Difficultés rencontrées & complications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        _SwitchCard(
          title: 'Intubation difficile (réelle, selon SFAR)',
          value: draft.intubationDifficileReelle,
          onChanged: (value) => onDraftChanged(
            draft.copyWith(intubationDifficileReelle: value),
          ),
        ),
        if (draft.intubationDifficileReelle) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.24),
              ),
            ),
            child: const Text(
              'Intubation difficile confirmée selon les critères SFAR.',
            ),
          ),
        ],
        const SizedBox(height: 20),
        AppTextField(
          controller: complicationsController,
          label: 'Description des complications (libre)',
          hintText: 'Décrivez les complications éventuelles...',
          minLines: 3,
          maxLines: 5,
          onChanged: (value) => onDraftChanged(
            draft.copyWith(
              complications: value.trim().isEmpty ? null : value.trim(),
              clearComplications: value.trim().isEmpty,
            ),
          ),
        ),
      ],
    );
  }
}

class _AdditionalDataStep extends StatelessWidget {
  final PatientEntity patient;
  final IntubationEntity draft;
  final List<String> photoLabels;
  final List<String> phonemes;
  final bool isRecording;
  final bool hasRecording;
  final String? localAudioPath;
  final int? activePhonemeIndex;
  final ValueChanged<int> onImageTap;
  final ValueChanged<int> onImageDelete;
  final Future<void> Function() onStartRecording;
  final Future<void> Function() onStopRecording;
  final Future<void> Function() onPlayRecording;
  final Future<void> Function() onDeleteRecording;

  const _AdditionalDataStep({
    required this.patient,
    required this.draft,
    required this.photoLabels,
    required this.phonemes,
    required this.isRecording,
    required this.hasRecording,
    required this.localAudioPath,
    required this.activePhonemeIndex,
    required this.onImageTap,
    required this.onImageDelete,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onPlayRecording,
    required this.onDeleteRecording,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedPhotos = List<String>.filled(photoLabels.length, '');
    for (var i = 0; i < draft.photoPaths.length && i < photoLabels.length; i++) {
      normalizedPhotos[i] = draft.photoPaths[i];
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Text(
          'Données complémentaires',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        Text(
          'Photos du patient',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: photoLabels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final path = normalizedPhotos[index];
            final hasImage = path.isNotEmpty && File(path).existsSync();

            return _PhotoSlot(
              label: photoLabels[index],
              imagePath: hasImage ? path : null,
              onTap: () => onImageTap(index),
              onDelete: hasImage ? () => onImageDelete(index) : null,
            );
          },
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enregistrement vocal (Bonus)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Phonèmes requis: أ خ ه ح غ ع',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  phonemes.length,
                  (index) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: activePhonemeIndex == index
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        phonemes[index],
                        style: TextStyle(
                          color: activePhonemeIndex == index
                              ? Colors.white
                              : AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _AudioActionButton(
                      icon: Icons.mic,
                      label: 'Enregistrer',
                      color: AppColors.primary,
                      onTap: isRecording ? null : onStartRecording,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AudioActionButton(
                      icon: Icons.stop,
                      label: 'Stop',
                      color: AppColors.danger,
                      onTap: isRecording ? onStopRecording : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AudioActionButton(
                      icon: Icons.play_arrow,
                      label: 'Lire',
                      color: AppColors.muted,
                      onTap: hasRecording ? onPlayRecording : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AudioActionButton(
                      icon: Icons.delete_outline,
                      label: 'Supprimer',
                      color: AppColors.warning,
                      onTap: hasRecording ? onDeleteRecording : null,
                    ),
                  ),
                ],
              ),
              if (localAudioPath?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                const Text(
                  'Un enregistrement vocal est prêt à être enregistré.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Récapitulatif',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _SummaryRow(label: 'Patient', value: patient.fullName),
              _SummaryRow(label: 'ASA', value: draft.scoreAsa ?? '-'),
              _SummaryRow(label: 'Mallampati', value: draft.mallampati ?? '-'),
              _SummaryRow(label: 'DTM', value: draft.dtm ?? '-'),
              _SummaryRow(
                label: 'Intubation prévue',
                value: draft.intubationPrevue ?? '-',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (draft.intubationPrevue == 'Difficile'
                            ? AppColors.danger
                            : AppColors.success)
                        .withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    draft.intubationPrevue ?? '-',
                    style: TextStyle(
                      color: draft.intubationPrevue == 'Difficile'
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                ),
              ),
              _SummaryRow(label: 'Cormack', value: draft.scoreCormack ?? '-'),
              _SummaryRow(
                label: 'Tentatives',
                value: '${draft.nombreTentatives ?? 1}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchCard({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}

class _CounterSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _CounterSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        IconButton.outlined(
          onPressed: value < 10 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String label;
  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _PhotoSlot({
    required this.label,
    required this.imagePath,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imagePath != null
                    ? Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.photo_camera_outlined,
                              color: Colors.white54,
                              size: 34,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            if (imagePath != null)
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: onDelete,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ),
            if (imagePath != null)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AudioActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function()? onTap;

  const _AudioActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap == null ? null : () => onTap!.call(),
      style: OutlinedButton.styleFrom(
        foregroundColor: onTap == null ? AppColors.muted : color,
        side: BorderSide(
          color: onTap == null ? AppColors.muted : color,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            ),
          ),
          if (trailing == null)
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          else
            trailing!,
        ],
      ),
    );
  }
}

class _InfoCardData {
  final Color color;
  final IconData icon;
  final String text;

  const _InfoCardData({
    required this.color,
    required this.icon,
    required this.text,
  });
}
