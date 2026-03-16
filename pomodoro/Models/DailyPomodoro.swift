import Foundation
import SwiftData

/// The data model that keeps track of the number of completed Pomodoros on a specific day.
/// Belirli bir günde tamamlanan Pomodoro sayılarını tutan veri modeli.
@Model
final class DailyPomodoro {
    /// The date for that day (should be used mostly ignoring hour/minute).
    /// O günün tarihi (saat/dakika önemsizleştirilerek kullanılmalı).
    var date: Date
    
    /// The number of Focus sessions completed within that day.
    /// O gün içinde tamamlanan Odaklanma oturumu sayısı.
    var completedCount: Int
    
    init(date: Date, completedCount: Int = 0) {
        self.date = date
        self.completedCount = completedCount
    }
}
