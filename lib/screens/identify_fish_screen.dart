import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../util/species.dart';

class IdentifyFishScreen extends StatefulWidget {
  const IdentifyFishScreen({super.key});

  @override
  _IdentifyFishScreenState createState() => _IdentifyFishScreenState();
}

class _IdentifyFishScreenState extends State<IdentifyFishScreen> with SingleTickerProviderStateMixin {

  AnimationController? _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController?.dispose();
    super.dispose();
  }

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

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.100.45:5000/api/predict'),  // Use your actual endpoint
      );
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      final response = await request.send();

      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(resBody);
        setState(() {
          _result = '${data['label'].toString().toUpperCase()} (${data['confidence'].toString()}%)';
        });
      } else {
        setState(() {
          _result = 'Failed to classify the image';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
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

  void _showFishInfoDialog({
    required bool isInvasive,
    required File imageFile,
  }) {
    final info = fishInfo[isInvasive ? 'invasive' : 'noninvasive']!;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green[900],
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 🐟 Image at Top
                  SizedBox(
                    width: 400,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: 300,
                          height: 200,
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                  ),



                  const SizedBox(height: 12),

                  SizedBox(
                    width:400,
                    height:300,

                 child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📝 Info Fields
                        for (var entry in info.entries)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.sora(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),

                                children: [
                                  TextSpan(
                                    text: "${entry.key}: ",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: entry.key.toLowerCase().contains("scientific")
                                        ? entry.value
                                        : entry.value,
                                    style: entry.key.toLowerCase().contains("scientific")
                                        ? const TextStyle(fontStyle: FontStyle.italic)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Chip(
                        label: Text(info["Concern Level"] ?? 'Unknown'),
                        avatar: const Icon(Icons.info_outline, color: Colors.white, size: 18),
                        backgroundColor: info["Concern Level"] == "Very Concern"
                            ? Colors.red
                            : Colors.green,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(isInvasive ? 'Invasive' : 'Non Invasive'),
                        avatar: Icon(
                          isInvasive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        backgroundColor: isInvasive ? Colors.red : Colors.green,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ⭐ Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      );
                    }),
                  ),

                  const SizedBox(height: 6),

                  // ℹ️ Info icon
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.info_outline, size: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

  }




  @override
  Widget build(BuildContext context) {
    final String label = _result != null ? _result!.split(' ').first.toLowerCase() : '';
    final bool isInvasive = label == 'invasive';

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Identify Fish Species")),
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
              Column(
                children: [
                  Center(
                    child: Text(
                      'Result: $_result',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isInvasive ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showFishInfoDialog(
                      isInvasive: isInvasive,
                      imageFile: _image!,
                    ),
                    icon: Icon(Icons.info),
                    label: Text("View Species Info"),
                  ),
                ],
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
