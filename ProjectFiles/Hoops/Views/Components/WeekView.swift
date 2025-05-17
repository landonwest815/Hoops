//
//  WeekPagerView.swift
//  Hoops
//
//  Created by Landon West on [Date].
//

import SwiftUI
import SwiftData

func startOfWeek(for date: Date, using startDay: String = UserDefaults.standard.string(forKey: AppSettingsKeys.startOfWeek) ?? "Monday") -> Date {
    var calendar = Calendar.current
    calendar.firstWeekday = startDay == "Sunday" ? 1 : 2
    return calendar.date(
        from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    ) ?? date
}

struct WeeklyShotTrackerView: View {
    let weekBaseDate: Date
    @Binding var selectedDate: Date
    @Query(sort: \HoopSession.date, order: .reverse) private var sessions: [HoopSession]
    @AppStorage(AppSettingsKeys.startOfWeek) private var startOfWeekPref = "Sunday"

    private let calendar = Calendar.current

    private var rotatedWeekdays: [String] {
        let days = ["S","M","T","W","T","F","S"]
        return startOfWeekPref == "Monday"
            ? Array(days[1...6]) + [days[0]]
            : days
    }

    private var daysOfWeek: [Date] {
        var cal = calendar
        cal.firstWeekday = startOfWeekPref == "Sunday" ? 1 : 2
        let start = startOfWeek(for: weekBaseDate, using: startOfWeekPref)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        VStack(spacing: 2.5) {
            HStack(spacing: 10) {
                ForEach(rotatedWeekdays, id: \.self) { d in
                    Text(d)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            HStack(spacing: 10) {
                ForEach(daysOfWeek, id: \.self) { day in
                    let startOfDay = calendar.startOfDay(for: day)
                    let dayNum = calendar.component(.day, from: day)
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
                            .opacity(isFuture ? 0.33 : 1)

                        Text("\(dayNum)")
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
                        isSelected
                            ? RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.66), lineWidth: 2)
                            : nil
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                            .foregroundColor(.gray.opacity(0.33))
                    )
                    .opacity(isFuture ? 0.5 : 1)
                    .onTapGesture {
                        if !isFuture {
                            withAnimation(.snappy) {
                                selectedDate = day
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

struct WeekPagerView: View {
    @Binding var selectedDate: Date
    @State private var weekOffset = 0
    @AppStorage(AppSettingsKeys.startOfWeek) private var startOfWeekPref = "Sunday"

    private let calendar = Calendar.current
    private let maxPastWeeks = 50

    private var currentWeekStart: Date {
        startOfWeek(for: Date(), using: startOfWeekPref)
    }

    private func computeWeek(for offset: Int) -> Date {
        calendar.date(byAdding: .weekOfYear, value: offset, to: currentWeekStart)
        ?? currentWeekStart
    }

    var body: some View {
        TabView(selection: $weekOffset) {
            ForEach((-maxPastWeeks...0), id: \.self) { off in
                WeeklyShotTrackerView(
                    weekBaseDate: computeWeek(for: off),
                    selectedDate: $selectedDate
                )
                .tag(off)
            }
        }
        .frame(height: 85)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear { updateOffset() }
        .onChange(of: selectedDate) { _, _ in updateOffset() }
        .onChange(of: weekOffset) { _, newOff in
            let newWeek = computeWeek(for: newOff)
            if !calendar.isDate(selectedDate, equalTo: newWeek, toGranularity: .weekOfYear) {
                withAnimation { selectedDate = newWeek }
            }
        }
    }

    private func updateOffset() {
        let selWeek = startOfWeek(for: selectedDate, using: startOfWeekPref)
        let comp = calendar.dateComponents([.weekOfYear], from: currentWeekStart, to: selWeek)
        withAnimation {
            weekOffset = min(comp.weekOfYear ?? 0, 0)
        }
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()
    WeekPagerView(selectedDate: $selectedDate)
}
