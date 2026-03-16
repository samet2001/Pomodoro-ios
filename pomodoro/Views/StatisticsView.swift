import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    // MARK: - Environment & Data
    
    @Environment(\.modelContext) private var modelContext
    
    // We fetch the data sorted by date
    // Verileri tarihe göre sıralayarak çekiyoruz
    @Query(sort: \DailyPomodoro.date) private var dailyStats: [DailyPomodoro]
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    
                    // Summary Card
                    // Özet Kartı
                    summaryCard
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // Chart Area
                    // Grafik Alanı
                    if dailyStats.isEmpty {
                        emptyStateView
                    } else {
                        chartCard
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("İstatistikler")
        }
    }
    
    // MARK: - Views
    
    /// Summary card showing the total number of completed pomodoros.
    /// Toplam tamamlanan pomodoro sayısını gösteren özet kartı.
    private var summaryCard: some View {
        let totalCompleted = dailyStats.reduce(0) { $0 + $1.completedCount }
        let totalFocusMinutes = totalCompleted * 25 // Calculation based on default 25 mins. // Varsayılan 25 dk. üzerinden hesaplama.
        
        return HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Toplam Odaklanma")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(totalCompleted)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Oturum")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Text("Yaklaşık \(totalFocusMinutes / 60) saat \(totalFocusMinutes % 60) dakika odaklandın.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    /// Bar Chart drawn with SwiftUI Charts.
    /// SwiftUI Charts ile Çizilen Çubuk Grafik (Bar Chart).
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Son 7 Gün")
                .font(.headline)
            
            Chart {
                ForEach(dailyStats) { stat in
                    BarMark(
                        x: .value("Tarih", stat.date, unit: .day),
                        y: .value("Oturum", stat.completedCount)
                    )
                    .foregroundStyle(Color.orange.gradient) // Our pastel orange // Pastel turuncumuz
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 250)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    /// The empty screen state to show if there is no data yet.
    /// Eğer henüz hiç veri yoksa gösterilecek boş ekran durumu.
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Henüz veri yok.")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("İlk pomodoronu tamamladığında istatistiklerin burada görünecek.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: DailyPomodoro.self, inMemory: true)
}
