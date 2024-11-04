from deep_translator import GoogleTranslator

def translate_text(text, target_language="es"):
    """Translate text to the target language using Google Translate."""
    translated = GoogleTranslator(source='auto', target=target_language).translate(text)
    return translated
