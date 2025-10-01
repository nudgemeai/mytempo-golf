import Foundation
import AVFoundation
import Combine

enum MetronomeSound {
    case tick   // Takeaway - crisp, light tick
    case tock   // Pause - deeper, warmer tock  
    case tack   // Impact - bright, prominent tack
}

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
    
    private func createMetronomeBuffer(type: MetronomeSound, duration: Double, amplitude: Double = 0.5) -> AVAudioPCMBuffer? {
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
        
        let volumeAmplitude = amplitude * Double(volume)
        
        switch type {
        case .tick:
            // Sharp, crisp tick sound - high frequency with quick decay
            createTickSound(channelData: channelData, frameCount: Int(frameCount), sampleRate: sampleRate, amplitude: volumeAmplitude)
        case .tock:
            // Deeper, warmer tock sound - lower frequency
            createTockSound(channelData: channelData, frameCount: Int(frameCount), sampleRate: sampleRate, amplitude: volumeAmplitude)
        case .tack:
            // Sharp accent sound - bright and prominent
            createTackSound(channelData: channelData, frameCount: Int(frameCount), sampleRate: sampleRate, amplitude: volumeAmplitude)
        }
        
        print("✅ Created metronome buffer: \(type), \(duration)s")
        return buffer
    }
    
    private func createTickSound(channelData: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double, amplitude: Double) {
        // High-pitched click with exponential decay - like a wooden metronome tick
        let baseFreq = 1200.0
        let angularFreq = 2.0 * Double.pi * baseFreq / sampleRate
        
        for i in 0..<frameCount {
            let t = Double(i) / sampleRate
            let decay = exp(-t * 15.0) // Quick decay
            let sine = sin(angularFreq * Double(i))
            let noise = (Double.random(in: -0.1...0.1)) // Slight noise for realism
            let sample = (sine + noise) * decay * amplitude * 0.8
            channelData[i] = Float(sample)
        }
    }
    
    private func createTockSound(channelData: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double, amplitude: Double) {
        // Lower, warmer sound with longer sustain
        let baseFreq = 800.0
        let angularFreq = 2.0 * Double.pi * baseFreq / sampleRate
        
        for i in 0..<frameCount {
            let t = Double(i) / sampleRate
            let decay = exp(-t * 8.0) // Slower decay than tick
            let sine = sin(angularFreq * Double(i))
            let harmonics = 0.3 * sin(angularFreq * Double(i) * 2.0) // Add some harmonics
            let sample = (sine + harmonics) * decay * amplitude * 0.9
            channelData[i] = Float(sample)
        }
    }
    
    private func createTackSound(channelData: UnsafeMutablePointer<Float>, frameCount: Int, sampleRate: Double, amplitude: Double) {
        // Bright, attention-grabbing sound for impact
        let baseFreq = 1600.0
        let angularFreq = 2.0 * Double.pi * baseFreq / sampleRate
        
        for i in 0..<frameCount {
            let t = Double(i) / sampleRate
            let decay = exp(-t * 12.0)
            let sine = sin(angularFreq * Double(i))
            let harmonics = 0.4 * sin(angularFreq * Double(i) * 1.5) // Brighter harmonics
            let click = t < 0.005 ? sin(angularFreq * Double(i) * 4.0) * 0.2 : 0 // Initial click
            let sample = (sine + harmonics + click) * decay * amplitude
            channelData[i] = Float(sample)
        }
    }
    
    private func playMetronomeSound(_ sound: MetronomeSound, duration: Double = 0.15, amplitude: Double = 0.5) {
        guard isEnabled else {
            print("🔇 Audio disabled, skipping metronome sound")
            return
        }
        
        guard let engine = audioEngine, let player = playerNode, engine.isRunning else {
            print("❌ Audio engine not running")
            return
        }
        
        guard let buffer = createMetronomeBuffer(type: sound, duration: duration, amplitude: amplitude) else {
            print("❌ Failed to create metronome buffer")
            return
        }
        
        DispatchQueue.main.async {
            if player.isPlaying {
                player.stop()
            }
            
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            player.play()
            
            print("🔊 Playing metronome sound: \(sound)")
        }
    }
    
    // Legacy function for test audio - keep simple tone
    private func playTone(frequency: Double, duration: Double = 0.15, amplitude: Double = 0.5) {
        guard isEnabled else {
            print("🔇 Audio disabled, skipping tone")
            return
        }
        
        guard let engine = audioEngine, let player = playerNode, engine.isRunning else {
            print("❌ Audio engine not running")
            return
        }
        
        // Create simple sine wave for test audio
        let sampleRate = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let angularFrequency = 2.0 * Double.pi * frequency / sampleRate
        let volumeAmplitude = amplitude * Double(volume)
        
        for i in 0..<Int(frameCount) {
            let sample = sin(angularFrequency * Double(i)) * volumeAmplitude
            channelData[i] = Float(sample)
        }
        
        DispatchQueue.main.async {
            if player.isPlaying {
                player.stop()
            }
            
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            player.play()
            
            print("🔊 Playing test tone: \(frequency)Hz")
        }
    }
    
    // Fred Couples signature metronome cues
    func playTakeawayTone() {
        print("🏌️ Takeaway tick")
        playMetronomeSound(.tick, duration: 0.1, amplitude: 0.6)
    }
    
    func playTopTone() {
        print("⏸️ Top/Pause tock")
        playMetronomeSound(.tock, duration: 0.15, amplitude: 0.7)
    }
    
    func playImpactTone() {
        print("💥 Impact tack")
        playMetronomeSound(.tack, duration: 0.2, amplitude: 0.8)
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