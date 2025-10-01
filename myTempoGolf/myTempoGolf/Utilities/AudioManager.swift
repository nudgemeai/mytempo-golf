import Foundation
import AVFoundation
import Combine

class AudioManager: ObservableObject {
    @Published var isEnabled: Bool = true
    @Published var volume: Float = 0.7
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    
    init() {
        setupAudioSession()
        setupAudioEngine()
        setupNotifications()
    }
    
    deinit {
        cleanup()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            print("✅ Audio session setup successful")
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine, let player = playerNode else {
            print("❌ Failed to create audio engine or player")
            return
        }
        
        engine.attach(player)
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
            print("✅ Audio engine started successfully")
        } catch {
            print("❌ Failed to start audio engine: \(error)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhaseChanged(_:)),
            name: .tempoPhaseChanged,
            object: nil
        )
    }
    
    @objc private func handlePhaseChanged(_ notification: Notification) {
        guard isEnabled, let phase = notification.object as? SwingPhase else { return }
        
        print("🔊 Audio triggered for phase: \(phase)")
        
        switch phase {
        case .takeaway:
            playTakeawayTone()
        case .pause:
            playTopTone()
        case .impact:
            playImpactTone()
        default:
            break
        }
    }
    
    private func createToneBuffer(frequency: Double, duration: Double, amplitude: Double = 0.5) -> AVAudioPCMBuffer? {
        let sampleRate = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            print("❌ Failed to create audio buffer")
            return nil
        }
        
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData?[0] else {
            print("❌ Failed to get channel data")
            return nil
        }
        
        let angularFrequency = 2.0 * Double.pi * frequency / sampleRate
        let volumeAmplitude = amplitude * Double(volume)
        
        for i in 0..<Int(frameCount) {
            let sample = sin(angularFrequency * Double(i)) * volumeAmplitude
            channelData[i] = Float(sample)
        }
        
        print("✅ Created tone buffer: \(frequency)Hz, \(duration)s")
        return buffer
    }
    
    private func playTone(frequency: Double, duration: Double = 0.15, amplitude: Double = 0.5) {
        guard isEnabled else {
            print("🔇 Audio disabled, skipping tone")
            return
        }
        
        guard let engine = audioEngine, let player = playerNode, engine.isRunning else {
            print("❌ Audio engine not running")
            return
        }
        
        guard let buffer = createToneBuffer(frequency: frequency, duration: duration, amplitude: amplitude) else {
            print("❌ Failed to create tone buffer")
            return
        }
        
        DispatchQueue.main.async {
            if player.isPlaying {
                player.stop()
            }
            
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            player.play()
            
            print("🔊 Playing tone: \(frequency)Hz")
        }
    }
    
    // Fred Couples signature audio cues
    func playTakeawayTone() {
        print("🏌️ Takeaway tone")
        playTone(frequency: 440, duration: 0.1, amplitude: 0.4) // Low A note
    }
    
    func playTopTone() {
        print("⏸️ Top/Pause tone")
        playTone(frequency: 880, duration: 0.15, amplitude: 0.6) // High A note
    }
    
    func playImpactTone() {
        print("💥 Impact tone")
        playTone(frequency: 1760, duration: 0.2, amplitude: 0.8) // Very high A note
    }
    
    // Test function to verify audio works
    func testAudio() {
        print("🧪 Testing audio...")
        playTone(frequency: 523, duration: 0.5) // C note
    }
    
    func setVolume(_ newVolume: Float) {
        DispatchQueue.main.async {
            self.volume = max(0.0, min(1.0, newVolume))
            self.audioEngine?.mainMixerNode.outputVolume = self.volume
            print("🔊 Volume set to: \(self.volume)")
        }
    }
    
    func setEnabled(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.isEnabled = enabled
            print("🔊 Audio enabled: \(enabled)")
        }
    }
    
    private func cleanup() {
        NotificationCenter.default.removeObserver(self)
        
        DispatchQueue.main.async {
            self.playerNode?.stop()
            self.audioEngine?.stop()
            print("🧹 Audio manager cleaned up")
        }
    }
}