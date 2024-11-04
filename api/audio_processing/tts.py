from gtts import gTTS

def text_to_speech(text, target_language='es', output_file="output.mp3"):
    """Convert text to speech using gTTS."""
    # Create a gTTS object
    tts = gTTS(text=text, lang=target_language, slow=False)

    # Save the audio to a file
    tts.save(output_file)
    print(f"Generated speech saved to {output_file}")
