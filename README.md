# OxyTrace

OxyTrace is a Flutter mobile application for managing tracheal intubation records. It centralizes patient information, risk factors, pre-intubation clinical assessments, procedure data, photos, audio notes, and PDF exports.

## Introduction

Tracheal intubation is a sensitive medical procedure that requires accurate patient assessment before, during, and after the procedure. In clinical settings, medical history, assessment scores, complications, and visual documentation can be scattered or recorded inconsistently.

OxyTrace addresses this problem by providing a simple, structured mobile tool that can be used at the point of care to document intubation records, make them easier to review, and improve the traceability of important clinical information.

## Project objectives

- Manage tracheal intubation records from a mobile device.
- Provide local user registration and authentication.
- Create, view, edit, search, and delete patient records.
- Associate one or more intubation records with each patient.
- Organize medical data entry into guided steps.
- Record risk criteria, procedure details, and possible complications.
- Add clinical photos and supplementary voice recordings.
- Generate and share a PDF report for an intubation record.
- Store data locally for autonomous mobile use.

## Main features

### Authentication

The application provides login and registration screens. Users are stored in the local database with hashed passwords to protect access to patient records.

### Dashboard

The dashboard provides a quick overview of application activity, including total patients, recent records, patient creation, the patient list, patient search, and the user profile.

### Patient management

OxyTrace manages first and last name, phone number, sex, date of birth, automatically calculated age, BMI with category classification, and creation/update dates. Users can add, edit, delete, and search for patients. Each patient profile provides access to associated intubation records.

### Intubation records

Each record is linked to a patient and is entered through six guided steps:

1. Medical history.
2. Clinical assessment.
3. Risk assessment.
4. Per-intubation data.
5. Difficulties and complications.
6. Additional data.

The form covers difficult intubation history, sleep apnea, diabetes, goiter, cervical trauma, burns, dysmorphia, cervicofacial tumors, snoring, dysphonia, dysphagia, STOP-BANG, ASA, Mallampati, thyromental distance, mouth opening, neck circumference, cervical mobility, intubation type, number of attempts, videolaryngoscope use, Eichmann guide, Cormack score, and complications.

### Additional clinical data

The application supports front, profile, open-mouth, LIP test, supine-neutral, and supine-extension patient photo views. A voice recording can also be created to document specific phonemes. Media files are stored locally in the application document directory.

### Record review and PDF export

The record detail page displays medical history, clinical assessment, planned risk, procedure details, complications, and photos in organized sections. Users can generate and share a PDF containing patient information, clinical data, procedure details, complications, and available photos.

## User workflow

1. Open the application.
2. Create an account or log in.
3. Open the dashboard.
4. Create a new patient or search for an existing patient.
5. Open the patient profile.
6. Create a new intubation record.
7. Complete the guided medical form.
8. Add photos and a voice recording if needed.
9. Save and review the record.
10. Edit, delete, or export the record as a PDF.

## Technical architecture

OxyTrace follows a feature-based architecture inspired by Clean Architecture:

```text
lib/
  core/
    constants/  errors/  usecases/  utils/
  features/
    auth/       patient/       intubation/       splash/
      data/     domain/        presentation/
  shared/
    network/local/  services/  widgets/
```

Responsibilities are separated as follows:

- `presentation`: Flutter screens, states, and Cubits;
- `domain`: entities, repository contracts, and use cases;
- `data`: models, local data sources, and repository implementations;
- `shared`: reusable components, local database, and cross-cutting services;
- `core`: constants, validation, formatting, and shared abstractions.

## Technology stack

- Flutter and Dart;
- `flutter_bloc` for state management;
- `get_it` for dependency injection;
- `sqflite` for local SQLite storage;
- `pdf`, `printing`, and `share_plus` for PDF generation and sharing;
- `image_picker` for selecting photos;
- `record`, `just_audio`, and `permission_handler` for audio recording and playback.

## Data model

The local SQLite database contains `users`, `patients`, and `intubations` tables. The main relationship is:

```text
patients (1) ---- (N) intubations
```

Patient records include identity, contact, birth-date, BMI, and timestamps. Intubation records include assessment scores, procedure data, complications, local photo paths, and an audio path. Deleting a patient also deletes its intubation records through the `ON DELETE CASCADE` constraint.

## Demonstration scenario

1. Launch OxyTrace on an emulator or mobile device.
2. Create a user account and log in.
3. Create a patient from the dashboard and test the search feature.
4. Create and complete an intubation record.
5. Add clinical photos and a short voice recording.
6. Save the record, review its details, and generate the PDF report.
7. Edit or delete the record to demonstrate CRUD operations.

## Challenges and solutions

- **Long medical form:** guided steps and a progress indicator keep each category manageable.
- **Data validation:** important assessment and procedure fields are validated before saving.
- **Offline persistence:** local SQLite storage supports operation without a remote server.
- **Media management:** files remain in local storage while SQLite stores only their paths.
- **PDF generation:** the dedicated `PdfService` combines clinical data and photos into a shareable report.

## Future improvements

- Secure server synchronization and stronger authentication with role management.
- Encryption for the local database and sensitive medical files.
- Statistics, advanced filters, and data backup/restore.
- Expanded unit and integration test coverage.
- Hospital or interoperable export formats.
- Web version or administration interface.

## Getting started

### Requirements

- Flutter SDK;
- Android Studio or Xcode, depending on the target platform;
- an emulator or connected mobile device.

### Install and run

```bash
flutter pub get
flutter run
```

### Analyze the code

```bash
flutter analyze
```
