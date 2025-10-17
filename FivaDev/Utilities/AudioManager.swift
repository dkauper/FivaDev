//
//  AudioManager.swift
//  FivaDev
//
//  Created: October 12, 2025, 10:50 PM Pacific
//  Updated: October 17, 2025, 10:10 AM Pacific - Fixed audio file loading with platform-specific imports
//  Manages game audio playback
//

import Foundation
import AVFoundation
import Combine

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Manages game audio playback
class AudioManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    /// Plays the crowd cheer sound for winning
    @MainActor
    func playCrowdCheer() {
        // Try multiple paths to find the audio file
        var soundURL: URL?
        
        // Method 1: Try as data asset (iOS/macOS)
        #if canImport(UIKit) || canImport(AppKit)
        if let asset = NSDataAsset(name: "Crowd_Cheer") {
            // Write to temp file to play
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Crowd_Cheer.mp3")
            do {
                try asset.data.write(to: tempURL)
                soundURL = tempURL
                print("🎵 AudioManager: Found audio in data asset")
            } catch {
                print("⚠️ AudioManager: Could not write data asset to temp file - \(error)")
            }
        }
        #endif
        
        // Method 2: Try direct bundle path
        if soundURL == nil {
            soundURL = Bundle.main.url(forResource: "Crowd_Cheer", withExtension: "mp3")
            if soundURL != nil {
                print("🎵 AudioManager: Found audio in bundle root")
            }
        }
        
        // Method 3: Try with subdirectory
        if soundURL == nil {
            soundURL = Bundle.main.url(forResource: "Crowd_Cheer", withExtension: "mp3", subdirectory: "Audio")
            if soundURL != nil {
                print("🎵 AudioManager: Found audio in Audio subdirectory")
            }
        }
        
        // Method 4: Try assets path
        if soundURL == nil {
            soundURL = Bundle.main.url(forResource: "Assets/Audio/Crowd_Cheer", withExtension: "mp3")
            if soundURL != nil {
                print("🎵 AudioManager: Found audio in Assets/Audio path")
            }
        }
        
        guard let url = soundURL else {
            print("⚠️ AudioManager: Could not find Crowd_Cheer.mp3 in any location")
            print("   Searched:")
            print("   - Data asset: NSDataAsset(name: 'Crowd_Cheer')")
            print("   - Bundle root: Crowd_Cheer.mp3")
            print("   - Audio subdirectory: Audio/Crowd_Cheer.mp3")
            print("   - Assets path: Assets/Audio/Crowd_Cheer.mp3")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.7
            audioPlayer?.play()
            print("🎵 AudioManager: Playing crowd cheer from \(url.lastPathComponent)")
        } catch {
            print("⚠️ AudioManager: Error playing audio - \(error.localizedDescription)")
        }
    }
    
    /// Stops currently playing audio
    @MainActor
    func stopAudio() {
        audioPlayer?.stop()
    }
}
