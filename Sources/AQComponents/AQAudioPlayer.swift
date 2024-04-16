//
//  AQAudioPlayer.swift
//
//
//  Created by Abdulrahman Qabbout on 16/04/2024.
//

import AVFoundation

public final class AQAudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    public static let shared = AQAudioPlayer()
    private var audioPlayer: AVAudioPlayer?
    
    private override init() {
        super.init()
    }
    
    /// Prepare and play the audio from a given URL
    public func playAudio(from url: URL) {
        do {
            // Activate the audio session
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Initialize and prepare the audio player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            dump("Failed to initialize or play audio: \(error)")
        }
    }
    
    /// Pause the currently playing audio
    public func pauseAudio() {
        audioPlayer?.pause()
    }
    
    /// Stop the audio and reset the player
    public func stopAudio() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        deactivateAudioSession()
    }
    
    /// Reactivate audio session
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            dump("Failed to deactivate audio session: \(error)")
        }
    }
    
    // MARK: - AVAudioPlayerDelegate methods
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        dump("Audio playback finished successfully: \(flag)")
        deactivateAudioSession()
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            dump("Audio playback decoding error: \(error.localizedDescription)")
        }
        deactivateAudioSession()
    }
}
