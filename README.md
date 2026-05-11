# OxyTrace

OxyTrace est une application mobile Flutter destinée au suivi des dossiers
d'intubation trachéale. Elle permet de centraliser les informations patient, les
facteurs de risque, l'évaluation clinique pré-intubation, les données de l'acte
et les éléments complémentaires comme les photos, l'audio et l'export PDF.

## Introduction : contexte et problématique

L'intubation trachéale est un geste médical sensible qui nécessite une
évaluation précise du patient avant, pendant et après l'acte. Dans un contexte
clinique, les données liées aux antécédents, aux scores d'évaluation, aux
complications et aux supports visuels peuvent être dispersées ou saisies de
manière non standardisée.

La problématique traitée par OxyTrace est donc la suivante : comment proposer un
outil mobile simple, structuré et utilisable au lit du patient pour documenter
les dossiers d'intubation, faciliter leur consultation et améliorer la traçabilité
des informations cliniques importantes ?

## Objectifs du projet

- Concevoir une application mobile dédiée à la gestion des dossiers
  d'intubation trachéale.
- Permettre l'authentification locale des utilisateurs.
- Créer, consulter, modifier, rechercher et supprimer des dossiers patients.
- Associer à chaque patient un ou plusieurs dossiers d'intubation.
- Structurer la saisie des données médicales sous forme d'étapes guidées.
- Enregistrer les critères de risque, le déroulement de l'acte et les
  complications éventuelles.
- Ajouter des photos cliniques et un enregistrement vocal complémentaire.
- Générer et partager un compte rendu PDF du dossier d'intubation.
- Stocker les données localement pour une utilisation mobile autonome.

## Description fonctionnelle des principales fonctionnalités

### Authentification

L'application propose un écran de connexion et d'inscription. Les utilisateurs
sont enregistrés dans la base locale avec un mot de passe haché, ce qui permet de
protéger l'accès aux dossiers médicaux.

### Tableau de bord

Le tableau de bord donne une vue rapide sur l'activité de l'application :

- nombre total de patients ;
- nombre de dossiers récents ;
- accès rapide à la création d'un patient ;
- accès à la liste des patients ;
- recherche de patients ;
- accès au profil utilisateur.

### Gestion des patients

OxyTrace permet de gérer les informations principales d'un patient :

- prénom et nom ;
- téléphone ;
- sexe ;
- date de naissance ;
- âge calculé automatiquement ;
- BMI/IMC avec catégorisation ;
- dates de création et de mise à jour.

L'utilisateur peut ajouter, modifier, supprimer et rechercher un patient. Depuis
la fiche patient, il peut consulter les informations générales et accéder aux
dossiers d'intubation associés.

### Gestion des dossiers d'intubation

Chaque dossier d'intubation est rattaché à un patient. La saisie est organisée en
six étapes :

1. Antécédents médicaux.
2. Évaluation clinique.
3. Évaluation du risque.
4. Données per-intubation.
5. Difficultés et complications.
6. Données complémentaires.

Le formulaire couvre notamment les antécédents d'intubation difficile, SAOS,
diabète, goitre, traumatismes cervicaux, brûlures, dysmorphies, tumeurs
cervico-faciales, ronflement, dysphonie, dysphagie, score STOP-BANG, score ASA,
Mallampati, distance thyro-mentonnière, ouverture buccale, tour de cou, mobilité
cervicale, type d'intubation, nombre de tentatives, vidéolaryngoscope, guide
d'Eichmann, score de Cormack et complications.

### Données complémentaires

L'application permet d'ajouter plusieurs vues photographiques du patient :

- vue de face ;
- vue de profil ;
- bouche ouverte ;
- LIP test face ;
- décubitus dorsal en position neutre ;
- décubitus dorsal en extension.

Un enregistrement vocal peut aussi être réalisé pour documenter des phonèmes
spécifiques. Les fichiers sont stockés localement dans l'espace documentaire de
l'application.

### Consultation et export PDF

La page de détail d'un dossier d'intubation présente les informations sous forme
de sections consultables : antécédents, évaluation clinique, risque prévu,
déroulement de l'acte, complications et photos. L'utilisateur peut générer un PDF
contenant les informations du patient, les données cliniques, le déroulement de
l'acte, les complications et les photos disponibles, puis le partager depuis le
téléphone.

## Parcours utilisateur

Le parcours utilisateur principal est le suivant :

1. L'utilisateur ouvre l'application.
2. Il crée un compte ou se connecte.
3. Il arrive sur le tableau de bord.
4. Il crée un nouveau patient ou recherche un patient existant.
5. Il ouvre la fiche du patient.
6. Il crée un nouveau dossier d'intubation.
7. Il remplit les étapes du formulaire médical.
8. Il ajoute, si nécessaire, des photos et un enregistrement vocal.
9. Il enregistre le dossier.
10. Il consulte le résumé du dossier depuis la fiche patient.
11. Il peut modifier le dossier, le supprimer ou générer un PDF de synthèse.

## Architecture technique adoptée

OxyTrace adopte une architecture inspirée de la Clean Architecture, organisée par
fonctionnalité :

```text
lib/
  core/
    constants/
    errors/
    usecases/
    utils/
  features/
    auth/
      data/
      domain/
      presentation/
    patient/
      data/
      domain/
      presentation/
    intubation/
      data/
      domain/
      presentation/
    splash/
      presentation/
  shared/
    network/local/
    services/
    widgets/
```

Les principales responsabilités sont séparées ainsi :

- `presentation` : écrans Flutter, états et Cubits.
- `domain` : entités, contrats de repositories et cas d'utilisation.
- `data` : modèles, sources de données locales et implémentations des
  repositories.
- `shared` : composants réutilisables, base locale et services transverses.
- `core` : constantes, validation, formatage et abstractions communes.

Les technologies utilisées sont :

- Flutter et Dart pour l'application mobile ;
- `flutter_bloc` pour la gestion d'état ;
- `get_it` pour l'injection de dépendances ;
- `sqflite` pour la base de données locale SQLite ;
- `pdf`, `printing` et `share_plus` pour la génération et le partage de PDF ;
- `image_picker` pour l'ajout de photos ;
- `record`, `just_audio` et `permission_handler` pour l'enregistrement et la
  lecture audio.

## Modélisation des données

La base SQLite locale contient trois tables principales.

### Table `users`

| Champ | Type | Description |
| --- | --- | --- |
| `id` | INTEGER | Identifiant unique |
| `full_name` | TEXT | Nom complet de l'utilisateur |
| `email` | TEXT | Email unique |
| `password_hash` | TEXT | Mot de passe haché |

### Table `patients`

| Champ | Type | Description |
| --- | --- | --- |
| `id` | INTEGER | Identifiant unique |
| `first_name` | TEXT | Prénom |
| `last_name` | TEXT | Nom |
| `phone` | TEXT | Téléphone |
| `sex` | TEXT | Sexe |
| `birth_date` | TEXT | Date de naissance |
| `bmi` | REAL | Indice de masse corporelle |
| `created_at` | TEXT | Date de création |
| `updated_at` | TEXT | Date de mise à jour |

### Table `intubations`

| Champ | Type | Description |
| --- | --- | --- |
| `id` | INTEGER | Identifiant unique |
| `patient_id` | INTEGER | Référence vers le patient |
| `created_at` / `updated_at` | TEXT | Dates de suivi |
| `antecedent_intubation_difficile`, `saos`, `diabete`, etc. | INTEGER | Antécédents et facteurs de risque |
| `score_stopbang`, `score_asa`, `mallampati`, `dtm` | TEXT/INTEGER | Évaluation pré-intubation |
| `intubation_prevue`, `type_intubation`, `nombre_tentatives` | TEXT/INTEGER | Prévision et déroulement de l'acte |
| `videolaryngoscope`, `guide_eichmann`, `score_cormack` | INTEGER/TEXT | Moyens utilisés et score per-intubation |
| `intubation_difficile_reelle`, `complications` | INTEGER/TEXT | Difficultés et complications |
| `photo_paths` | TEXT | Chemins des photos locales |
| `audio_path` | TEXT | Chemin de l'enregistrement vocal |

La relation principale est :

```text
patients (1) ---- (N) intubations
```

La suppression d'un patient entraîne la suppression de ses dossiers
d'intubation grâce à la contrainte `ON DELETE CASCADE`.

## Démonstration des fonctionnalités implémentées

Pour démontrer l'application, le scénario suivant peut être utilisé :

1. Lancer OxyTrace sur un émulateur ou un appareil mobile.
2. Créer un compte utilisateur puis se connecter.
3. Depuis le tableau de bord, créer un nouveau patient.
4. Vérifier l'apparition du patient dans la liste et tester la recherche.
5. Ouvrir la fiche patient et consulter ses informations générales.
6. Créer un dossier d'intubation.
7. Remplir les étapes du formulaire : antécédents, évaluation clinique, risque,
   données de l'acte, complications et données complémentaires.
8. Ajouter une ou plusieurs photos cliniques.
9. Réaliser un enregistrement vocal court.
10. Enregistrer le dossier puis ouvrir son détail.
11. Générer et partager le PDF du dossier.
12. Modifier le dossier ou le supprimer pour montrer les opérations CRUD.

## Difficultés rencontrées et solutions apportées

### Structuration d'un formulaire médical long

La saisie d'un dossier d'intubation contient beaucoup de champs. Pour éviter une
interface trop lourde, le formulaire a été découpé en étapes avec une barre de
progression. Chaque étape regroupe une catégorie logique de données.

### Validation des données importantes

Certains champs sont indispensables pour exploiter correctement le dossier :
évaluation clinique, risque prévu, type d'intubation, score de Cormack et nombre
de tentatives. Une validation par étape a été mise en place afin d'empêcher
l'enregistrement d'un dossier incomplet.

### Persistance locale des données

L'application doit fonctionner en mobilité, même sans serveur distant. La
solution adoptée est une base SQLite locale avec `sqflite`, associée à des
datasources et repositories séparés pour garder un code maintenable.

### Gestion des médias

Les photos et l'audio ne sont pas stockés directement dans la base. L'application
enregistre les fichiers dans le stockage local et conserve uniquement leurs
chemins dans SQLite. Cette approche limite la taille de la base et simplifie
l'affichage des médias.

### Génération du compte rendu

La génération PDF doit regrouper des données structurées et des photos. Un
service dédié, `PdfService`, a été créé pour isoler cette logique et produire un
document partageable sans mélanger cette responsabilité avec les écrans.

## Perspectives d'amélioration

- Ajouter une synchronisation avec un serveur sécurisé.
- Mettre en place une authentification plus complète avec gestion des rôles.
- Chiffrer la base locale et les fichiers médicaux sensibles.
- Ajouter des statistiques sur les intubations difficiles et les complications.
- Intégrer des filtres avancés sur les patients et les dossiers.
- Ajouter une sauvegarde/restauration des données.
- Améliorer l'analyse des photos et des enregistrements vocaux.
- Ajouter des tests unitaires et des tests d'intégration plus complets.
- Prévoir une exportation vers des formats hospitaliers ou interopérables.
- Ajouter une version web ou une interface d'administration.

## Lancement du projet

Prérequis :

- Flutter SDK installé ;
- Android Studio ou Xcode selon la plateforme cible ;
- un émulateur ou un appareil mobile connecté.

Commandes utiles :

```bash
flutter pub get
flutter run
```

Pour analyser le code :

```bash
flutter analyze
```
