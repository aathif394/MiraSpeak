import whisper
import torch

def transcribe_audio(file_path, source_language="en"):
    """Transcribe audio from audio file to text using Whisper."""
    # Check if a GPU is available and use it; otherwise, use CPU
    # device = "cuda" if torch.cuda.is_available() else "cpu"
    device = "cpu"
    print(f"Device: {device}")
    
    # Load the Whisper model and send it to the specified device
    model = whisper.load_model("base").to(device)
    
    # Transcribe the audio
    result = model.transcribe(file_path, language=source_language)
    return result['text']
