import Foundation
import SwiftData

/// The data model representing the tasks the user will focus on.
/// Kullanıcının odaklanacağı görevleri temsil eden veri modeli.
@Model
final class TaskItem {
    /// The unique identifier of the task.
    /// Görevin benzersiz kimliği.
    var id: UUID
    
    /// The title or description of the task.
    /// Görevin başlığı veya açıklaması.
    var title: String
    
    /// The completion status of the task.
    /// Görevin tamamlanıp tamamlanmadığı durumu.
    var isCompleted: Bool
    
    /// The creation date of the task.
    /// Görevin oluşturulma tarihi.
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
