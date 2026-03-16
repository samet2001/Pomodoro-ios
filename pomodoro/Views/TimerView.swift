import SwiftUI

struct TimerView: View {
    
    @State private var viewModel = TimerViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            
            // MARK: - Header (Durum ve Sayaç)
            VStack(spacing: 8) {
                Text(viewModel.currentState.rawValue)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            // MARK: - Circular Progress Bar
            ZStack {
                // Arkaplan Çemberi
                Circle()
                    .stroke(lineWidth: 24)
                    .opacity(0.1)
                    .foregroundColor(themeColor(for: viewModel.currentState))
                
                // İlerleme Çemberi
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(viewModel.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round))
                    .foregroundColor(themeColor(for: viewModel.currentState))
                    .rotationEffect(Angle(degrees: 270.0))
                    // .animation(.linear, value: viewModel.progress)
                
                // Merkezdeki Süre Metni
                Text(viewModel.timeString)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            .padding(40)
            
            // MARK: - Controls (Oynat/Duraklat, Yenile, İleri)
            HStack(spacing: 30) {
                // Yeniden Başlat Butonu
                Button(action: {
                    withAnimation {
                        viewModel.resetTimer()
                    }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                        .foregroundColor(.primary)
                }
                
                // Başlat / Duraklat Butonu
                Button(action: {
                    withAnimation {
                        viewModel.toggleTimer()
                    }
                }) {
                    Image(systemName: viewModel.isActive ? "pause.fill" : "play.fill")
                        .font(.system(size: 40))
                        .padding(24)
                        .background(themeColor(for: viewModel.currentState))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(color: themeColor(for: viewModel.currentState).opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                // Atla Butonu
                Button(action: {
                    withAnimation {
                        viewModel.skipState()
                    }
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        // Ekranın arkaplanı odak/mola moduna göre hafifçe renklenebilir. (HIG Minimalizmi)
        .background(themeColor(for: viewModel.currentState).opacity(0.05).ignoresSafeArea())
    }
    
    // MARK: - Helper Methods
    
    /// Her evre için renk paleti.
    private func themeColor(for state: PomodoroState) -> Color {
        switch state {
        case .focus:
            // Odaklanma için sıcak, enerjik (pastel kırmızı/turuncu tonları)
            return Color.orange
        case .shortBreak:
            // Kısa mola için ferahlatıcı (pastel yeşil)
            return Color.teal
        case .longBreak:
            // Uzun mola için dinlendirici (pastel mavi)
            return Color.indigo
        }
    }
}

#Preview {
    TimerView()
}
