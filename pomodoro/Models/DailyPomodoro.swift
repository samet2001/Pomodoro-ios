import Foundation
import SwiftData

/// Belirli bir günde tamamlanan Pomodoro sayılarını tutan veri modeli.
@Model
final class DailyPomodoro {
    /// O günün tarihi (saat/dakika önemsizleştirilerek kullanılmalı).
    var date: Date
    
    /// O gün içinde tamamlanan Odaklanma oturumu sayısı.
    var completedCount: Int
    
    init(date: Date, completedCount: Int = 0) {
        self.date = date
        self.completedCount = completedCount
    }
}
