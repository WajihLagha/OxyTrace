 import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../datasources/patient_local_datasource.dart';
import '../models/patient_model.dart';

class PatientSyncService {
  PatientSyncService({
    required PatientLocalDatasource localDatasource,
    Connectivity? connectivity,
    HttpClient? httpClient,
  })  : _localDatasource = localDatasource,
        _connectivity = connectivity ?? Connectivity(),
        _httpClient = httpClient ?? HttpClient();

  static const String _endpoint =
      String.fromEnvironment('OXYTRACE_PATIENT_SYNC_ENDPOINT');

  final PatientLocalDatasource _localDatasource;
  final Connectivity _connectivity;
  final HttpClient _httpClient;

  Future<PatientSyncResult> syncPendingPatients() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final isOffline = connectivityResults.every(
      (result) => result == ConnectivityResult.none,
    );

    if (isOffline) {
      throw const PatientSyncException('Aucune connexion internet disponible.');
    }

    if (_endpoint.trim().isEmpty) {
      throw const PatientSyncException(
        'Endpoint de synchronisation non configuré.',
      );
    }

    final pendingPatients = await _localDatasource.getPendingSyncPatients();
    var syncedCount = 0;

    for (final patient in pendingPatients) {
      await _uploadPatient(patient);
      if (patient.id != null) {
        await _localDatasource.markPatientSynced(patient.id!);
      }
      syncedCount++;
    }

    return PatientSyncResult(
      pendingBeforeSync: pendingPatients.length,
      syncedCount: syncedCount,
    );
  }

  Future<void> _uploadPatient(PatientModel patient) async {
    final uri = Uri.parse(_endpoint);
    final request = await _httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(patient.toMap()));

    final response = await request.close();
    await response.drain<void>();

    if (response.statusCode < HttpStatus.ok ||
        response.statusCode >= HttpStatus.multipleChoices) {
      throw PatientSyncException(
        'Synchronisation interrompue (${response.statusCode}).',
      );
    }
  }
}

class PatientSyncResult {
  const PatientSyncResult({
    required this.pendingBeforeSync,
    required this.syncedCount,
  });

  final int pendingBeforeSync;
  final int syncedCount;
}

class PatientSyncException implements Exception {
  const PatientSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}
