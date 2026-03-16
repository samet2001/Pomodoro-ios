import Foundation
import SwiftUI
import Combine

// For audio alerts.
// Sesli uyarılar için.
import AVFoundation

/// Defines the Pomodoro work states.
/// Pomodoro çalışma evrelerini tanımlar.
enum PomodoroState: String {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

/// The ViewModel that handles the main business logic of the timer.
/// Zamanlayıcının ana iş mantığını yürüten ViewModel.
@Observable
class TimerViewModel {
    
    // MARK: - Properties
    
    /// The current state (Focus, Short Break, Long Break).
    /// Mevcut evre (Odaklanma, Kısa Mola, Uzun Mola).
    var currentState: PomodoroState = .focus
    
    /// Holds the remaining time in seconds.
    /// Kalan süreyi saniye cinsinden tutar.
    var timeRemaining: Int = 25 * 60
    
    /// Holds the total time (required for the progress bar).
    /// Toplam süreyi tutar (Progress bar için gerekli).
    var totalTime: Int = 25 * 60
    
    /// Determines whether the timer is currently active.
    /// Zamanlayıcının şu anda aktif olup olmadığını belirler.
    var isActive: Bool = false
    
    /// Indicates the number of completed Pomodoros so far.
    /// Bugüne kadar tamamlanan Pomodoro sayısını belirtir.
    var completedPomodoros: Int = 0
    
    // Adjustable duration defaults (in seconds)
    // Ayarlanabilir süre varsayılanları (Saniye cinsinden)
    var focusDuration: Int = 25 * 60
    var shortBreakDuration: Int = 5 * 60
    var longBreakDuration: Int = 15 * 60
    
    // Timer reference
    // Timer referansı
    private var timer: AnyCancellable?
    
    // MARK: - Init
    
    init() {
        // Request notification permission when the ViewModel is first created
        // ViewModel ilk oluşturulduğunda kullanıcıdan bildirim izni iste
        NotificationManager.shared.requestAuthorization()
    }
    
    // MARK: - Format Helpers
    
    /// Returns the remaining time in `MM:SS` format (e.g., "25:00").
    /// Kalan süreyi `MM:SS` formatında (Örn: "25:00") döndürür.
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Returns the completion ratio for the progress bar (between 0.0 and 1.0).
    /// İlerleme çubuğu için (0.0 ile 1.0 arasında) tamamlanma oranını Döndürür.
    var progress: Double {
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
    
    // MARK: - Timer Controls
    
    /// Starts or pauses the remaining time.
    /// Kalan süreyi başlatır ya da duraklatır.
    func toggleTimer() {
        isActive.toggle()
        
        if isActive {
            startTimer()
            // Schedule a notification for the end time when the timer runs
            // Zamanlayıcı çalıştırıldığında, bitiş süresi için bir bildirim planla
            scheduleNotificationForCurrentState()
        } else {
            stopTimer()
            // Cancel the scheduled notification when the timer is paused
            // Zamanlayıcı duraklatıldığında planlı bildirimi iptal et
            NotificationManager.shared.cancelAllNotifications()
        }
    }
    
    /// Starts the timer, calls the `timerElapsed` function every second.
    /// Timer'ı başlatır, her saniye `timerElapsed` fonksiyonunu çağırır.
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerElapsed()
            }
    }
    
    /// Stops the timer.
    /// Timer'ı durdurur.
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    /// Resets the counter and returns to the starting time based on the current state.
    /// Sayacı sıfırlar ve mevcut evreye göre başlangıç süresine döner.
    func resetTimer() {
        stopTimer()
        NotificationManager.shared.cancelAllNotifications()
        isActive = false
        setDuration(for: currentState)
    }
    
    /// Cancels or skips a state and transitions to the next state.
    /// Bir evreyi iptal edip, veya atlayıp bir sonraki evreye geçmeyi sağlar.
    func skipState() {
        stopTimer()
        NotificationManager.shared.cancelAllNotifications()
        isActive = false
        transitionToNextState()
    }
    
    // MARK: - State Management
    
    /// Called every second, changes the state when the time is up.
    /// Her saniyede çağrılır, süre bittiğinde evreyi değiştirir.
    private func timerElapsed() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            // Actions to perform when the time is up.
            // Süre dolduğunda yapılacaklar.
            stopTimer()
            isActive = false
            playSoundAlert()
            
            if currentState == .focus {
                completedPomodoros += 1
            }
            transitionToNextState()
        }
    }
    
    /// Manages the transition to the next phase (Break or Focus).
    /// Bir sonraki aşamaya (Mola veya Odaklanma) geçişi yönetir.
    private func transitionToNextState() {
        switch currentState {
        case .focus:
            // A long break is given every 4 pomodoros
            // Her 4 pomodoroda bir uzun mola verilir
            if completedPomodoros > 0 && completedPomodoros % 4 == 0 {
                currentState = .longBreak
            } else {
                currentState = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentState = .focus
        }
        setDuration(for: currentState)
    }
    
    /// Sets the durations in seconds based on the selected state.
    /// Seçilen evreye göre saniye cinsinden süreleri ayarlar.
    private func setDuration(for state: PomodoroState) {
        switch state {
        case .focus:
            timeRemaining = focusDuration
            totalTime = focusDuration
        case .shortBreak:
            timeRemaining = shortBreakDuration
            totalTime = shortBreakDuration
        case .longBreak:
            timeRemaining = longBreakDuration
            totalTime = longBreakDuration
        }
    }
    
    // MARK: - Audio & Notifications
    
    /// Schedules a local notification for when the current state finishes.
    /// Mevcut evrenin biteceği zaman için yerel bir bildirim planlar.
    private func scheduleNotificationForCurrentState() {
        let title: String
        let body: String
        
        switch currentState {
        case .focus:
            title = "Odaklanma Süresi Bitti!"
            body = "Harika iş çıkardın. Şimdi kısa bir mola zamanı."
        case .shortBreak:
            title = "Mola Bitti!"
            body = "Tekrar odaklanma zamanı. Hadi başlayalım!"
        case .longBreak:
            title = "Uzun Mola Bitti!"
            body = "Dinlendiysen yeni bir pomodoro döngüsüne hazır mısın?"
        }
        
        NotificationManager.shared.scheduleNotification(title: title, body: body, timeInterval: TimeInterval(timeRemaining))
    }
    
    /// Plays a simple system sound when the time is up.
    /// Süre bitiminde basit bir sistem sesi çalar.
    private func playSoundAlert() {
        // HIG-compliant, gentle notification sound. (System Sound ID: 1005 - Tock)
        // Alternatively, 1304 can be used. An advanced sound system can be moved to the Core/ folder.
        // HIG uyumlu, nazik bir bildirim sesi. (System Sound ID: 1005 - Tock)
        // Alternatif olarak 1304 kullanılabilir. Gelişmiş bir ses sistemi Core/ klasörüne alınabilir.
        AudioServicesPlaySystemSound(1005)
    }
}
