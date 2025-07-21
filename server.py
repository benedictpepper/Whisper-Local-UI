import os
import sys
import tempfile
import subprocess
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import logging
import shutil

# --- Basic Setup ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
app = Flask(__name__, static_folder='.', static_url_path='')
CORS(app)

# --- Helper Function ---
def is_whisper_installed():
    """Check if the 'whisper' command is available in the system's PATH."""
    try:
        command = "where whisper" if sys.platform == "win32" else "which whisper"
        subprocess.run(command, check=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        logging.info("'whisper' command is available.")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        logging.error("'whisper' command not found. Please ensure OpenAI Whisper is installed and in your system's PATH.")
        return False

# --- API Endpoint ---
@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    """
    Receives audio, runs Whisper, and returns transcripts in multiple formats (txt, vtt, srt).
    """
    if not is_whisper_installed():
        return jsonify({"error": "Whisper is not installed or not in the system's PATH."}), 500

    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400
    
    file = request.files['file']
    model = request.form.get('model', 'small')
    language = request.form.get('language', 'auto')
    task = request.form.get('task', 'transcribe')

    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    # Create a temporary directory to store the uploaded file and the results
    temp_dir = tempfile.mkdtemp()
    try:
        temp_audio_path = os.path.join(temp_dir, file.filename)
        file.save(temp_audio_path)
        
        logging.info(f"File saved to: {temp_audio_path}")
        logging.info(f"Running Whisper with model: {model}, language: {language}, task: {task}")

        command = [
            "whisper",
            temp_audio_path,
            "--model", model,
            "--task", task,
            "--output_dir", temp_dir  # Tell Whisper to save all outputs here
        ]
        if language != "auto":
            command.extend(["--language", language])

        # Execute the command
        process = subprocess.run(
            command,
            check=True,
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        logging.info("Whisper process completed successfully.")

        # --- Read all generated transcript files ---
        base_filename = os.path.splitext(temp_audio_path)[0]
        transcripts = {}
        
        # Loop through the expected file extensions
        for ext in ['.txt', '.vtt', '.srt']:
            file_path = base_filename + ext
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    # The key will be 'txt', 'vtt', or 'srt'
                    transcripts[ext.strip('.')] = f.read()
            except FileNotFoundError:
                logging.warning(f"File not found: {file_path}")
                transcripts[ext.strip('.')] = None # Assign None if a format wasn't generated
        
        # Check if the primary .txt file was created
        if not transcripts.get('txt'):
             raise FileNotFoundError("Primary .txt transcript not found.")
        
        # Return the dictionary with all transcript formats
        return jsonify(transcripts)

    except subprocess.CalledProcessError as e:
        logging.error(f"Whisper process failed: {e.stderr}")
        return jsonify({"error": f"Whisper failed: {e.stderr}"}), 500
    except FileNotFoundError as e:
        logging.error(f"Transcript file not found: {e}")
        return jsonify({"error": "Transcript file not found. Whisper might not have produced output."}), 500
    finally:
        # --- Clean up the temporary directory and all its contents ---
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir)
            logging.info(f"Cleaned up temporary directory: {temp_dir}")


# --- Serve the Frontend ---
@app.route('/')
def serve_index():
    return send_from_directory('.', 'index.html')

# --- Main Execution ---
if __name__ == '__main__':
    if is_whisper_installed():
        print("\n--- Whisper UI Server ---")
        print("Starting server...")
        print("Open your web browser and go to: http://127.0.0.1:5000")
        print("-------------------------\n")
        app.run(host='127.0.0.1', port=5000, debug=False)
    else:
        print("\n---")
        print("ERROR: Could not find the 'whisper' command.")
        print("Please ensure you have installed OpenAI Whisper with 'pip install -U openai-whisper'")
        print("and that its installation location is in your system's PATH.")
        print("---\n")
