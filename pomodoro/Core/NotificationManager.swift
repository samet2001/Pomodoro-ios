import Foundation
import UserNotifications

/// Uygulama içi yerel bildirimleri (Local Notifications) yöneten yardımcı sınıf.
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Kullanıcıdan bildirim göndermek için izin ister.
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Bildirim izni alınırken hata oluştu: \(error.localizedDescription)")
            } else {
                print("Bildirim izni onaylandı mı? : \(granted)")
            }
        }
    }
    
    /// Belirtilen süre sonunda bir bildirim planlar.
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        // HIG Uyumlu varsayılan bildirim sesi
        content.sound = .default
        
        // Tetikleyici: Belirtilen saniye sonra çalışır.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim planlanırken hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    /// Önceden planlanmış ancak henüz gösterilmemiş tüm bildirimleri iptal eder.
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
