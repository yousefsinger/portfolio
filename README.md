# 🚀 Mahmoud Dahy - Professional Flutter Portfolio

<div align="center">

  ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
  ![Clean Architecture](https://img.shields.io/badge/Clean-Architecture-green?style=for-the-badge)

  **A sleek, production-ready portfolio application featuring personal branding, dynamic project management, and a robust admin dashboard.**

</div>

---

## 📺 Project Showcase (Demo Video)
> **Explore the features and smooth UI interactions of the portfolio.**

<div align="center">
  <video src="https://github.com/user-attachments/assets/a7592686-e9e7-45a7-aed0-155ddba90681" width="800" controls style="border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.2);">
    Your browser does not support the video tag.
  </video>
  <br><br>
  <strong style="font-size: 1.2em; color: #02569B;">✨ Project Walkthrough ✨</strong>
</div>

---

## 📖 Overview

`MD Portfolio` is a comprehensive Flutter-based solution for developers to showcase their work, skills, and professional journey. Built with **Clean Architecture** principles and **Clean Code** standards, it ensures high performance, maintainability, and scalability.

The project features a **real-time backend powered by Firebase**, allowing updates without the need for manual redeployment. It also includes an **Admin Dashboard** for content management and a fully **Responsive Design** that looks stunning on mobile, tablet, and web.

---

## ✨ Key Features

- **📱 Fully Responsive Design**: Adapts seamlessly to all screen sizes (Mobile, Tablet, Desktop).
- **🔒 Role-Based Access**: Specialized views for Visitors and a secure Admin Dashboard.
- **📝 Practical Experience Section**: Showcase professional roles, responsibilities, and timelines dynamically.
- **🏗️ Content Management**: Add, update, or remove Projects, Certificates, and Experiences directly from the app.
- **🔥 Firebase Integration**: Dynamic data persistence using Cloud Firestore with real-time UI synchronization.
- **📧 Interactive Contact Form**: Integrated with **EmailJS** and featuring a smart **Spam Prevention** system (Rate Limiting).
- **🌗 Theme Management**: Smooth Dark/Light mode transitions handled via `Bloc/Cubit`.
- **🚀 Premium Aesthetics**: Polished UI with micro-animations powered by `flutter_animate` and custom typography.
- **🛡️ Clean Architecture**: Decoupled layers (Presentation, Domain, Data) for maximum testability and growth.

---

## 🛠️ Tech Stack & Architecture

### **Core**
- **Framework**: Flutter (Stable)
- **Language**: Dart
- **Architecture**: Clean Architecture (Feature-driven)

### **Infrastructure**
- **Storage/Database**: Cloud Firestore
- **State Management**: flutter_bloc (Cubit)
- **Form Handling**: EmailJS API

### **Key Packages**
- `flutter_bloc`: Reliable state management.
- `get_it`: Service locator for Dependency Injection.
- `go_router`: Modern declarative routing system.
- `flutter_animate`: Micro-animations and visual transitions.
- `google_fonts`: Premium typography integration.
- `shared_preferences`: Persistent local storage for user settings and security.

---

## 📂 Project Structure

```text
lib/
├── core/            # Global constants, theme, DI, and routing
├── features/        # Business features
│   ├── admin/       # Management dashboard logic & UI
│   ├── auth/        # Role selection & authentication flow
│   └── portfolio/   # Main portfolio sections (Home, About, Projects, etc.)
└── main.dart        # Application entry point
```

---

## 🚀 Getting Started

### **1. Prerequisites**
* Flutter SDK (Latest Stable)
* Firebase Account & Project
* Node.js (for Firebase CLI optional)

### **2. Setup & Installation**
```bash
# Clone the repository
git clone https://github.com/MahmoudDahy11/PortfolioII.git

# Navigate to project directory
cd PortfolioII

# Install dependencies
flutter pub get
```

### **3. Firebase Configuration**
Configure your Firebase project and generate the `firebase_options.dart` file using the FlutterFire CLI:
```bash
flutterfire configure
```

### **4. Run the App**
```bash
# For Web
flutter run -d chrome

# For Desktop/Mobile
flutter run
```

---

## 👨‍💻 Author

**Mahmoud Dahy**
- [LinkedIn](https://www.linkedin.com/in/mahmoud-dahy/)
- [GitHub](https://github.com/MahmoudDahy11)
- [Personal Website](https://mahmoud-dahy.web.app/)

---

<p align="center">
  <i>Built with ❤️ using Flutter & Firebase</i>
</p>
