# Planz 📋

A modern, feature-rich task management Flutter application with voice input and scheduling. Fully offline: all data stays on your device.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## 📸 App Overview 

![Planz App Screenshot](lib/screenshot/planz.png)

## 📱 Features

### Core Functionality
- ✅ **Task Management** - Create, edit, complete, and delete tasks with descriptions
- 🎯 **Priority System** - Four priority levels (Low, Medium, High, Urgent) with color coding
- 📅 **Task Scheduling** - Schedule tasks with specific dates and times
- 🗑️ **Soft Delete** - Deleted tasks can be restored from trash
- 🔍 **Search** - Search through your tasks quickly
- 📊 **Task Statistics** - View completed, pending, and total task counts

### Advanced Features
- 🎤 **Voice Input** - Create tasks using voice commands with natural language processing
- 🗓️ **Calendar View** - Week and month calendar views for scheduled tasks
- ⏰ **Timeline View** - 24-hour timeline showing hourly task schedule
- 🎨 **Custom UI** - Modern, gradient-based UI with smooth animations
- 🔔 **Task Filters** - Filter by Today, This Week, Overdue, and Completed
- 💾 **Local Storage** - Tasks persist locally using Hive database

### User Experience
- 🔒 **Private by Default** - No account needed; nothing leaves the device
- 👤 **Profile** - Your name, task stats, and app reset
- 🌙 **Dark Mode** - Persisted light/dark theme
- 📳 **Haptic Feedback** - Tactile responses for user interactions
- 🎭 **Onboarding** - Beautiful onboarding screens for new users

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management solution
- **Google Fonts** - Custom typography (Inter, Jost)
- **flutter_svg** - SVG asset rendering
- **table_calendar** - Calendar widget implementation
- **smooth_page_indicator** - Page indicator for onboarding

### Backend & Database
- **Hive** - Local storage for tasks (`todo` box), profile (`user_data`), and settings (`settings`)

### Voice & AI
- **speech_to_text** - Voice recognition
- **Custom NLP Parser** - Natural language task parsing

### UI Components
- **dotted_border** - Decorative borders
- **rive** - Advanced animations
- **intl** - Date/time formatting

## 📁 Project Structure

```
planz/
├── lib/
│   ├── auth/                       # Firebase login/register (not used in the offline flow)
│   ├── LandingPages/
│   │   ├── landing.dart            # Onboarding page 1
│   │   ├── landing2.dart           # Onboarding page 2
│   │   ├── landing3.dart           # Onboarding page 3
│   │   ├── landingmain.dart        # Onboarding controller
│   │   └── OnBoardingPage.dart     # Name entry (first run)
│   ├── pages/
│   │   ├── Home.dart               # Main task list view
│   │   ├── List.dart               # Filtered tasks view
│   │   ├── Schedule.dart           # Calendar & timeline view
│   │   ├── Profile.dart            # User profile & settings
│   │   ├── PageNav.dart            # Bottom navigation
│   │   ├── voice.dart              # Voice input screen
│   │   ├── voice_command_parser.dart # NLP for voice commands
│   │   └── deleted_pages.dart      # Trash/deleted tasks
│   ├── providers/
│   │   ├── task_notifier.dart      # Task state management
│   │   ├── task_provider.dart      # Riverpod providers
│   │   ├── theme_provider.dart     # Light/dark theme
│   │   └── user_provider.dart      # User name / onboarding state
│   ├── Widgets/
│   │   ├── bottom_task_sheet.dart  # Task creation bottom sheet
│   │   └── customtextfield.dart    # Reusable text fields
│   ├── router.dart                 # App routing
│   └── main.dart                   # App entry point
├── assets/
│   └── *.svg                       # SVG illustrations
├── pubspec.yaml                    # Dependencies
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Android Studio / VS Code
- iOS development: Xcode (macOS only)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/harshit36singh/Planz.git
cd Planz
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## 📱 App Flow

### 1. Onboarding (first launch only)
- Three intro pages with smooth animations
- Enter your name (or skip). It is stored locally with Hive
- Later launches open straight to Home

### 2. No Account Needed
- Everything is stored on the device; Profile → Reset App erases it

### 3. Task Creation
Three methods to create tasks:

**Manual Entry:**
- Title and description fields
- Priority selector (Low/Medium/High/Urgent)
- Optional due date and time

**Scheduled Tasks:**
- Select specific date from calendar
- Choose time using Cupertino time picker
- Auto-organizes in timeline view

**Voice Input:**
- Natural language processing
- Examples:
  - "Add task buy groceries"
  - "Schedule meeting tomorrow at 3 PM"
  - "Remind me to call mom on Friday"

### 4. Task Management
- **Home View**: All active tasks with priority indicators
- **Schedule View**: Calendar with 24-hour timeline
- **List View**: Filtered task views
- **Profile**: User settings and preferences

### 5. Task Operations
- ✅ Mark as complete
- 📝 Edit task details
- 🗑️ Soft delete (move to trash)
- ♻️ Restore from trash
- 🔥 Permanent delete

## 🎨 Key Features Explained

### Priority System
Tasks are color-coded based on priority:
- 🟢 **Low** - Green
- 🔵 **Medium** - Blue  
- 🟠 **High** - Orange
- 🔴 **Urgent** - Red

Each task card has a color-coded left border and subtle background glow.

### Voice Command Parser
Natural language processing supports:
- Date parsing: "today", "tomorrow", "December 15", "next Monday"
- Time parsing: "at 3 PM", "at 15:30"
- Action words: "add", "schedule", "remind me to"

Example commands:
```
"Add task finish project report"
"Schedule dentist appointment tomorrow at 2 PM"
"Remind me to call John on Friday at 10 AM"
```

### Timeline View
24-hour schedule visualization:
- "All day" row for tasks with a date but no time
- Hourly slots from 12:00 AM to 11:00 PM
- Current hour highlighted
- Multiple tasks per hour supported
- Auto-scroll to the current hour (or the first task on other days)

### Soft Delete System
- Deleted tasks stored with timestamp
- Swipe to delete, with undo
- Trash (bin icon on Home) lists all deleted tasks
- Restore, permanently delete, or empty the trash

## 🔧 Configuration

### Priority Colors
Edit in `lib/providers/task_notifier.dart`:
```dart
extension TaskPriorityExtension on TaskPriority {
  Color get color {
    switch (this) {
      case TaskPriority.low: return Colors.green;
      case TaskPriority.medium: return Colors.blue;
      case TaskPriority.high: return Colors.orange;
      case TaskPriority.urgent: return Colors.red;
    }
  }
}
```

### Theme
Light and dark themes live in `lib/providers/theme_provider.dart` (`AppTheme`);
the dark mode switch is on the Profile page.

## 📦 Dependencies

### Core
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.0

  # Storage
  hive: latest
  hive_flutter: latest
  
  # UI
  google_fonts: latest
  flutter_svg: latest
  table_calendar: latest
  smooth_page_indicator: latest
  dotted_border: latest
  
  # Voice
  speech_to_text: latest
  
  # Utils
  intl: latest
```

