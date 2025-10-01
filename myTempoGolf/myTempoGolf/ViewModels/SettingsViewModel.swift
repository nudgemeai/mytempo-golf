import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("isAutoLockDisabled") var isAutoLockDisabled: Bool = true
    @AppStorage("backgroundAudioEnabled") var backgroundAudioEnabled: Bool = true
    @AppStorage("highContrastMode") var highContrastMode: Bool = false
    @AppStorage("showBPM") var showBPM: Bool = true
    @AppStorage("vibrateOnSilent") var vibrateOnSilent: Bool = true
    
    @Published var sessionManager = SessionManager()
    
    init() {
        setupNotifications()
        setupSessionObserver()
    }
    
    private func setupNotifications() {
        UIApplication.shared.isIdleTimerDisabled = isAutoLockDisabled
    }
    
    private func setupSessionObserver() {
        NotificationCenter.default.addObserver(
            forName: .sessionCompleted,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let session = notification.object as? SwingSession {
                self?.sessionManager.addSession(session)
            }
        }
    }
    
    // Computed properties for easy access to stats
    var totalSwings: Int {
        sessionManager.totalSwings
    }
    
    var totalSessions: Int {
        sessionManager.totalSessions
    }
    
    var averageSessionDuration: TimeInterval {
        sessionManager.averageSessionDuration
    }
    
    var currentStreak: Int {
        calculateCurrentStreak()
    }
    
    var longestStreak: Int {
        calculateLongestStreak()
    }
    
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        let sessions = sessionManager.sessions.sorted { $0.date > $1.date }
        
        guard let mostRecentSession = sessions.first else { return 0 }
        
        let today = calendar.startOfDay(for: Date())
        let sessionDate = calendar.startOfDay(for: mostRecentSession.date)
        
        // If most recent session is not today or yesterday, streak is 0
        let daysDifference = calendar.dateComponents([.day], from: sessionDate, to: today).day ?? 0
        if daysDifference > 1 { return 0 }
        
        var streak = 0
        var currentDate = today
        
        for session in sessions {
            let sessionDay = calendar.startOfDay(for: session.date)
            
            if calendar.isDate(sessionDay, inSameDayAs: currentDate) {
                if streak == 0 || calendar.isDate(sessionDay, inSameDayAs: currentDate) {
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                }
            } else {
                let daysBetween = calendar.dateComponents([.day], from: sessionDay, to: currentDate).day ?? 0
                if daysBetween == 1 {
                    streak += 1
                    currentDate = sessionDay
                } else {
                    break
                }
            }
        }
        
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        let calendar = Calendar.current
        let sessions = sessionManager.sessions.sorted { $0.date < $1.date }
        
        guard !sessions.isEmpty else { return 0 }
        
        var longestStreak = 1
        var currentStreak = 1
        var lastDate = calendar.startOfDay(for: sessions[0].date)
        
        for i in 1..<sessions.count {
            let sessionDate = calendar.startOfDay(for: sessions[i].date)
            let daysDifference = calendar.dateComponents([.day], from: lastDate, to: sessionDate).day ?? 0
            
            if daysDifference == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if daysDifference > 1 {
                currentStreak = 1
            }
            
            lastDate = sessionDate
        }
        
        return longestStreak
    }
    
    func refreshStatistics() {
        sessionManager.loadSessions()
        objectWillChange.send()
    }
    
    func resetAllData() {
        sessionManager.clearAllSessions()
    }
    
    func exportData() -> String {
        var csvContent = "Date,Swings,Duration,Tempo Ratio,Pause Duration,Practice Mode\n"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        for session in sessionManager.sessions {
            let dateString = formatter.string(from: session.date)
            let durationString = String(format: "%.1f", session.duration)
            csvContent += "\(dateString),\(session.swingCount),\(durationString),\(session.tempoRatio),\(session.pauseDuration),\(session.practiceMode)\n"
        }
        
        return csvContent
    }
}