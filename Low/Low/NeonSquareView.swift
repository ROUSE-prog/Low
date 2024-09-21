import SwiftUI
import AVFoundation

struct NeonSquareView: View {
    @Binding var square: NeonSquare
    var onDelete: () -> Void
    @State private var offset = CGSize.zero
    @State private var player: AVAudioPlayer?

    var body: some View {
        Rectangle()
            .fill(square.color)
            .frame(width: 100, height: 100)
            .position(x: square.position.width + offset.width, y: square.position.height + offset.height)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        self.offset = gesture.translation
                    }
            )
            .onTapGesture(count: 2) {
                playSound(square.soundURL)
            }
            .contextMenu {
                Button(action: onDelete) {
                    Text("Delete")
                    Image(systemName: "trash")
                }
            }
    }

    // Play sound associated with the square
    func playSound(_ url: URL?) {
        guard let url = url else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}
