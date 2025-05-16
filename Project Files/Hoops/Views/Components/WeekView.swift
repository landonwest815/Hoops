//
//  WeekPagerView.swift
//  Hoops
//
//  Created by Landon West on [Date].
//

import SwiftUI
import SwiftData


// MARK: - Helper
func startOfWeek(for date: Date, using startDay: String = UserDefaults.standard.string(forKey: AppSettingsKeys.startOfWeek) ?? "Monday") -> Date {
    var calendar = Calendar.current
    calendar.firstWeekday = (startDay == "Sunday") ? 1 : 2 // 1 = Sunday, 2 = Monday
    return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
}

// MARK: - WeeklyShotTrackerView
struct WeeklyShotTrackerView: View {
    let weekBaseDate: Date
    @Binding var selectedDate: Date
    @Query(sort: \HoopSession.date, order: .reverse) var sessions: [HoopSession]
    
    private let calendar = Calendar.current
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    @AppStorage(AppSettingsKeys.startOfWeek) private var startOfWeekPref: String = "Sunday"
    
    private var rotatedWeekdays: [String] {
        let original = ["S", "M", "T", "W", "T", "F", "S"]
        if startOfWeekPref == "Monday" {
            return Array(original[1...6]) + [original[0]] // Monday to Sunday
        } else {
            return original // Sunday to Saturday
        }
    }

    private var daysOfWeek: [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = (startOfWeekPref == "Sunday") ? 1 : 2
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekBaseDate)) ?? weekBaseDate
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }
    
    var body: some View {
        VStack(spacing: 2.5) {
            HStack(spacing: 10) {
                ForEach(rotatedWeekdays, id: \.self) { daySymbol in
                    Text(daySymbol)
                        .font(.caption)
                        .fontWeight(.regular)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 10) {
                ForEach(daysOfWeek, id: \.self) { day in
                    let startOfDay = calendar.startOfDay(for: day)
                    let dayNumber = calendar.component(.day, from: day)
                    let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                    let isFuture = startOfDay > calendar.startOfDay(for: Date())
                    let hasSession = sessions.contains { calendar.isDate($0.date, inSameDayAs: day) }
                    
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
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
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
struct WeekPagerView: View {
    @Binding var selectedDate: Date
    @State private var weekOffset: Int = 0
    private let calendar = Calendar.current
    private let maxPastWeeks: Int = 50
    
    @AppStorage(AppSettingsKeys.startOfWeek) private var startOfWeekPref: String = "Sunday"
    
    private var currentWeekStart: Date {
        startOfWeek(for: Date(), using: startOfWeekPref)
    }

    private func computeWeek(for offset: Int) -> Date {
        calendar.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart) ?? currentWeekStart
    }

    var body: some View {
        TabView(selection: $weekOffset) {
            ForEach((-maxPastWeeks...0), id: \.self) { offset in
                let weekBaseDate = computeWeek(for: offset)
                WeeklyShotTrackerView(weekBaseDate: weekBaseDate, selectedDate: $selectedDate)
                    .tag(offset)
            }
        }
        .frame(height: 85)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear { updateOffsetForSelectedDate() }
        .onChange(of: selectedDate) { _, _ in updateOffsetForSelectedDate() }
        .onChange(of: weekOffset) { _, newOffset in
            let newWeekBaseDate = computeWeek(for: newOffset)
            if !calendar.isDate(selectedDate, equalTo: newWeekBaseDate, toGranularity: .weekOfYear) {
                withAnimation {
                    selectedDate = newWeekBaseDate
                }
            }
        }
    }

    private func updateOffsetForSelectedDate() {
        let selectedWeekStart = startOfWeek(for: selectedDate, using: startOfWeekPref)
        let components = calendar.dateComponents([.weekOfYear], from: currentWeekStart, to: selectedWeekStart)
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
