import SwiftUI
import AVFoundation
struct NeonSquare: Identifiable {
    var id = UUID() // Unique identifier for each square
    var color: Color // The neon color for the square
    var soundURL: URL? // URL pointing to the sound file
    var position: CGSize // The position of the square on the screen
}

struct ContentView: View {
    @State private var squares: [NeonSquare] = []
    @State private var selectedColor: Color = .cyan
    @State private var currentRecordingURL: URL?
    
    @State private var player: AVAudioPlayer?
    @State private var isRecording = false
    @State private var recordingSession: AVAudioSession!
    @State private var audioRecorder: AVAudioRecorder!
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Display all neon squares
            ForEach(squares.indices, id: \.self) { index in
                NeonSquareView(square: $squares[index], onDelete: {
                    squares.remove(at: index)
                })
            }
            
            VStack {
                HStack {
                    // Button to add new square
                    Button(action: addNewSquare) {
                        Text("Add Square")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    // Color picker for selecting neon color
                    ColorPicker("Pick Color", selection: $selectedColor)
                        .labelsHidden()
                }
                
                // Record or choose sound
                Button(action: startRecording) {
                    Text(isRecording ? "Stop Recording" : "Record Sound")
                        .foregroundColor(.white)
                        .padding()
                        .background(isRecording ? Color.red : Color.green)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
    
    // Function to add a new square
    func addNewSquare() {
        if let soundURL = currentRecordingURL {
            let newSquare = NeonSquare(color: selectedColor, soundURL: soundURL, position: CGSize(width: 100, height: 100))
            squares.append(newSquare)
            currentRecordingURL = nil // Reset the recording URL
        }
    }
    
    // Start/Stop recording audio
    func startRecording() {
        if isRecording {
            audioRecorder.stop()
            isRecording = false
            currentRecordingURL = audioRecorder.url // Save the recording URL
        } else {
            let filename = getDocumentsDirectory().appendingPathComponent("recording.wav")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.record()
                isRecording = true
            } catch {
                print("Failed to record")
            }
        }
    }
    
    // Helper function to get the documents directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
