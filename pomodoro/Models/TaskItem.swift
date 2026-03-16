import Foundation
import SwiftData

/// Kullanıcının odaklanacağı görevleri temsil eden veri modeli.
@Model
final class TaskItem {
    /// Görevin benzersiz kimliği.
    var id: UUID
    
    /// Görevin başlığı veya açıklaması.
    var title: String
    
    /// Görevin tamamlanıp tamamlanmadığı durumu.
    var isCompleted: Bool
    
    /// Görevin oluşturulma tarihi.
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
