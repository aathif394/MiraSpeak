import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'transcription_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mira Speak',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UploadAudioPage(),
    );
  }
}

class UploadAudioPage extends StatefulWidget {
  @override
  _UploadAudioPageState createState() => _UploadAudioPageState();
}

class _UploadAudioPageState extends State<UploadAudioPage> {
  PlatformFile? _audioFile;
  String? _audioUrl;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _record = AudioRecorder();
  String? _filePath;
  bool _isRecording = false;
  bool _isUploading = false;

  String _inputLanguage = 'en'; // Default input language
  String _outputLanguage = 'es'; // Default output language (example: Spanish)

  // List of languages for dropdown
  final List<String> _languages = ['en', 'es', 'fr', 'de', 'it'];

  // Start recording and save to temporary folder
  Future<void> _startRecording() async {
    if (await _record.hasPermission()) {
      final tempDir = await getTemporaryDirectory();
      _filePath = "${tempDir.path}/audio_record.m4a";
      await _record.start(const RecordConfig(encoder: AudioEncoder.wav), path: _filePath!);
      setState(() => _isRecording = true);

      // Automatically stop recording after a period of silence
      await Future.delayed(Duration(seconds: 5), () async {
        if (_isRecording) {
          await _stopRecording();
        }
      });
    }
  }

  // Stop recording and load file details
  Future<void> _stopRecording() async {
    if (_isRecording) {
      await _record.stop();
      setState(() {
        _isRecording = false;
      });

      // Automatically play the translated audio after recording
      await _uploadAudio();
      await _playAudio();
    }
  }

  // Upload audio to the server
  Future<void> _uploadAudio() async {
    if (_filePath == null) return;

    setState(() => _isUploading = true);

    String url = 'http://192.168.0.36:5000/upload'; // Update with your server URL
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('audio_file', _filePath!));

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      setState(() {
        _audioUrl = json.decode(responseData.body)['audio_url'];
        _isUploading = false;
      });
    } else {
      setState(() => _isUploading = false);
      print('Upload failed with status: ${response.statusCode}');
    }
  }

  // Play audio from server URL
  Future<void> _playAudio() async {
    if (_audioUrl != null) {
      await _audioPlayer.play(UrlSource(_audioUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Audio'),
      actions: [IconButton(
            icon: const Icon(Icons.text_snippet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WhisperTranscriptionPage()),
              );
            },
            tooltip: 'Go to Transcription',
          ),],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _inputLanguage,
                  items: _languages.map((String lang) {
                    return DropdownMenuItem<String>(
                      value: lang,
                      child: Text(lang),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _inputLanguage = value!;
                    });
                  },
                ),
                Text('Input Language: $_inputLanguage'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _outputLanguage,
                  items: _languages.map((String lang) {
                    return DropdownMenuItem<String>(
                      value: lang,
                      child: Text(lang),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _outputLanguage = value!;
                    });
                  },
                ),
                Text('Output Language: $_outputLanguage'),
              ],
            ),
            SizedBox(height: 20),

            // Recording controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isRecording ? null : _startRecording,
                  child: Text('Start Recording'),
                ),
                ElevatedButton(
                  onPressed: _isRecording ? _stopRecording : null,
                  child: Text('Stop Recording'),
                ),
              ],
            ),
            SizedBox(height: 20),

            if (_isUploading) ...[
              Text(
                'Translating...',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(),
              SizedBox(height: 20),
            ] else if (_audioFile != null) ...[
              SizedBox(height: 20),
              Text('Selected File: ${_audioFile!.name}'),
            ],
          ],
        ),
      ),
    );
  }
}
