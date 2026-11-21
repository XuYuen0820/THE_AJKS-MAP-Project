# Exora
EXORA is a role-based Flutter and Firebase mobile application for university examination supervision, invigilator duty assignments, and staff profile management.

## Architecture (MVVM)
The application is structured using the **Model–View–ViewModel (MVVM)** pattern with a dedicated **Service** layer so UI widgets do not interact directly with Firebase:

lib/
├── constants/                  # App color palette and theme constants
├── features/                   # Feature-based Views and ViewModels
│   ├── auth/                   # Login, Forgot Password, and AuthGate role routing
│   ├── dashboard/              # Role-based Admin and Invigilator dashboards
│   ├── invigilator_management/ # Invigilator list, assignment, and discharge flows
│   └── profile/                # Profile viewing, avatar upload, and password update
├── models/                     # Plain Dart data models (StaffUser, ExamAssignment)
├── services/                   # FirebaseAuth and Cloud Firestore data access layer
└── widgets/                    # Reusable UI components

## Installation & Setup

### 1. Clone and Install Dependencies

# Clone the repository
git clone [https://github.com/XuYuen0820/THE_AJKS-MAP-Project.git](https://github.com/XuYuen0820/THE_AJKS-MAP-Project.git)

# Navigate into the project folder
cd THE_AJKS-MAP-Project

# Then
flutter pub get
```

---

### 2. Run the Application

```bash
# Run on Web (Chrome):
flutter run -d chrome --web-port=8080
```
> Press `F12` in Chrome and switch to the **Device Toolbar** (`Ctrl + Shift + M`) to preview the mobile layout.

# Build Android Release APK:
flutter build apk --release

The compiled release APK is output to build/app/outputs/flutter-apk/app-release.apk.

### 3. Configure Firebase Authentication & Cloud Firestore

The login form uses email and password. Firebase Authentication verifies user credentials, while Cloud Firestore provides the staff profile and role (Admin or Invigilator).

1. In the Firebase Console, open Authentication → Sign-in method and enable Email/Password.
2. In Authentication → Users, create an account for each staff member using their email address and password.
3. In the Firestore account collection, ensure each staff document contains an email field that exactly matches their Firebase Authentication email, along with a role field (Admin or Invigilator).
4. Deploy the Firestore security rules from firestore.rules using the Firebase CLI from the repository root:

   ```bash
   firebase deploy --only firestore:rules --project exora-map-project
   ```

Firebase Authentication persists the signed-in session across app restarts until the user selects Log out.

Note: Legacy passwordHash fields in Firestore are no longer used for authentication and should be removed from staff documents. A Firestore document alone does not grant login access without a matching Firebase Authentication user.

### 4. Test Accounts
# Admin--> Email: laini@graduate.utm.my  Password: admin001
# Invigilator--> Email: koryee.heng@graduate.utm.my   Password: staff001