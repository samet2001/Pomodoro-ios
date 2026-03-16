//
//  ContentView.swift
//  pomodoro
//
//  Created by SAMET FIRINCI on 13.03.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Label("Odaklan", systemImage: "timer")
                }
            
            TaskListView()
                .tabItem {
                    Label("Görevler", systemImage: "checklist")
                }
            
            StatisticsView()
                .tabItem {
                    Label("İstatistikler", systemImage: "chart.bar")
                }
        }
        // Minimalist görünüm için accent rengini turuncu (Odak rengimiz) yapıyoruz.
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
