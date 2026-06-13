# Qari 24/7 📖✨

Qari 24/7 is a state-of-the-art Flutter mobile application designed to facilitate real-time Quran recitation tracking, interactive learning, and AI-powered voice detection feedback. 

This repository currently hosts the **Phase 1: Frontend & AI Interface** implementation.

---

## 🚀 Project Overview

The first phase focus is a premium, high-fidelity frontend combined with robust local service architectures and core integration setups.

### 🌟 Key Features (Phase 1 Completed)
* **Real-time Recitation & AI Detection (`recitation`):**
  * Interactive recitation screen with synchronized Quranic text and elegant audio controllers.
  * Integration framework for real-time recitation voice analysis and pronunciation detection (`recitation_ai_service`).
  * Offline-first download manager for high-quality audio files.
* **Onboarding & Authentication (`auth` & `onboarding`):**
  * Premium glassmorphic walkthrough screen.
  * Firebase Auth integration prepared with Google Sign-In certificates.
* **Interactive Community Portal (`community`):**
  * Social circles, explore card views, and interactive bottom sheets to foster community recitation.
* **Analytics & Progress (`progress`):**
  * Advanced graphs and streak tracking metrics to measure daily, weekly, and monthly recitation progress.
* **Premium Subscriptions (`subscription`):**
  * Sleek pricing matrices, receipt listings, checkout fields, and plan management screen.
* **Settings & Profiles (`settings` & `profile`):**
  * Modular system control, subscription statuses, and localization preferences.
  * Added detailed premium information screens: **About QARI 24/7**, **Help Center**, **Terms of Service**, and **Privacy Policy** with dynamic light/dark theme support.
  * Integrated contact support email (`Thehub923community@gmail.com`) with instant copy-to-clipboard actions.
  * Styled the Logout confirmation popup Cancel button to use the primary green color (`AppColors.primary`).

---

## 🛠️ Technology Stack

* **Framework:** Flutter (Channel stable, `3.41.3` / `3.29.0`)
* **Language:** Dart (`3.11.1` / `3.7.0`)
* **State Management & DI:** `GetX` (robust, reactive, and fast)
* **HTTP Client:** `Dio` (fully customizable interceptors and cache management)
* **Real-time Streaming:** WebSockets via `web_socket_channel`
* **Audio Engine:** `audioplayers` & `record`
* **Local Storage:** `shared_preferences` & `path_provider`
* **Database & Auth Config:** Firebase (Firebase Core initialized securely)

---

## 🔒 Security & Ignored Configurations
To prevent automated secret scanning warnings (such as GitGuardian or GitHub alerts) on public repositories, all Firebase keys and configuration profiles are kept strictly on the local machine and are ignored by git:
* `android/app/google-services.json` (Ignored)
* `lib/firebase_options.dart` (Ignored)
* `ios/Runner/GoogleService-Info.plist` (Ignored)

---

## 📅 Roadmap: Phase 2 (Backend Connection)
In the next phase, we will connect the live production backend services:
1. **Live WebSockets Streaming:** Route real-time audio streams directly to our hosted Python/AI service (`quran_recitation_detection`) for low-latency voice detection.
2. **REST API Endpoints Integration:** Fully sync community feeds, user profile updates, saved lists, and subscription checkouts with the remote API database.
3. **Firebase Cloud Features:** Dynamic updates, Push notifications (`firebase_messaging`), and Firestore-backed authentication.

---

## 🛠️ Getting Started Locally

### Prerequisites
* Flutter SDK (version `>=3.11.0`)
* Android SDK & Xcode (for iOS build support)

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/hamim5264/qari24-7.git
   cd qari24-7
   ```
2. **Install all dependencies:**
   ```bash
   flutter pub get
   ```
3. **Firebase Configuration:**
   Because configuration files are ignored for security, generate them for your local environment using the Firebase CLI:
   ```bash
   flutterfire configure --project=qari24-7
   ```
4. **Run the application:**
   ```bash
   flutter run
   ```

---

*Made with ❤️ for Quran Recitation and AI Innovation.*
