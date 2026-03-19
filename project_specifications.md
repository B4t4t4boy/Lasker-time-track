# Project Specifications: Desktop Time Tracker

## 1. Overview
A lightweight, desktop-first application designed to help users track time spent on specific tasks and activities effortlessly.

## 2. Technology Stack
*   **Framework:** Flutter
*   **Language:** Dart
*   **Target Platforms:** Windows 11 (Primary), Android (Mobile), Debian Linux (Secondary)

## 3. UI/UX Requirements
*   **Aesthetic:** Simple, clean, and highly responsive.
*   **Layout:** A straightforward dashboard displaying all created tasks as individual interactive buttons/cards.

## 4. Core Features & Business Logic
### 4.1. Task Creation
*   The UI must contain a clear, accessible button to add a new task.
*   Upon clicking "Add Task", the user is prompted to enter a task name.
*   Once named, the new task is immediately generated and presented as a new clickable button/card on the main screen.

### 4.2. Time Tracking & State Management
Each task button operates purely on user interaction and dictates its own specific timer. The button will have three distinct visual states based on the timer's status:

1.  **Idle/Default State (Grey)**
    *   **Trigger:** When a task is initially created.
    *   **Action:** No timer is active.

2.  **Active State (Green)**
    *   **Trigger:** When the user clicks a grey (or red) task button.
    *   **Action:** The button visually shifts to **Green**, and the application starts counting the time spent specifically on this task.

3.  **Stopped/Paused State (Red)**
    *   **Trigger:** When the user clicks the button while it is in the Active (Green) state.
    *   **Action:** The button visually shifts to **Red**, and the application strictly stops/pauses the time-tracking for that specific task.

### 4.3. Data Persistence
*   Local data persistence (saving tasks and tracked time so they persist after closing the app).

### 4.4. Task Management
*   Ability to delete or rename existing tasks.

### 4.5. Data Export
*   Exporting time logs.
