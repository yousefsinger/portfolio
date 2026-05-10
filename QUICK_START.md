# Full Setup Guide

Follow these detailed steps to get your portfolio project running with your own Firebase and EmailJS accounts.

## 1. Firebase Integration (Step-by-Step)
Since the original configuration was removed, you must link the app to your own Firebase project.

### Step A: Login & CLI Setup
1. Open your terminal in the project root.
2. Login to Firebase:
   ```bash
   firebase login
   ```
3. Install the FlutterFire CLI globally:
   ```bash
   dart pub global activate flutterfire_cli
   ```

### Step B: Create & Configure Project
1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Run the configuration tool in your terminal:
   ```bash
   flutterfire configure
   ```
3. Select your project from the list and choose the platforms (Android, iOS, Web).
4. This command will automatically generate `lib/firebase_options.dart`.

### Step C: Update `lib/main.dart`
Now, re-enable Firebase in the code:
1. Open `lib/main.dart`.
2. Add these imports at the top:
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'firebase_options.dart';
   ```
3. Uncomment the initialization block inside `main()`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();

     // Initialize Firebase
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );

     await setupDI();
     runApp(const MyApp());
   }
   ```

## 2. Admin Mode & Credentials
The project features an Admin Dashboard where you can manage your skills, projects, and certificates without touching the code.

- **To Enter Admin Mode**: Choose "Admin" when the app starts and enter the code.
- **Default Code**: `123456`
- **How to Change the Code**: 
  1. Open `lib/core/constants/app_constants.dart`.
  2. Find `static const String adminCode = '123456';`.
  3. Change `'123456'` to your preferred password.

## 3. EmailJS Setup (Contact Form)
The contact form uses EmailJS to send emails directly from the browser.

### How to get credentials:
1. Create an account at [EmailJS](https://www.emailjs.com/).
2. **Service ID**: Go to "Email Services" -> Add New Service (e.g., Gmail) -> Copy the **Service ID**.
3. **Template ID**: Go to "Email Templates" -> Create New Template -> Save -> Copy the **Template ID**.
4. **Public Key**: Go to "Account" -> API Keys -> Copy the **Public Key**.

### Link to the App:
1. Open `lib/core/constants/app_constants.dart`.
2. Fill in your keys:
   ```dart
   static const String serviceId = 'YOUR_SERVICE_ID';
   static const String templateId = 'YOUR_TEMPLATE_ID';
   static const String publicKey = 'YOUR_PUBLIC_KEY';
   ```

## 4. Run the Project
```bash
flutter pub get
flutter run
```

## 5. Pro Tips 💡
- **Firestore Collections**: The app expects collections named `profile`, `projects`, `skills`, and `certificates`. You can add your first entries through the Firebase Console or the app's Admin panel.
- **Image Hosting**: Use Firebase Storage or a cloud service (like Cloudinary) for your images, then paste the URL into the Admin panel.
- **GitHub Actions**: If you want to deploy to Firebase Hosting automatically, run `firebase init hosting` and follow the prompts for GitHub Actions.

---
*Success! Your portfolio is now ready to be customized.* 🚀
