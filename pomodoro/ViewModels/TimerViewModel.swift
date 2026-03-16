import Foundation
import SwiftUI
import Combine

// Sesli uyarılar için.
import AVFoundation

/// Pomodoro çalışma evrelerini tanımlar.
enum PomodoroState: String {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

/// Zamanlayıcının ana iş mantığını yürüten ViewModel.
@Observable
class TimerViewModel {
    
    // MARK: - Properties
    
    /// Mevcut evre (Odaklanma, Kısa Mola, Uzun Mola).
    var currentState: PomodoroState = .focus
    
    /// Kalan süreyi saniye cinsinden tutar.
    var timeRemaining: Int = 25 * 60
    
    /// Toplam süreyi tutar (Progress bar için gerekli).
    var totalTime: Int = 25 * 60
    
    /// Zamanlayıcının şu anda aktif olup olmadığını belirler.
    var isActive: Bool = false
    
    /// Bugüne kadar tamamlanan Pomodoro sayısını belirtir.
    var completedPomodoros: Int = 0
    
    // Ayarlanabilir süre varsayılanları (Saniye cinsinden)
    var focusDuration: Int = 25 * 60
    var shortBreakDuration: Int = 5 * 60
    var longBreakDuration: Int = 15 * 60
    
    // Timer referansı
    private var timer: AnyCancellable?
    
    // MARK: - Init
    
    init() {
        // ViewModel ilk oluşturulduğunda kullanıcıdan bildirim izni iste
        NotificationManager.shared.requestAuthorization()
    }
    
    // MARK: - Format Helpers
    
    /// Kalan süreyi `MM:SS` formatında (Örn: "25:00") döndürür.
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// İlerleme çubuğu için (0.0 ile 1.0 arasında) tamamlanma oranını Döndürür.
    var progress: Double {
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
    
    // MARK: - Timer Controls
    
    /// Kalan süreyi başlatır ya da duraklatır.
    func toggleTimer() {
        isActive.toggle()
        
        if isActive {
            startTimer()
            // Zamanlayıcı çalıştırıldığında, bitiş süresi için bir bildirim planla
            scheduleNotificationForCurrentState()
        } else {
            stopTimer()
            // Zamanlayıcı duraklatıldığında planlı bildirimi iptal et
            NotificationManager.shared.cancelAllNotifications()
        }
    }
    
    /// Timer'ı başlatır, her saniye `timerElapsed` fonksiyonunu çağırır.
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerElapsed()
            }
    }
    
    /// Timer'ı durdurur.
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    /// Sayacı sıfırlar ve mevcut evreye göre başlangıç süresine döner.
    func resetTimer() {
        stopTimer()
        NotificationManager.shared.cancelAllNotifications()
        isActive = false
        setDuration(for: currentState)
    }
    
    /// Bir evreyi iptal edip, veya atlayıp bir sonraki evreye geçmeyi sağlar.
    func skipState() {
        stopTimer()
        NotificationManager.shared.cancelAllNotifications()
        isActive = false
        transitionToNextState()
    }
    
    // MARK: - State Management
    
    /// Her saniyede çağrılır, süre bittiğinde evreyi değiştirir.
    private func timerElapsed() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
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
    
    /// Bir sonraki aşamaya (Mola veya Odaklanma) geçişi yönetir.
    private func transitionToNextState() {
        switch currentState {
        case .focus:
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
    
    /// Süre bitiminde basit bir sistem sesi çalar.
    private func playSoundAlert() {
        // HIG uyumlu, nazik bir bildirim sesi. (System Sound ID: 1005 - Tock)
        // Alternatif olarak 1304 kullanılabilir. Gelişmiş bir ses sistemi Core/ klasörüne alınabilir.
        AudioServicesPlaySystemSound(1005)
    }
}
