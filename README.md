# Exora
EXORA is a role-based Flutter and Firebase mobile application for university examination supervision, invigilator duty assignments, and staff profile management.

## Architecture (MVVM)
The application follows a **feature-based Model–View–ViewModel (MVVM)** architecture[cite: 7, 54] with **Service Interfaces**[cite: 12, 13] and centralized **Dependency Injection (`GetIt`)**[cite: 14, 35, 37, 41] so UI widgets remain decoupled from Firebase data sources[cite: 11, 12]:

```text
lib/
├── main.dart                       # App entry point & Firebase/DI initialization[cite: 7, 42, 54]
├── firebase_options.dart           # Platform-specific Firebase configuration[cite: 57]
├── app/                            # Application-wide setup & wiring[cite: 7, 35, 54]
│   ├── app.dart                    # MaterialApp & theme configuration[cite: 7, 14, 54]
│   ├── dependencies.dart           # Centralized GetIt Service Locator (DI)[cite: 14, 35, 37, 41]
│   └── router.dart                 # Named route navigation & ViewModel injection[cite: 7, 35, 54]
├── core/                           # Shared infrastructure, models & UI components[cite: 7, 36, 54]
│   ├── models/                     # Shared domain models (StaffUser)[cite: 7, 18, 54]
│   ├── services/                   # Shared service contracts & implementations (AuthService)[cite: 7, 12, 54]
│   ├── utils/                      # App color palette & theme constants (AppColors)[cite: 7, 54]
│   └── widgets/                    # Reusable UI widgets shared across screens[cite: 36]
└── features/                       # Self-contained feature modules[cite: 7, 54]
    ├── authentication/             # Login, Forgot Password, and AuthGate role routing
    │   ├── viewmodels/             # AuthViewModel, LoginViewModel, ForgotPasswordViewModel
    │   └── views/                  # AuthGateView, LoginView, ForgotPasswordView
    ├── dashboard/                  # Role-based Admin and Invigilator dashboards
    │   ├── viewmodels/             # DashboardViewModel
    │   └── views/                  # AdminDashboardView, InvigilatorDashboardView, DashboardProfileCard
    ├── invigilator_management/     # Invigilator list, assignment, and discharge flows
    │   ├── models/                 # ExamAssignment domain model
    │   ├── services/               # InvigilatorService interface & FirebaseInvigilatorService
    │   ├── viewmodels/             # InvigilatorManagementViewModel
    │   └── views/                  # InvigilatorManagementView, List, Assign & Discharge views
    └── profile/                    # Profile viewing, avatar upload, and password update
        ├── services/               # ProfileService interface & FirebaseProfileService
        ├── viewmodels/             # ProfileViewModel
        └── views/                  # ProfileView, EditProfileView

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
```bash
# Admin--> Email: laini@graduate.utm.my  Password: admin001
# Invigilator--> Email: koryee.heng@graduate.utm.my   Password: staff001
```