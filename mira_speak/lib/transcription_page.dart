import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:onnxruntime/onnxruntime.dart';

class WhisperTranscriptionPage extends StatefulWidget {
  @override
  _WhisperTranscriptionPageState createState() => _WhisperTranscriptionPageState();
}


class _WhisperTranscriptionPageState extends State<WhisperTranscriptionPage> {
  File? _audioFile;
  String _transcriptionText = '';
  bool _isLoading = false;


  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _transcribeAudio() async {
    OrtEnv.instance.init();
    if (_audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an audio file first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _transcriptionText = '';
    });

    try {
      
      // TODO: Implement actual Whisper ONNX transcription
      // This is a placeholder transcription method
      await Future.delayed(Duration(seconds: 2)); // Simulate processing
      
      setState(() {
        _transcriptionText = 'Transcription will appear here\n'
            'Note: Actual transcription implementation depends on your\n'
            'specific ONNX model and preprocessing steps.';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transcription failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Whisper Transcription'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _pickAudioFile,
                child: Text('Select MP3 File'),
              ),
              SizedBox(height: 16),
              if (_audioFile != null)
                Text('Selected file: ${_audioFile!.path.split('/').last}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _transcribeAudio,
                child: Text('Transcribe'),
              ),
              SizedBox(height: 16),
              if (_isLoading)
                Center(child: CircularProgressIndicator()),
              if (_transcriptionText.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _transcriptionText,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}