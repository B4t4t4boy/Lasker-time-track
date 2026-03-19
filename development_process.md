# Development Process & Project Components

## Development Process
This document outlines the step-by-step development process followed for building the Desktop Time Tracker application using Flutter.

### Phase 1: Planning and Setup (Completed)
- Define project specifications.
- Scaffold the initial project structure (even without Flutter runtime natively available yet).
- Set up the dependency map via `pubspec.yaml`.

### Phase 2: Core Logic and State Management (In Progress)
- Implemented the `Task` model (`task_model.dart`) representing individual task entities with specific metadata (id, name, duration, active state).
- Integrated `provider` (`task_provider.dart`) as the chosen state management solution. It handles the list of tasks, toggling task states (idle/active/stopped), and updating the local timers globally.
- Integrated `shared_preferences` into the provider to support local data persistence immediately.

### Phase 3: UI Implementation
- Structured the primary dashboard interface (`dashboard_screen.dart`).
- Created dynamic, reusable task buttons (`task_button.dart`) which observe their specific task state and automatically rebuild to reflect color changes intuitively.

## Project Components Structure

1.  **Models (`lib/models/`)**
    *   `task_model.dart`: Defines the data structure of a Task, including its timer logic properties and JSON serialization for storage.

2.  **State Management (`lib/providers/`)**
    *   `task_provider.dart`: Contains the business logic for managing tasks. Acts as the Single Source of Truth for the UI. Handles starting/stopping standard `Timer.periodic` instances and saving to disk.

3.  **UI Components (`lib/widgets/`)**
    *   `task_button.dart`: A specialized button widget that transitions between Grey, Green, and Red based on the timer's active/idle state.

4.  **Screens (`lib/screens/`)**
    *   `dashboard_screen.dart`: The primary interaction surface housing the Add Task functionality and the grid of Task Buttons.

5.  **Entry Point**
    *   `main.dart`: Bootstraps the Flutter application, initializes the Provider scope, and loads the initial state from SharedPreferences.
