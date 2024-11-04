import tensorflow as tf
import tf2onnx
import torch
import os

def convert_keras_to_onnx(keras_model_path, onnx_model_path):
    # Load Keras model
    keras_model = tf.keras.models.load_model(keras_model_path)

    # Convert to ONNX
    spec = (tf.TensorSpec((None, 224, 224, 3), tf.float32, name="input"),)  # Adjust the input shape as necessary
    model_proto, _ = tf2onnx.convert.from_keras(keras_model, input_signature=spec)

    # Save ONNX model
    with open(onnx_model_path, 'wb') as f:
        f.write(model_proto.SerializeToString())
    
    print(f"ONNX model saved to {onnx_model_path}")


def convert_pytorch_to_onnx(pytorch_model_path, onnx_model_path):
    # Load PyTorch model
    model = torch.load(pytorch_model_path)
    model.eval()  # Set the model to evaluation mode

    # Create a dummy input tensor
    dummy_input = torch.randn(1, 3, 224, 224)  # Adjust input size as necessary

    # Export to ONNX
    torch.onnx.export(model, dummy_input, onnx_model_path, 
                      export_params=True, 
                      opset_version=11,  # Use a suitable ONNX opset version
                      do_constant_folding=True,
                      input_names=['input'],  # Name of the input layer
                      output_names=['output'])  # Name of the output layer

    print(f"ONNX model saved to {onnx_model_path}")


def convert_model(model_type, model_path, onnx_model_path):
    if model_type == 'keras':
        convert_keras_to_onnx(model_path, onnx_model_path)
    elif model_type == 'pytorch':
        convert_pytorch_to_onnx(model_path, onnx_model_path)
    else:
        print("Unsupported model type. Use 'keras' or 'pytorch'.")


# Example usage:
if __name__ == "__main__":
    # Adjust these paths as necessary
    keras_model_path = 'models/whisper-tiny.h5'
    pytorch_model_path = 'models/checkpoint.pt'
    onnx_model_path_keras = 'models/whisper-tiny.onnx'
    onnx_model_path_pytorch = 'models/nllb.onnx'

    # Convert Keras model to ONNX
    convert_model('keras', keras_model_path, onnx_model_path_keras)

    # Convert PyTorch model to ONNX
    convert_model('pytorch', pytorch_model_path, onnx_model_path_pytorch)
