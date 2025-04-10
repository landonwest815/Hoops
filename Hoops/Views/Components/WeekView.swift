import SwiftUI
import SwiftData

// Helper: compute the start of a week for a given date.
func startOfWeek(for date: Date, calendar: Calendar = .current) -> Date {
    calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
}

/// Displays a single week’s dates computed from a fixed base date, highlights the global selected date,
/// and uses the presence of a session to adjust the basketball icon.
struct WeeklyShotTrackerView: View {
    /// Base date for the week (used to compute this week’s dates).
    let weekBaseDate: Date
    /// Global selected date binding.
    @Binding var selectedDate: Date

    private let calendar = Calendar.current
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    // Reintroduce the query to load session data.
    @Query(sort: \HoopSession.date, order: .reverse) var sessions: [HoopSession]
    
    /// Compute days for this week based on weekBaseDate.
    private var daysOfWeek: [Date] {
        let weekStart = startOfWeek(for: weekBaseDate, calendar: calendar)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    var body: some View {
        VStack(spacing: 2.5) {
            // Weekday labels.
            HStack(spacing: 10) {
                ForEach(weekdays.indices, id: \.self) { index in
                    Text(weekdays[index])
                        .font(.caption)
                        .fontWeight(.regular)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Date rectangles.
            HStack(spacing: 10) {
                ForEach(daysOfWeek, id: \.self) { day in
                    let startOfDay = calendar.startOfDay(for: day)
                    let dayNumber = calendar.component(.day, from: day)
                    let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                    let isFuture = startOfDay > calendar.startOfDay(for: Date())
                    
                    // Check if a session exists for this day.
                    let hasSession = sessions.contains { session in
                        calendar.isDate(session.date, inSameDayAs: day)
                    }
                    
                    VStack(spacing: 5) {
                        Image(systemName: "basketball.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            // For example, fill in with orange if there’s a session, or gray if not.
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
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .overlay(
                        // Highlight the selected day.
                        isSelected ?
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.66), lineWidth: 2)
                        : nil
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                            .foregroundColor(.gray.opacity(0.33))
                    )
                    .onTapGesture {
                        withAnimation(.snappy) {
                            if !isFuture {
                                selectedDate = day
                            }
                        }
                    }
                    .opacity(isFuture ? 0.5 : 1.0)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}


// MARK: - WeekPagerView

/// Displays week pages (one week per page) that can be swiped through,
/// but disallows scrolling into future weeks (i.e. only past weeks plus the current week).
struct WeekPagerView: View {
    @Binding var selectedDate: Date
    @State private var weekOffset: Int = 0
    
    private let calendar = Calendar.current
    /// The maximum number of weeks in the past that can be scrolled.
    private let maxPastWeeks: Int = 50
    /// The current week’s start is computed from today.
    private let currentWeekStart: Date = startOfWeek(for: Date(), calendar: Calendar.current)
    
    /// Computes the week base date for a given offset relative to the current week.
    private func computeWeek(for offset: Int) -> Date {
        calendar.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart) ?? currentWeekStart
    }
    
    var body: some View {
        TabView(selection: $weekOffset) {
            // Offsets from maxPastWeeks ago (negative numbers) through 0 (current week)
            ForEach((-maxPastWeeks...0), id: \.self) { offset in
                let weekBaseDate = computeWeek(for: offset)
                WeeklyShotTrackerView(weekBaseDate: weekBaseDate, selectedDate: $selectedDate)
                    .tag(offset)
            }
        }
        .frame(height: 85)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        // When the view appears or the global selectedDate changes,
        // update the page (weekOffset) accordingly.
        .onAppear { updateOffsetForSelectedDate() }
        .onChange(of: selectedDate) { _, _ in updateOffsetForSelectedDate() }
        // When the user swipes the pager, update the global selectedDate if needed.
        .onChange(of: weekOffset) { _, newOffset in
            let newWeekBaseDate = computeWeek(for: newOffset)
            if !calendar.isDate(selectedDate, equalTo: newWeekBaseDate, toGranularity: .weekOfYear) {
                // Option 1: Simply default the global selectedDate to the new week's start.
                withAnimation {
                    selectedDate = newWeekBaseDate
                }
                // Option 2: Preserve the same weekday (if desired) by trying something like:
                // let weekday = calendar.component(.weekday, from: selectedDate)
                // if let newSelectedDate = calendar.date(bySetting: .weekday, value: weekday, of: newWeekBaseDate) {
                //     selectedDate = newSelectedDate
                // } else {
                //     selectedDate = newWeekBaseDate
                // }
            }
        }
    }
    
    /// Updates the pager’s weekOffset based on the global selectedDate.
    private func updateOffsetForSelectedDate() {
        let selectedWeekStart = startOfWeek(for: selectedDate, calendar: calendar)
        let components = calendar.dateComponents([.weekOfYear], from: currentWeekStart, to: selectedWeekStart)
        // Compute the offset (it will be 0 or negative, because future weeks are disallowed).
        let newOffset = components.weekOfYear ?? 0
        withAnimation {
            weekOffset = min(newOffset, 0)
        }
    }
}



#Preview {
    @Previewable @State var selectedDate = Date()
    return WeekPagerView(selectedDate: $selectedDate)
}
