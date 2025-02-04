import SwiftUI
import SwiftData

struct WeekView: View {
    @Binding var selectedDate: Date // Bind to selectedDate
    
    var body: some View {
        ZStack {
            WeeklyShotTrackerView(selectedDate: $selectedDate)
        }
    }
}

struct WeeklyShotTrackerView: View {
    @Query(sort: \HoopSession.date, order: .reverse) var sessions: [HoopSession]
    @Binding var selectedDate: Date // Bind to selectedDate
    private let calendar = Calendar.current
    private let today: Int
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"] // Fixed order
    private let loggedDays: Set<Int> = [27, 29]
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        today = calendar.component(.day, from: Date()) // Store today's day number
    }
    
    // Computed property to get all days of the current week
    private var daysOfWeek: [Date] {
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    var body: some View {
        VStack(spacing: 2.5) {
            // Weekday labels
            HStack(spacing: 10) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.regular)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Date rectangles
            HStack(spacing: 10) {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    let day = daysOfWeek[index]
                    let startOfDay = calendar.startOfDay(for: day)
                    let dayNumber = calendar.component(.day, from: day)
                    //let isLogged = loggedDays.contains(dayNumber)
                    //let isToday = calendar.isDate(day, inSameDayAs: Date()) // Check if today
                    let isSelected = calendar.isDate(day, inSameDayAs: selectedDate) // Check if selected
                    let isFuture = calendar.startOfDay(for: day) > calendar.startOfDay(for: Date())
                    
                    let hasSession = sessions.contains { calendar.startOfDay(for: $0.date) == startOfDay }

                    
                    VStack(spacing: 5) {
                        Image(systemName: "basketball.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(hasSession ? .orange : Color(red: 0.3, green: 0.3, blue: 0.3))
                            .frame(width: 22.5, height: 22.5)
                            .padding(.top, 2.5)
                            .opacity(isFuture ? 0.33 : 1.0)
                        
                        Text("\(dayNumber)")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.subheadline)
                            .foregroundStyle(isFuture ? .secondary : .primary)
                    }
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    //.background(isSelected ? Color(red: 0.3, green: 0.3, blue: 0.3).opacity(0.33) : Color.clear)
                    .cornerRadius(12)
                    .overlay(
                        isSelected ?
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.75), lineWidth: 1)
                        : nil
                    )
                    .onTapGesture {
                        withAnimation(.snappy) {
                            if !isFuture {
                                selectedDate = day // Update selected date when tapped
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()
    return WeekView(selectedDate: $selectedDate)
}
