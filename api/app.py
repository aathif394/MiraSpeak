from flask import Flask, request, jsonify, send_file
from flask_cors import CORS

import os
import tempfile
from audio_processing.transcribe import transcribe_audio
from audio_processing.translate import translate_text
from audio_processing.tts import text_to_speech

app = Flask(__name__)
CORS(app)

@app.route("/test", methods=["GET"])
def test():
    return jsonify("Hello")

@app.route('/upload', methods=['POST'])
def upload_file():
    source_lang = "en"
    target_lang = "fr"

    if 'audio_file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['audio_file']
    
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    if file:
        # Save uploaded file to a temporary location
        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp3") as temp_file:
            file.save(temp_file.name)
            temp_file_path = temp_file.name
        
        try:
            # Transcribe the audio
            transcription = transcribe_audio(temp_file_path, source_lang)
            print(f"Transcribed text: {transcription}")
            # Translate the transcription
            translated_text = translate_text(transcription, target_language=target_lang)
            
            # Convert translated text to speech
            output_audio_path = "output.mp3"
            text_to_speech(translated_text, target_language=target_lang, output_file=output_audio_path)
            
            # Clean up temporary file
            os.remove(temp_file_path)

            # Send the URL of the generated audio file
            output_url = f"http://192.168.0.36:5000/audio"  # Adjust this URL as needed
            
        except Exception as e:
            return jsonify({"error": str(e)}), 500

    return jsonify({"audio_url": output_url}), 200

@app.route('/audio', methods=['GET'])
def serve_audio():
    return send_file('output.mp3', mimetype='audio/mp3')

if __name__ == '__main__':
   app.run(debug=True, host="0.0.0.0", port=5000)

