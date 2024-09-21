//
//  GameViewController.swift
//  Low
//
//  Created by Main on 9/20/24.
//

import Foundation
import UIKit
import AVFoundation
import CoreHaptics

class GameViewController: UIViewController {

    var neonColors: [UIColor] = [.cyan, .magenta, .yellow, .green]
    var soundPatterns: [String] = ["note1", "note2", "note3", "note4"] // Example sound files
    var currentPattern: [Int] = []
    var player: AVAudioPlayer?
    var hapticEngine: CHHapticEngine?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        prepareHaptics()
        startGame()
    }

    func startGame() {
        generatePattern()
        playPattern()
    }

    // Generate a random pattern for the user to follow
    func generatePattern() {
        currentPattern = (0..<4).map { _ in Int.random(in: 0..<4) }
    }

    // Play the pattern visually and audibly for the user
    func playPattern() {
        for (index, colorIndex) in currentPattern.enumerated() {
            let delay = Double(index) * 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.flashNeonColor(self.neonColors[colorIndex])
                self.playSound(self.soundPatterns[colorIndex])
            }
        }
    }

    // Flash neon color to indicate a pattern step
    func flashNeonColor(_ color: UIColor) {
        let neonView = UIView(frame: self.view.bounds)
        neonView.backgroundColor = color
        neonView.alpha = 0.8
        self.view.addSubview(neonView)

        UIView.animate(withDuration: 0.5, animations: {
            neonView.alpha = 0.0
        }) { _ in
            neonView.removeFromSuperview()
        }
    }

    // Play a sound for a specific pattern step
    func playSound(_ soundName: String) {
        if let path = Bundle.main.path(forResource: soundName, ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("Error loading sound: \(error.localizedDescription)")
            }
        }
    }


    // Set up haptic feedback for correct or incorrect taps
    func prepareHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine failed to start: \(error)")
        }
    }

    func playHapticFeedback() {
        let hapticEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
}
