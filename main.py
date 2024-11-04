import whisper
from googletrans import Translator
from deep_translator import GoogleTranslator
from gtts import gTTS


import torchaudio
import torch
import os
# from TTS.utils import setup_logging
# from TTS.utils.generic_utils import download_model
# from TTS.utils.synthesizer import Synthesizer

def transcribe_audio(file_path):
    """Transcribe audio from MP3 file to text using Whisper."""
    # Check if a GPU is available and use it; otherwise, use CPU
    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Device: {device}")
    model = whisper.load_model("base").to(device)  # Load model and send it to the specified device
    result = model.transcribe(file_path, language="en")  # Optionally specify the language
    return result['text']


def translate_text(text, target_language="es"):
    """Translate text to the target language using Google Translate."""
    # translator = Translator()
    # translation = translator.translate(text, dest=target_language)
    # return translation.text
    translated = GoogleTranslator(source='auto', target=target_language).translate(text)  # output -> Weiter so, du bist großartig
    return translated

# def text_to_speech(text, model_name="tts_models/en/ljspeech/glow-tts", output_file="output.wav"):
#     """Convert text to speech using Coqui TTS."""
#     setup_logging()
#     synthesizer = Synthesizer(model_name)

#     # Synthesize the speech
#     wav = synthesizer.tts(text)
#     torchaudio.save(output_file, wav.unsqueeze(0), 22050)  # Save at 22050Hz sample rate
#     print(f"Generated speech saved to {output_file}")

def text_to_speech(text, target_language='es', output_file="output.mp3"):
    """Convert text to speech using gTTS."""
    # Create a gTTS object
    tts = gTTS(text=text, lang=target_language, slow=False)  # Set the desired language

    # Save the audio to a file
    tts.save(output_file)
    print(f"Generated speech saved to {output_file}")

    # Optionally, you can convert mp3 to wav if needed
    # You can use pydub or any other library for conversion
    # Example using pydub
    # from pydub import AudioSegment
    # AudioSegment.from_mp3(output_file).export(output_file.replace(".mp3", ".wav"), format="wav")


def main(mp3_file, target_language="es"):
    """Main function to execute the flow."""
    # Step 1: Transcribe audio
    print("Transcribing audio...")
    transcription = transcribe_audio(mp3_file)
    print("Transcription:", transcription)
    
    # Step 2: Translate text
    print("Translating text...")
    translated_text = translate_text(transcription, target_language)
    print("Translated Text:", translated_text)
    
    # Step 3: Convert text to speech
    print("Converting translated text to speech...")
    text_to_speech(translated_text, target_language)

if __name__ == "__main__":
    mp3_file = "audio.wav"  # Replace with your MP3 file path
    main(mp3_file, target_language='fr')
