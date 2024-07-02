# Registration and Verification System

This project is a Flutter-based application for registering and verifying users. It allows users to register with their name, image, and face features, and provides functionality to retrieve and delete user details.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Database](#database)
- [Contributing](#contributing)

## Features

- **User Registration**: Register users with their name, image, and face features.
- **User Retrieval**: Retrieve a list of all registered users.
- **User Details**: View detailed information of a specific user.
- **User Deletion**: Delete a specific user.
- **Face Authentication**: Verify users via face authentication.

## Installation

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (version 2.0 or higher)
- [Dart](https://dart.dev/get-dart)
- SQLite database

### Steps

1. Clone the repository:

    ```bash
    git clone https://github.com/yourusername/registration-and-verification-system.git
    ```

2. Navigate to the project directory:

    ```bash
    cd registration-and-verification-system
    ```

3. Install the dependencies:

    ```bash
    flutter pub get
    ```

4. Run the app:

    ```bash
    flutter run
    ```

## Usage

### User Registration

1. Open the app.
2. Navigate to the registration screen.
3. Enter the user details.
4. Submit the form to register the user.

### User Retrieval and Deletion

1. Open the app.
2. Navigate to the user list screen.
3. View the list of registered users.
4. Tap on a user to view details or delete the user.

## API Documentation

The project includes a plan for developing an API for managing user registrations. The plan of the detailed API documentation can be found [here](./API_DOCUMENTATION.md).

## Database

The app uses SQLite to manage user data. The database schema includes the following fields:

- `id`: Unique identifier for the user
- `name`: Name of the user
- `image`: Base64 encoded image or file path
- `face_features`: Encoded face features
- `registered_on`: Timestamp of registration

### Database Initialization

The database is initialized with the following command in the app:

```dart
_database = await openDatabase(
  join(await getDatabasesPath(), 'user_database.db'),
  onCreate: (db, version) {
    return db.execute(
      "CREATE TABLE users(id TEXT PRIMARY KEY, name TEXT, image TEXT, faceFeatures TEXT, registeredOn INTEGER)",
    );
  },
  version: 1,
);
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Submit a pull request.
