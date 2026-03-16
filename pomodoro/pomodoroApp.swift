//
//  pomodoroApp.swift
//  pomodoro
//
//  Created by SAMET FIRINCI on 13.03.2026.
//

import SwiftUI
import SwiftData

@main
struct pomodoroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Tüm uygulama genelinde veri tabanına (ModelContext) erişim sağlar.
        .modelContainer(for: [TaskItem.self, DailyPomodoro.self])
    }
}
