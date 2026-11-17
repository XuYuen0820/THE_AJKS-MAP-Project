# Exora

## Installation & Setup

### 1. Clone and Install Dependencies

```bash
# Clone the repository
git clone https://github.com/XuYuen0820/THE_AJKS-MAP-Project.git

# Navigate into the project folder
cd THE_AJKS-MAP-Project
# Then
flutter pub get
```

---

### 2. Run the Application

```bash
flutter run -d chrome --web-port=8080
```
> Press `F12` in Chrome and switch to the **Device Toolbar** (`Ctrl + Shift + M`) to preview the mobile layout.

### 3. Configure Firebase Authentication

The login form uses **email and password**. Firebase Authentication checks the
password, and Firestore provides the staff profile and role.

1. In the Firebase Console, open **Authentication → Sign-in method** and enable
   **Email/Password**.
2. In **Authentication → Users**, create an account for each staff member using
   their email address. Set their password there.
3. In the Firestore `account` collection, make sure each staff document has an
   `email` field that exactly matches the Firebase Authentication email.
4. Publish the Firestore rules from [`firestore.rules`](./firestore.rules).
   Using the Firebase CLI from the repository root:

   ```bash
   firebase deploy --only firestore:rules
   ```

Firebase Authentication remembers a signed-in user when the app is reopened.
The user stays signed in until they choose **Log out**. Log out signs them out
of Firebase Authentication.

The Firestore `passwordHash` field is no longer used for login. Remove old
password values from staff documents after creating the corresponding Firebase
Authentication accounts. A Firestore staff document by itself does not create
a Firebase Authentication account.
