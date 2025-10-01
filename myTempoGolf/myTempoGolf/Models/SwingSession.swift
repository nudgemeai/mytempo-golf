import Foundation

// Simple session model without Core Data for now
struct SwingSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let swingCount: Int
    let duration: TimeInterval
    let tempoRatio: Double
    let pauseDuration: Double
    let practiceMode: String
    let consistencyScore: Double
    
    init(swingCount: Int, duration: TimeInterval, settings: TempoSettings, consistencyScore: Double = 0.0) {
        self.id = UUID()
        self.date = Date()
        self.swingCount = swingCount
        self.duration = duration
        self.tempoRatio = settings.ratio
        self.pauseDuration = settings.pauseDuration
        self.practiceMode = settings.practiceMode.rawValue
        self.consistencyScore = consistencyScore
    }
}

// Simple data manager using UserDefaults for now
class SessionManager: ObservableObject {
    @Published var sessions: [SwingSession] = []
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "SwingSessions"
    
    init() {
        loadSessions()
    }
    
    func addSession(_ session: SwingSession) {
        sessions.insert(session, at: 0) // Most recent first
        saveSessions()
    }
    
    func loadSessions() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let decodedSessions = try? JSONDecoder().decode([SwingSession].self, from: data) {
            sessions = decodedSessions
        }
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }
    
    func clearAllSessions() {
        sessions.removeAll()
        userDefaults.removeObject(forKey: sessionsKey)
    }
    
    var totalSwings: Int {
        sessions.reduce(0) { $0 + $1.swingCount }
    }
    
    var totalSessions: Int {
        sessions.count
    }
    
    var averageSessionDuration: TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0) { $0 + $1.duration } / Double(sessions.count)
    }
}