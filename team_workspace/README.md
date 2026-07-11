# Team Workspace - Task Management Application

A production-ready Flutter task management application built with Clean Architecture, BLoC state management, and Firebase Authentication.

## 📱 Features

### Core Features
- ✅ **Firebase Authentication** - Email/Password signup, login, and session persistence
- ✅ **Task Dashboard** - Paginated task list with infinite scrolling
- ✅ **Pull-to-Refresh** - Refresh tasks with a single gesture
- ✅ **Task CRUD Operations** - Create, read, update, and manage tasks
- ✅ **Task Details** - View comprehensive task information with status toggle
- ✅ **Search & Filter** - Search tasks by title and filter by status/priority
- ✅ **Offline Support** - Local caching with SQLite and automatic online sync
- ✅ **Connectivity Detection** - Real-time network status monitoring
- ✅ **Form Validation** - Comprehensive validation for all user inputs
- ✅ **Error Handling** - Graceful error states with retry mechanisms

### Bonus Features
- 🌙 **Dark Mode** - Full light/dark theme support with persistent preference
- 📊 **Firebase Analytics** - Event tracking and user analytics
- 📝 **Structured Logging** - Production-grade logging with PrettyPrinter
- 🧪 **Testing Setup** - BLoC testing and mocking libraries configured

## 🏗️ Architecture

The application follows **Clean Architecture** with a feature-first directory structure:

## 📦 Dependencies

### State Management
- **flutter_bloc** (^9.1.1) - BLoC pattern implementation for state management
- **equatable** (^2.1.0) - Value equality support for Dart objects

### Firebase
- **firebase_core** (^4.11.0) - Core Firebase SDK for Flutter
- **firebase_auth** (^6.5.4) - Firebase Authentication for email/password and session management
- **firebase_analytics** (^12.4.3) - Event tracking and user analytics

### Network & API
- **dio** (^5.10.0) - Powerful HTTP client for API calls with interceptor support

### Local Storage
- **shared_preferences** (^2.5.5) - Lightweight key-value storage for user preferences
- **sqflite** (^2.4.2) - SQLite database plugin for offline task caching
- **path** (^1.9.0) - Platform-independent file path utilities

### Connectivity
- **connectivity_plus** (^7.2.0) - Real-time network connectivity status monitoring

### Utilities & UI
- **cupertino_icons** (^1.0.8) - iOS-style icons from Cupertino library
- **intl** (^0.20.3) - Internationalization and localization support
- **logger** (^2.7.0) - Structured logging with pretty printing for debugging

### Development Dependencies
- **flutter_test** - Flutter testing framework
- **flutter_lints** (^6.0.0) - Recommended linting rules for Flutter
- **bloc_test** (^10.0.0) - Testing utilities for BLoC pattern
- **mocktail** (^1.0.5) - Mocking library for unit tests
- **dartz** (^0.10.1) - Functional programming utilities (Either, Option types)
