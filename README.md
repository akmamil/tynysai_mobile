# TynysAI Mobile

Flutter mobile application for AI-powered chest X-ray analysis.

This project was developed as part of a diploma thesis and represents a mobile client for the TynysAI platform.

---

# Features

## Authentication
- JWT-based login
- Registration flow
- Secure token storage
- Splash/session restore

## X-Ray Analysis Flow
- Upload chest X-ray images
- Select image from gallery or camera
- AI-style asynchronous analysis lifecycle
- Polling-based status updates:
  - PENDING
  - PROCESSING
  - COMPLETED
- Detailed result screen

## Profile Management
- View patient profile
- Edit profile information

## Notifications
- Notification list
- Mock notification system

## History
- X-ray analysis history
- Detailed analysis view

---

# Tech Stack

## Frontend
- Flutter
- Dart
- Riverpod
- Dio

## Architecture
- Feature-first architecture
- Repository pattern
- Remote datasource layer
- Provider-based state management

## Backend Integration
- REST API
- JWT authentication
- Mock/Postman-driven development
- Backend-ready architecture

---

# Project Structure

```text
lib/
├── app/
├── core/
├── features/
│   ├── auth/
│   ├── home/
│   ├── notifications/
│   ├── profile/
│   └── xray/
└── shared/
```

---

# MVP Flow

```text
Login
→ Home
→ Upload X-Ray
→ Polling Analysis
→ Result Screen
→ History / Notifications / Profile
```

---

# Mock Environment

The application currently supports a mock-driven workflow for AI analysis simulation.

Implemented mock features:
- Mock authentication
- Mock profile data
- Mock notifications
- Mock X-ray analysis lifecycle
- Mock polling state machine

---

# Running the Project

## Requirements
- Flutter SDK
- Android Studio
- Android Emulator or physical device

## Install dependencies

```bash
flutter pub get
```

## Run the app

```bash
flutter run --dart-define-from-file=env.json
```

---

# Android Testing

Tested on:
- Windows
- Android Emulator (API 35)

---

# Future Improvements

- Real backend integration
- Real AI inference pipeline
- Push notifications
- Better UI/UX polish
- Dark mode
- Cloud image storage

---

# Diploma Context

This application was developed as a diploma project focused on:
- mobile healthcare applications
- AI-assisted diagnostics
- asynchronous processing workflows
- Flutter cross-platform development

---

# Author

Akmaral Orynbassar

---

# Repository

GitHub:
https://github.com/akmamil/tynysai_mobile
