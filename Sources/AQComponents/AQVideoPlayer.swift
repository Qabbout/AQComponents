//
//  AQVideoPlayer.swift
//
//
//  Created by Abdulrahman Qabbout on 16/04/2024.
//

import AVFoundation
import UIKit

protocol AQVideoPlayerDelegate: AnyObject {
    func playbackTimeChanged(to timeElapsed: Float)
}

public final class AQVideoPlayer: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    
    weak var delegate: AQVideoPlayerDelegate?
    
    // UI Components
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.tintColor = .white
        button.addTarget(AQVideoPlayer.self, action: #selector(togglePlayPause), for: .touchUpInside)
        return button
    }()
    
    private let timeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.thumbTintColor = .white
        slider.tintColor = .white
        slider.addTarget(AQVideoPlayer.self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()

    // Initialize with frame
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // Initialize with coder for storyboard use
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupPlayer()
        setupUI()

    }
    // Setup player
    private func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else { return }
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = .resizeAspect
        self.layer.addSublayer(playerLayer)
        self.addSubview(playPauseButton)
        self.addSubview(timeSlider)
    }
    // Setup UI components
    private func setupUI() {
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        timeSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playPauseButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            playPauseButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            timeSlider.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            timeSlider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            timeSlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func togglePlayPause() {
        if player?.timeControlStatus == .paused {
            player?.play()
            playPauseButton.setTitle("Pause", for: .normal)
        } else {
            player?.pause()
            playPauseButton.setTitle("Play", for: .normal)
        }
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        let duration = player?.currentItem?.duration.seconds ?? 0
        let value = Float64(slider.value) * duration
        let seekTime = CMTime(seconds: value, preferredTimescale: 600)
        player?.seek(to: seekTime)
    }
    
    // Update UI or delegate method to notify current playback time
    private func playbackTimeChanged(to timeElapsed: Float) {
        let duration = player?.currentItem?.duration.seconds ?? 0
        timeSlider.value = Float(timeElapsed) / Float(duration)
        delegate?.playbackTimeChanged(to: timeElapsed)
    }
    
    // Load and play a video from a URL
    public func playVideo(from url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player?.replaceCurrentItem(with: playerItem)
        addPeriodicTimeObserver()
        player?.play()
    }
    
    // Stop the video
    public func stop() {
        player?.pause()
        player?.seek(to: .zero)
        removePeriodicTimeObserver()
    }
    
    // MARK: Observing Playback Progress
    private func addPeriodicTimeObserver() {
        // Notify every half second
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let timeElapsed = Float(time.seconds)
            self?.playbackTimeChanged(to: timeElapsed)
        }
    }
    
    private func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    // MARK: Handle Player Resize
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }

}

