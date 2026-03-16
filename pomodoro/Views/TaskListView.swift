import SwiftUI
import SwiftData

struct TaskListView: View {
    // MARK: - Environment & Data
    
    @Environment(\.modelContext) private var modelContext
    
    // Görevleri oluşturulma tarihine göre azalan şekilde (en yeni en üstte) sıralıyoruz.
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    
    // MARK: - State
    
    @State private var newTaskTitle: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Arkaplan rengi (HIG'e uygun, dikkat dağıtmayan çok açık gri/siyah)
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Görev Ekleme Alanı
                    addTaskSection
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    // Görev Listesi
                    List {
                        ForEach(tasks) { task in
                            TaskRowView(task: task) {
                                toggleCompletion(for: task)
                            }
                            // Liste satırında sağa kaydırarak silme işlemi
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteTask(task)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Görevler")
            .toolbar {
                // Klavyeyi kapatmak için "Bitti" butonu
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Bitti") {
                            isTextFieldFocused = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Views
    
    /// Yeni görev ekleme komponenti
    private var addTaskSection: some View {
        HStack {
            TextField("Yeni bir görev ekle...", text: $newTaskTitle)
                .textFieldStyle(.plain)
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .focused($isTextFieldFocused)
                .submitLabel(.done)
                .onSubmit {
                    addTask()
                }
            
            Button(action: {
                addTask()
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.5) : Color.orange)
            }
            .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    
    // MARK: - Actions
    
    /// Yeni bir görev oluşturup SwiftData context'ine ekler.
    private func addTask() {
        let trimmedTitle = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        // HIG Animasyonu: Eklerken akıcı bir geçiş.
        withAnimation {
            let newTask = TaskItem(title: trimmedTitle)
            modelContext.insert(newTask)
            newTaskTitle = ""
        }
    }
    
    /// Görevin tamamlanma durumunu değiştirir.
    private func toggleCompletion(for task: TaskItem) {
        withAnimation {
            task.isCompleted.toggle()
        }
    }
    
    /// Görevi kalıcı olarak siler.
    private func deleteTask(_ task: TaskItem) {
        withAnimation {
            modelContext.delete(task)
        }
    }
}

/// Her bir görev için liste satırı görünümü.
struct TaskRowView: View {
    let task: TaskItem
    var onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain) // Butonun tüm satırı kaplamasını engeller
            
            Text(task.title)
                .font(.body)
                .strikethrough(task.isCompleted, color: .gray)
                .foregroundColor(task.isCompleted ? .gray : .primary)
                .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TaskListView()
        // Preview ortamında geçici bellek içi veri tabanı (inMemory) kullanıyoruz.
        .modelContainer(for: TaskItem.self, inMemory: true)
}
