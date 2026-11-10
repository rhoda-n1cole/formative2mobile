# Campus Incident Reporter

A Flutter mobile app for ALU students to report campus problems, such as water shortages, broken facilities, electricity outages, damaged furniture, sanitation and safety concerns, and to track them until campus staff resolve them.

Built for Mobile Application Development, Individual Assignment 2.

- **Demo video:** [https://youtu.be/pT-8yLxNaj8]
- **Technical report:** see the PDF submitted on Canvas

## Features

**Students**
- Register and log in with an ALU email (`@alustudent.com` or `@alueducation.com`), with email verification
- Submit a report with a category, title, description, location and an optional photo
- Report anonymously
- Browse all campus reports or only their own; search and filter by category and status
- View report details and a live status timeline
- Tap "Me too" to support an existing report
- Delete their own report while it is still Submitted

**Staff**
- Dashboard with a count of reports per status (tap a count to filter)
- Update a report's status (Submitted, In Review, In Progress, Resolved) with a note for the reporter

## Tech stack

| Area | Technology |
| --- | --- |
| App | Flutter (Dart), Material 3 |
| State management | Riverpod |
| Authentication | Firebase Authentication (email and password) |
| Database | Cloud Firestore |
| Photo uploads | Cloudinary (unsigned upload preset) |
| Tested on | Android emulator |

## Project structure

```text
lib/
├── main.dart              # Firebase init, ProviderScope, MaterialApp
├── app/                   # AuthGate, theme, constants, validators
├── models/                # AppUser, Incident, StatusUpdate
├── repositories/          # Auth, incident and storage (all backend calls)
├── providers/             # Riverpod providers for auth, incidents and filters
├── widgets/               # Reusable UI: IncidentCard, StatusChip, ...
└── screens/
    ├── auth/              # Login, register, verify email
    ├── student/           # Student home, submit report
    ├── staff/             # Staff dashboard
    └── shared/            # Report list, report details
test/
└── app_test.dart          # Unit and widget tests
```

Screens only display data. Providers hold the state, and repositories are the only classes that talk to Firebase or Cloudinary.

## Getting started

### Prerequisites
- Flutter SDK (3.27 or later)
- Android Studio with an Android emulator, or a physical Android device
- A Firebase project and a free Cloudinary account

### 1. Clone and install
```bash
git clone https://github.com/rhoda-n1cole/formative2mobile
cd campus_incident_app
flutter pub get
```

### 2. Connect Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This generates `lib/firebase_options.dart`. In the Firebase Console:
- **Authentication:** enable the Email/Password sign-in method
- **Firestore:** create a database, then publish the rules from [Security rules](#security-rules)

### 3. Connect Cloudinary
1. In Cloudinary, go to **Settings → Upload → Upload presets** and create a preset with **Signing mode: Unsigned**.
2. In `lib/providers/incident_providers.dart`, set your cloud name and preset name:
```dart
final storageRepositoryProvider = Provider<StorageRepository>(
  (ref) => StorageRepository(
       cloudName: 'YOUR_CLOUD_NAME',
   uploadPreset: 'YOUR_PRESET_NAME',
  ),
);
```

### 4. Run
```bash
flutter run
```

### 5. Create a staff account
Every new account is a student. To make one staff, register and verify it in the app, then in **Firestore → users → [that user]** change `role` from `student` to `staff`.

## Firestore data structure

```text
users/{uid}
  email, name, role ("student" | "staff"), createdAt

incidents/{id}
  title, description, category, location, status, imageUrl,
  reporterId, reporterName, isAnonymous, createdAt, updatedAt

  statusHistory/{hid}      status, note, updatedBy, createdAt   (append-only)
  supporters/{uid}         createdAt                            (one "Me too" per user)
```

## Security rules

Access control is enforced on the server by Firestore security rules:

- Only verified ALU accounts can read anything
- A profile can only be created with the role `student`, and no one can change a role from the app
- Students create reports only as themselves, with status `Submitted`
- Only staff can update a report, and only its `status` and `updatedAt` fields
- Students can delete their own report only while it is `Submitted`
- Timeline entries can be added by staff but never edited or deleted

The full rules are in the technical report (Section 7).

## Tests

```bash
flutter test
```
Covers the email and password validators, `Incident.fromMap` defaults, and the `StatusChip` widget.

## Known limitations

- Anonymous reports still store the reporter's user id, which a technical user could read
- The unsigned Cloudinary preset accepts uploads from anyone who knows its name
- Staff are promoted manually in the Firebase Console
- There is no push notification when a status changes
- There is no Rejected status for spam or duplicate reports

## Author

[UmutesiNicoleRhoda], African Leadership University
