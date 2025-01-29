//
//  WeekView.swift
//  Hoops
//
//  Created by Landon West on 1/29/25.
//

import SwiftUI

struct WeekView: View {
    var body: some View {
        ZStack {
            WeeklyShotTrackerView()
        }
    }
}


struct WeeklyShotTrackerView: View {
    private let calendar = Calendar.current
    private let today: Int
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"] // Fixed order
    private let loggedDays: Set<Int> = [27, 29]
    
    init() {
        today = calendar.component(.day, from: Date()) // Store today's day number
    }
    
    // Computed property to get all days of the current week
    private var daysOfWeek: [Date] {
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    
    var body: some View {
        VStack(spacing: 7.5) {
            // Weekday labels
            HStack(spacing: 10) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Date rectangles
            HStack(spacing: 10) {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    let day = daysOfWeek[index]
                    let dayNumber = calendar.component(.day, from: day)
                    let isLogged = loggedDays.contains(dayNumber)
                    let isToday = dayNumber == today // Check if this day is today
                    
                    VStack(spacing: 5) {
                        Image(systemName: "basketball.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(isLogged ? .orange : Color(red: 0.3, green: 0.3, blue: 0.3)) // Orange if logged
                            .frame(width: 22.5, height: 22.5)
                            .padding(.top, 2.5)
                        
                        Text("\(dayNumber)")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.headline)
                        
                    }
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .cornerRadius(12)
                    .overlay(
                        isToday ? RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 2) : nil // White border for today
                    )
                }
            }
        }
        .padding()
    }
}

#Preview {
    WeekView()
}
