//
//  MyTempoGolfApp.swift
//  MyTempoGolf
//
//  Created by Christopher Pritchard on 9/29/25.
//

import SwiftUI
import AVFoundation
import CoreHaptics

@main
struct MyTempoGolfApp: App {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var hapticManager = HapticManager()
    @StateObject private var tempoViewModel = TempoViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    init() {
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .environmentObject(hapticManager)
                .environmentObject(tempoViewModel)
                .environmentObject(settingsViewModel)
                .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
        }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}