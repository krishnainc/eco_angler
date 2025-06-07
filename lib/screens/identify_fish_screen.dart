import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class IdentifyFishScreen extends StatefulWidget {
  @override
  _IdentifyFishScreenState createState() => _IdentifyFishScreenState();
}

class _IdentifyFishScreenState extends State<IdentifyFishScreen> {
  File? _image;
  String? _result;
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = null;
      });
    }
  }


  Future<void> _sendToModel(File image) async {
    setState(() => _loading = true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://<your-server-ip>:<port>/predict'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    setState(() {
      _result = response.statusCode == 200 ? resBody : 'Failed to classify';
      _loading = false;
    });
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Identify Fish Species")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔷 Intro Text
            Text(
              "What are invasive fish species?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Invasive species are non-native fish that disrupt local aquatic ecosystems. "
                  "They can outcompete native species, spread diseases, and damage habitats.\n\n"
                  "Use this tool to help identify whether a fish you’ve caught or found is invasive or not.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),

            /// 📸 Image preview
            if (_image != null)
              Center(
                child: Column(
                  children: [
                    Image.file(_image!, height: 250),
                    SizedBox(height: 10),
                  ],
                ),
              ),

            /// 🟢 Result
            if (_loading)
              Center(child: CircularProgressIndicator()),
            if (_result != null)
              Center(
                child: Text(
                  'Result: $_result',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),

            /// 🔘 Buttons
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.camera_alt),
                label: Text("Upload Fish Photo"),
                onPressed: _showImageSourcePicker,
              ),
            ),

            if (_image != null)
              Center(
                child: ElevatedButton(
                  onPressed: () => _sendToModel(_image!),
                  child: Text("Identify Species"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
