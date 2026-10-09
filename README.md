# Workout Tracking App

A Flutter mobile application designed to help users organize their workouts, save exercises, and mark exercises as completed. Developed as a university group project, the app focuses on a simple interface and local data storage.

## Project Overview

The app allows users to register, log in, and manage their workout routines. Users can add exercises, view previously saved exercises, and tick off each exercise after completing it.

Workout data is stored locally on the device, allowing users to access their saved routines without an internet connection.

## Core Features

- **Registration and login:** Create an account and sign in.
- **Add exercises:** Add exercises to a workout routine.
- **View saved exercises:** Access previously saved workout details.
- **Track completion:** Mark each exercise as completed during a workout.
- **Local storage:** Keep saved workout data available between app sessions.

## Technology and Architecture

- **Framework:** Flutter
- **Programming language:** Dart
- **Architecture:** Model–View–ViewModel (MVVM)
- **Storage:** Local on-device database
- **UI design:** Material 3 with an expressive green-and-black theme and large icons
- **Version control:** Git and GitHub
- **Project management:** Jira

MVVM separates the application into three main responsibilities:

| Layer | Responsibility |
|---|---|
| Model | Represents application data, such as users and exercises. |
| View | Displays screens and captures user interactions. |
| ViewModel | Manages screen state, handles user actions, and communicates with the data layer. |

This separation makes the code easier to maintain, test, and divide among team members.

## Development Approach

The project is planned for **four weeks with a team of four members**, using an Agile approach. Work covers requirements analysis, UI design, implementation, testing, and documentation. Jira tracks tasks and progress, while GitHub supports collaboration and code reviews.

## Testing Plan

- **Unit testing:** Validate input rules and ViewModel logic.
- **Widget testing:** Check forms, buttons, exercise lists, and completion checkboxes.
- **Integration testing:** Verify complete flows, including registration, login, saving exercises, and restoring saved data.
