# AutiCare

AutiCare is a cross-platform Flutter application designed to assist in the early prediction and support for Autism Spectrum Disorder (ASD) using both behavioral questionnaires and clinical fMRI scans. The app aims to bridge the gap between behavioral symptom detection and clinical neuroscience, providing a comprehensive tool for users, caregivers, and clinicians.

## Features

- **Behavioral Symptom Assessment:**  
  Users can complete standardized questionnaires to detect behavioral symptoms related to autism.

- **fMRI Scan Upload and Prediction:**  
  The app allows users to upload fMRI brain scan files (`.nii.gz` format). By analyzing these scans, AutiCare provides clinical predictions that enhance the accuracy beyond behavioral assessments.

- **Cloud Integration:**  
  Leveraging Firebase Firestore and Storage, user data and predictions are securely stored and managed.

- **Cross-Platform Support:**  
  Built with Flutter, AutiCare runs on Android, iOS, Windows, Linux, and the web.

## Why fMRI?

While questionnaires are effective in detecting behavioral aspects, fMRI scans offer clinical insight into brain structure and activity patterns, enabling more accurate identification and prediction of autism traits.

## Getting Started

This project is a starting point for a Flutter application. To run the app locally:

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/AkanxRai/AutiCare.git
   cd AutiCare
   ```

2. **Install Dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the App:**
   Choose your platform:
   - For mobile:  
     `flutter run`
   - For desktop/web:  
     `flutter run -d <platform>`

4. **Firebase Setup:**  
   Ensure you have configured your Firebase project and added the necessary configuration files for your platforms (`google-services.json`, `GoogleService-Info.plist`, etc.).

## Project Structure

- `lib/` - Main Dart codebase for Flutter UI and logic.
- `web/` - Web-specific files.
- `linux/`, `windows/` - Platform-specific build scripts and configuration.
- `assets/` - Static assets such as images and fonts.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)

## Contributing

Contributions are welcome! Please open issues or submit pull requests for new features, bug fixes, or suggestions.

## License

This project is licensed under the MIT License.
