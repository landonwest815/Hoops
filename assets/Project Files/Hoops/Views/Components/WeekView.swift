import SwiftUI
import SwiftData

// MARK: - Helper Functions

/// Computes the start of the week for a given date based on the provided calendar.
/// - Parameters:
///   - date: The date from which to calculate the start of the week.
///   - calendar: The calendar to use for calculations (default is `.current`).
/// - Returns: The date representing the start of the week. If the calculation fails, returns the original date.
func startOfWeek(for date: Date, calendar: Calendar = .current) -> Date {
    // Uses yearForWeekOfYear and weekOfYear to calculate the first day of that week.
    calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
}

// MARK: - WeeklyShotTrackerView

/// Displays a single week’s dates computed from a fixed base date.
/// Highlights the globally selected date, and adjusts the basketball icon color
/// based on whether a session exists on that day.
struct WeeklyShotTrackerView: View {
    // MARK: Properties
    
    /// Base date for the week (used to compute this week’s dates).
    let weekBaseDate: Date
    /// Binding to the global selected date.
    @Binding var selectedDate: Date
    
    /// The current calendar.
    private let calendar = Calendar.current
    /// Abbreviated weekday symbols to display above the dates.
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    /// Query to load session data (ordered with the most recent first).
    @Query(sort: \HoopSession.date, order: .reverse) var sessions: [HoopSession]
    
    /// Computes an array of dates for the current week using the week base date.
    private var daysOfWeek: [Date] {
        let weekStart = startOfWeek(for: weekBaseDate, calendar: calendar)
        // Returns 7 consecutive dates starting with weekStart.
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 2.5) {
            // Weekday labels (e.g., S, M, T, etc.).
            HStack(spacing: 10) {
                ForEach(weekdays.indices, id: \.self) { index in
                    Text(weekdays[index])
                        .font(.caption)
                        .fontWeight(.regular)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Date rectangles for each day of the week.
            HStack(spacing: 10) {
                ForEach(daysOfWeek, id: \.self) { day in
                    // Compute key date properties.
                    let startOfDay = calendar.startOfDay(for: day)
                    let dayNumber = calendar.component(.day, from: day)
                    let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                    // Mark days that lie in the future.
                    let isFuture = startOfDay > calendar.startOfDay(for: Date())
                    
                    // Determine if there is at least one session on this day.
                    let hasSession = sessions.contains { session in
                        calendar.isDate(session.date, inSameDayAs: day)
                    }
                    
                    VStack(spacing: 5) {
                        // Basketball icon: colored orange if a session exists, otherwise a darker gray.
                        Image(systemName: "basketball.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(hasSession ? .orange : Color(red: 0.3, green: 0.3, blue: 0.3))
                            .frame(width: 22.5, height: 22.5)
                            .padding(.top, 2.5)
                            .opacity(isFuture ? 0.33 : 1.0)
                        
                        // Display the day number.
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
                    // Overlay a border if this day is the currently selected day.
                    .overlay(
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
                    // Tapping a non-future day updates the global selected date.
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
/// but restricts navigation to past weeks (including the current week) only.
struct WeekPagerView: View {
    // MARK: Properties
    
    /// Binding to the global selected date.
    @Binding var selectedDate: Date
    /// The current pager offset in weeks.
    @State private var weekOffset: Int = 0
    
    private let calendar = Calendar.current
    /// The maximum number of weeks in the past that can be navigated.
    private let maxPastWeeks: Int = 50
    /// The start date of the current week (based on today's date).
    private let currentWeekStart: Date = startOfWeek(for: Date(), calendar: Calendar.current)
    
    /// Computes the base date for a week given an offset relative to the current week.
    /// - Parameter offset: A negative integer representing past weeks (0 is current week).
    /// - Returns: The base date for that week.
    private func computeWeek(for offset: Int) -> Date {
        calendar.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart) ?? currentWeekStart
    }
    
    // MARK: Body
    var body: some View {
        TabView(selection: $weekOffset) {
            // Create pages for each week from maxPastWeeks ago up to the current week (0).
            ForEach((-maxPastWeeks...0), id: \.self) { offset in
                let weekBaseDate = computeWeek(for: offset)
                WeeklyShotTrackerView(weekBaseDate: weekBaseDate, selectedDate: $selectedDate)
                    .tag(offset)
            }
        }
        .frame(height: 85)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        // Update the pager offset when the view appears or when selectedDate changes.
        .onAppear { updateOffsetForSelectedDate() }
        .onChange(of: selectedDate) { _, _ in updateOffsetForSelectedDate() }
        // When the user swipes the pager, update the global selectedDate accordingly.
        .onChange(of: weekOffset) { _, newOffset in
            let newWeekBaseDate = computeWeek(for: newOffset)
            if !calendar.isDate(selectedDate, equalTo: newWeekBaseDate, toGranularity: .weekOfYear) {
                // Default the global selectedDate to the new week's start.
                withAnimation {
                    selectedDate = newWeekBaseDate
                }
            }
        }
    }
    
    /// Updates the pager offset (weekOffset) to match the global selectedDate.
    private func updateOffsetForSelectedDate() {
        let selectedWeekStart = startOfWeek(for: selectedDate, calendar: calendar)
        let components = calendar.dateComponents([.weekOfYear], from: currentWeekStart, to: selectedWeekStart)
        // The computed offset will be 0 or negative (future weeks are disallowed).
        let newOffset = components.weekOfYear ?? 0
        withAnimation {
            weekOffset = min(newOffset, 0)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedDate = Date()
    return WeekPagerView(selectedDate: $selectedDate)
}
