import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class FMRIPredictionPage extends StatefulWidget {
  const FMRIPredictionPage({super.key});

  @override
  State<FMRIPredictionPage> createState() => _FMRIPredictionPageState();
}

class _FMRIPredictionPageState extends State<FMRIPredictionPage> {
  File? selectedFile;
  String? prediction;
  bool isLoading = false;

  Future<void> pickNiiFile() async {
    bool granted = await requestStoragePermission();

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to pick a file.')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
      print("Selected file path: ${selectedFile!.path}");
    } else {
      print("File selection cancelled or failed");
    }
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        final status = await Permission.photos.request(); // For images and files on Android 13+
        return status.isGranted;
      } else {
        final status = await Permission.storage.request(); // For Android 12 and below
        return status.isGranted;
      }
    }
    return true; // iOS or other
  }

  Future<void> uploadAndPredict() async {
    if (selectedFile == null) return;

    setState(() {
      isLoading = true;
      prediction = null;
    });

    try {
      final uri = Uri.parse("https://nipunkl-auticare.hf.space/predict-brain/");
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', selectedFile!.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          prediction = responseData['prediction']?.first ?? 'Unknown result';
        });

        await saveResultToFirestore(prediction!);
      } else {
        setState(() {
          prediction = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        prediction = 'Exception occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveResultToFirestore(String result) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "guest";

    await FirebaseFirestore.instance.collection('fmri_predictions').add({
      'uid': uid,
      'result': result,
      'type': 'fMRI-based',
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload fMRI Scan')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🧠 Why Upload fMRI Scan?",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              "While questionnaire predictions detect behavioral symptoms, "
              "fMRI scans offer clinical insights into brain structure and "
              "activity, enhancing prediction accuracy.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickNiiFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Select .nii.gz File"),
            ),
            const SizedBox(height: 10),
            if (selectedFile != null)
              Text("Selected: ${selectedFile!.path.split('/').last}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadAndPredict,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Upload and Predict"),
            ),
            const SizedBox(height: 30),
            if (prediction != null)
              Card(
                elevation: 4,
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "🧾 Prediction Result:\n$prediction\n(Source: fMRI Analysis)",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
