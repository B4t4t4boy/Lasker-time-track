# ⏱️ Desktop Time Tracker

A simple, responsive, and lightweight desktop application designed to track time spent across various tasks and activities effortlessly. 

Built with **Flutter**, this app compiles down to native standalone executables for **Linux**, **Windows**, and mobile **Android**, requiring no underlying development dependencies for the end-user.

## ✨ Features
*   **Create Custom Tasks:** Instantly generate new tracked activities.
*   **Intuitive Visual States:** 
    *   ⚪ **Grey:** Idle (Task created, no time tracked)
    *   🟢 **Green:** Active (Timer is currently running)
    *   🔴 **Red:** Stopped (Timer is paused)
*   **Independent Tracking:** Start and stop distinct tasks entirely independently of one another.
*   **Local Persistence:** Automatically saves your timers and logged tasks instantly to your local disk, so you never lose your progress when closing the app.
*   **14-Day Calendar History:** Natively snapshots your cumulative tracking time into a strictly scaled historical grid view automatically spanning the last 14 days.
*   **KDE Plasma Dark Theme:** Custom borderless layout engineered mathematically to match native Breeze Dark desktop environments seamlessly.

## 🛠️ Technology Stack
*   **Framework:** [Flutter](https://flutter.dev/)
*   **Language:** Dart
*   **State Management:** `provider`
*   **Storage Framework:** `shared_preferences`

## 🚀 Installation & Usage

### Windows Setup 🪟
You don't need to compile anything manually! This repository is configured with a fully automated **GitHub Actions CI/CD Pipeline**. 
1. Navigate to the **Actions** tab of this GitHub repository.
2. Click on the latest successful **"Windows Build"** workflow run.
3. Scroll to the bottom and download the **`time-tracker-windows-exe`** zip artifact.
4. Extract the folder and double-click `time_tracker.exe` to start logging time!

### Android Setup 📱
You don't need to compile anything manually! This repository is configured with a fully automated **GitHub Actions CI/CD Pipeline**. 
1. Navigate to the **Actions** tab of this GitHub repository.
2. Click on the latest successful **"Android Build"** workflow run.
3. Scroll to the bottom and download the **`time-tracker-android-apk`** zip artifact.
4. Extract the folder, transfer the `.apk` file to your mobile device, and install it!

### Linux Setup 🐧
To build and compile the native Linux application directly from source:

1. Ensure your system has the required C++ and GTK Desktop dependencies:
   ```bash
   sudo apt update && sudo apt install clang cmake ninja-build libgtk-3-dev
   ```
2. Clone this repository and navigate into it:
   ```bash
   git clone https://github.com/B4t4t4boy/Lasker-time-track.git
   cd Lasker-time-track
   ```
3. Run the application directly or compile the standalone release build:
   ```bash
   flutter run -d linux
   
   # Or build the native executable:
   flutter build linux --release
   ```
*(The standalone Linux release executable will be generated at `build/linux/x64/release/bundle/time_tracker`)*

## 📂 Architecture Overview
*   `lib/models/`: Core data structures containing the timer tracking configurations.
*   `lib/providers/`: Business logic handling all State Management and `shared_preferences` disk writing.
*   `lib/screens/`: Primary interaction surfaces like the Main Dashboard.
*   `lib/widgets/`: Reusable, reactive components (like the dynamic, color-shifting Task Button).
