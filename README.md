# Whisper-Local-UI
A simple, self-hosted web interface for OpenAI's Whisper to make local audio transcription easy with a drag-and-drop UI.

Whisper Local UI
A simple, self-hosted web interface for OpenAI's Whisper to make local audio transcription easy with a drag-and-drop UI. This tool provides a user-friendly frontend that interacts with your local Whisper installation, allowing you to transcribe files without using the command line.

<img width="1788" height="1025" alt="image" src="https://github.com/user-attachments/assets/8a53ef29-5874-4ff1-8097-85717671328d" />



✨ Features
Drag & Drop: Easily upload audio or video files by dragging them into the browser.

Model & Language Selection: Choose the Whisper model, language, and task (transcribe or translate) directly from the UI.

Real-time Progress: A visual progress bar provides feedback during transcription.

Multiple Download Formats: Download the finished transcript as a .txt, .vtt, or .srt file.

Easy Setup & Launch: Includes one-click batch scripts for both installation and launching on Windows.

Self-Hosted: Runs entirely on your local machine. No data is sent to the cloud.



🚀 How to Use
1. First-Time Installation
If this is your first time using the tool, you need to install the dependencies.

Download the WhisperOneClickInstaller.bat script from this repository.

Right-click the file and select "Run as administrator".

Wait for the script to complete. It will install Python, FFmpeg, PyTorch, and Whisper. This may take some time.



2. Launching the Application
Double-click the LaunchWhisperUI.bat file.

A command prompt window will open, and the web interface will automatically launch in your default browser at http://127.0.0.1:5000.

The command prompt window must remain open while you use the application.



📂 Files in This Repository
index.html: The main user interface file (frontend).

server.py: The Flask server that runs on your machine and executes the Whisper commands (backend).

install_whisper.bat: A one-click script to install all required dependencies on Windows.

launch_whisper_ui.bat: A one-click script to start the server and open the UI in your browser.
