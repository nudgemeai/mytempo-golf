import Foundation
import SwiftUI

struct TempoSettings: Codable, Equatable {
    var ratio: Double = 3.3 // Fred Couples signature 3.3:1 ratio
    var pauseDuration: Double = 0.1 // Signature pause at top
    var isAudioEnabled: Bool = true
    var isHapticEnabled: Bool = true
    var volume: Double = 0.7
    var visualMode: VisualMode = .circle
    var practiceMode: PracticeMode = .continuous
    var customSwingCount: Int = 20
    
    // Fred Couples tempo specifications
    var backswingDuration: Double {
        return 1.1 // 33 frames at 30fps
    }
    
    var downswingDuration: Double {
        return 0.33 // 10 frames at 30fps
    }
    
    var totalSwingDuration: Double {
        return backswingDuration + pauseDuration + downswingDuration
    }
    
    var bpm: Int {
        return Int(60.0 / totalSwingDuration)
    }
    
    // Preset configurations
    static let couplesClassic = TempoSettings(ratio: 3.3, pauseDuration: 0.1)
    static let couplesSmooth = TempoSettings(ratio: 3.27, pauseDuration: 0.15) // Slightly slower
    static let couplesDriver = TempoSettings(ratio: 3.33, pauseDuration: 0.08) // Faster for driver
    static let trainingTempo = TempoSettings(ratio: 3.0, pauseDuration: 0.05) // More aggressive
}

enum VisualMode: String, CaseIterable, Codable {
    case circle = "Circle"
    case bar = "Bar"
    case pendulum = "Pendulum"
    case color = "Color"
    
    var icon: String {
        switch self {
        case .circle: return "circle"
        case .bar: return "rectangle"
        case .pendulum: return "metronome"
        case .color: return "paintpalette"
        }
    }
}

enum PracticeMode: String, CaseIterable, Codable {
    case continuous = "Continuous"
    case single = "Single Swing"
    case set = "Set Practice"
    case progressive = "Progressive"
    
    var description: String {
        switch self {
        case .continuous: return "Repeats indefinitely"
        case .single: return "One swing then stop"
        case .set: return "Custom number of swings"
        case .progressive: return "Gradually increases tempo"
        }
    }
}

enum SwingPhase: CaseIterable {
    case takeaway
    case backswing
    case pause
    case downswing
    case impact
    case followthrough
    
    var color: Color {
        switch self {
        case .takeaway: return .green.opacity(0.3)
        case .backswing: return .green
        case .pause: return .yellow
        case .downswing: return .orange
        case .impact: return .red
        case .followthrough: return .red.opacity(0.6)
        }
    }
    
    var hapticIntensity: Double {
        switch self {
        case .takeaway: return 0.3
        case .backswing: return 0.0
        case .pause: return 0.5
        case .downswing: return 0.0
        case .impact: return 1.0
        case .followthrough: return 0.2
        }
    }
}