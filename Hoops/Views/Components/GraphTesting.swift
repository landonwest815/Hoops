//
//  GraphTesting.swift
//  Hoops
//
//  Created by Landon West on 3/7/24.
//

import SwiftUI
import Charts
import SwiftData

enum TimeRange: String, CaseIterable {
    case sevenDays = "7 Days"
    case month = "Month"
    case allTime = "All Time"
}

struct GraphTesting: View {
    @Environment(\.modelContext) var context
    @Query(sort: \HoopSession.date) var sessions: [HoopSession]
    
    @Binding var shotType: ShotType
    @Binding var selectedMetric: GraphType
    @Binding var selectedDate: Date
    
    @State private var currentActiveSession: HoopSession?
    @State private var computedData: [(date: Date, value: Double)] = []
    
    var lineColor: Color {
        switch shotType {
        case .freeThrows, .midrange: return .blue
        case .layups:               return .red
        case .threePointers:        return .green
        case .deep:                 return .purple
        case .allShots:             return .orange
        }
    }
    
    /// Returns all sessions for the selected shot type (or all sessions if “All Shots” is selected)
    var filteredSessions: [HoopSession] {
        if shotType == .allShots {
            return sessions
        } else {
            return sessions.filter { $0.shotType == shotType }
        }
    }
    
    /// Enum representing the trend direction.
    private enum Trend {
        case up, same, down
    }

    /// Computes the overall trend by comparing the latest data value with the all-time average.
    /// The last value must differ from the average by at least 5% (i.e. significantly) to register
    /// as 'up' or 'down'. Otherwise, the trend is considered stable.
    private var trend: Trend {
        // Ensure there is at least one data point.
        guard !computedData.isEmpty, let lastValue = computedData.last?.value else {
            return .same
        }
        
        // Calculate the overall average.
        let total = computedData.reduce(0.0) { $0 + $1.value }
        let average = total / Double(computedData.count)
        
        // Define a 15% threshold (15% difference).
        let threshold = 0.15
        
        // For a non-zero average, compare the relative difference.
        if average != 0 {
            if lastValue > average * (1 + threshold) {
                return .up
            } else if lastValue < average * (1 - threshold) {
                return .down
            } else {
                return .same
            }
        } else {
            // When average is zero, use the sign of the last value.
            return lastValue > 0 ? .up : (lastValue < 0 ? .down : .same)
        }
    }

    /// Returns the appropriate SF Symbol based on the trend.
    private var trendIcon: String {
        switch trend {
        case .up:
            return "arrow.up.right"   // upward trend
        case .down:
            return "arrow.down.right" // downward trend
        case .same:
            return "arrow.right"      // stable
        }
    }

    /// Returns the color corresponding to the trend.
    private var trendColor: Color {
        switch trend {
        case .up:
            return .green
        case .down:
            return .red
        case .same:
            return .gray
        }
    }

    
    var body: some View {
        let yValues = computedData.map { $0.value }
        let averageValue = yValues.isEmpty ? 0 : yValues.reduce(0, +) / Double(yValues.count)
        let ruleMarkPosition = averageValue
        
        // Compute the Y axis scale (with some extra padding)
        let minYValue = yValues.min() ?? 0
        let maxYValue = yValues.max() ?? 1
        let range = maxYValue - minYValue
        let padding = averageValue//max(range * 1, 2)
        let domainEnd = maxYValue + padding
        
        // Calculate best and worst from your computed values.
        // The best value is simply the maximum.
        let bestValue = yValues.max() ?? 0
        // For worstValue, we ignore zeros by filtering out any values equal to 0.
        let worstValue = yValues.filter { $0 > 0 }.min() ?? 0
        
        VStack(spacing: 15) {
            // Header
            HStack(spacing: 15) {
                Text(selectedMetric.rawValue)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)
                
                HStack {
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 18)
                    
                    // Add an id and a fade transition so that when selectedDate changes,
                    // SwiftUI treats the text as new and animates its appearance.
                    Text(selectedDate, format: Date.FormatStyle().month(.wide).day().year())
                        .id(selectedDate)
                        .transition(.opacity)
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .contentTransition(.numericText())
                .frame(height: 20)
                .padding(.leading, 5)
            }
            .padding(.horizontal)
            .padding(.top, 5)
            .animation(.easeInOut(duration: 0.5), value: selectedDate)
            
            // Chart view
            ZStack {
                if filteredSessions.isEmpty {
                    Text("No data available.\nGo shoot some hoops!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray.opacity(0.5))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }
                
                if let firstDate = computedData.first?.date,
                   let lastDate = computedData.last?.date {
                    
                    // Add extra padding to the right side of the chart
                    let totalDuration = lastDate.timeIntervalSince(firstDate)
                    let extraPadding = totalDuration * 0.1
                    
                    Chart(computedData, id: \.date) {
                        // Line
                        LineMark(
                            x: .value("Date", $0.date),
                            y: .value("Metric", $0.value)
                        )
                        .foregroundStyle(lineColor)
                        .lineStyle(.init(lineWidth: 3))
                        .interpolationMethod(.catmullRom)
                        
                        // Filled Area under the line
                        AreaMark(
                            x: .value("Date", $0.date),
                            y: .value("Metric", $0.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [lineColor.opacity(0.5), lineColor.opacity(0.125)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .lineStyle(.init(lineWidth: 3))
                        .interpolationMethod(.catmullRom)
                        
                        // Rule mark for average
                        RuleMark(y: .value("Average", ruleMarkPosition))
                            .lineStyle(.init(lineWidth: 1, dash: [2.5]))
                            .foregroundStyle(.gray.opacity(0.25))
                        
                        // Always display the latest point dot.
                        if let latestPoint = computedData.max(by: { $0.date < $1.date }) {
                            PointMark(
                                x: .value("Date", latestPoint.date),
                                y: .value("Metric", latestPoint.value)
                            )
                            .foregroundStyle(lineColor)
                            .symbol(.circle)
                            
                            // If the selected date matches the latest point, add an annotation.
                            if let selectedPoint = computedData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }),
                               Calendar.current.isDate(selectedPoint.date, inSameDayAs: latestPoint.date) {
                                PointMark(
                                    x: .value("Date", selectedPoint.date),
                                    y: .value("Metric", selectedPoint.value)
                                )
                                .foregroundStyle(lineColor)
                                .symbol(.circle)
                            }
                        }

                        // If the selected date is different from the latest point, mark it with a white dot.
                        if let selectedPoint = computedData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                            // Determine if this selected point is the first entry in computedData
                            let isFirstEntry = computedData.count > 1 && computedData.first?.date == selectedPoint.date
                            
                            PointMark(
                                x: .value("Date", selectedPoint.date),
                                y: .value("Metric", selectedPoint.value)
                            )
                            .foregroundStyle(.white)
                            .symbol(.circle)
                            .annotation(position: .top, alignment: .center) {
                                Text("\(selectedPoint.value, specifier: "%.0f")")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.white)
                                    .frame(width: 50)
                                    .padding(5)
                                    .padding(.horizontal, 2.5)
                                    .padding(.bottom, 10)
                                    .cornerRadius(5)
                                    // Apply an x-offset when it is the very first entry
                                    .offset(x: isFirstEntry ? 20 : 0, y: 0)
                            }
                        }


                    }
                    .chartYScale(domain: 0 ... domainEnd)
                    .chartXScale(domain: firstDate ... lastDate.addingTimeInterval(extraPadding))
                    .cornerRadius(15)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                }
            }
            .frame(width: 350, height: 175)
            .background(.black.opacity(0.125))
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(.gray.opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal)
            
            // Shot type filter
            ShotTypePicker(shotType: $shotType)
                .padding(.top, 5)
            
            // Metrics display
            VStack {
                HStack(alignment: .top, spacing: 50) {
                    // Average Metric
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Average")
                            .font(.headline)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        Text(averageValue == 0 ? "-" : String(format: "%.1f", averageValue))
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(averageValue == 0 ? .gray : .white)
                    }
                    
                    // Today’s metric
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Today")
                            .font(.headline)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        if let latest = computedData.last,
                           Calendar.current.isDate(latest.date, inSameDayAs: Date()) {
                            Text("\(latest.value, specifier: "%.0f")")
                                .font(.largeTitle)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        } else {
                            Text("-")
                                .font(.largeTitle)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    // Trend Metric: Shows an arrow icon (up, down, right) with corresponding color.
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Trend")
                            .font(.headline)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        Image(systemName: trendIcon)
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundColor(trendColor)
                            .padding(.top, 5)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 1)
                
                HStack(alignment: .top, spacing: 50) {
                    // Average Metric
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Best")
                            .font(.headline)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        Text(bestValue == 0 ? "-" : String(format: "%.1f", bestValue))
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(bestValue == 0 ? .gray : .white)
                    }
                    
                    // Today’s metric
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Worst")
                            .font(.headline)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        Text(worstValue == 0 ? "-" : String(format: "%.1f", worstValue))
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(worstValue == 0 ? .gray : .white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 1)
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .padding(.horizontal)
        .padding(.top)
        .onAppear(perform: updateComputedData)
        .onChange(of: sessions) { _, _ in
            updateComputedData()
        }
        .onChange(of: shotType) { _, _ in
            updateComputedData()
        }
        .onChange(of: selectedMetric) { _, _ in
            updateComputedData()
        }
    }
    
    /// Groups the filtered sessions by day and computes a value for each day based on the selected metric.
    private func updateComputedData() {
        withAnimation(.easeInOut(duration: 0.5)) {
            let grouped = Dictionary(grouping: filteredSessions) { session in
                Calendar.current.startOfDay(for: session.date)
            }
            
            computedData = grouped.map { (date, sessions) in
                let totalMakes = sessions.reduce(0) { $0 + $1.makes }
                let sessionCount = Double(sessions.count)
                let yValue: Double
                
                switch selectedMetric {
                case .makes:
                    yValue = Double(totalMakes)
                case .average:
                    let totalTimeInMinutes = sessions.reduce(0) { $0 + $1.length }
                    yValue = totalTimeInMinutes > 0 ? Double(totalMakes) / (Double(totalTimeInMinutes) / 60.0) : 0
                case .sessions:
                    yValue = sessionCount
                case .none:
                    yValue = 0
                }
                return (date, yValue)
            }
            .sorted { $0.date < $1.date }
        }
    }
}

struct ShotTypePicker: View {
    @Binding var shotType: ShotType
    
    var lineColor: Color {
        switch shotType {
        case .freeThrows, .midrange: return .blue
        case .layups:               return .red
        case .threePointers:        return .green
        case .deep:                 return .purple
        case .allShots:             return .orange
        }
    }
    
    var body: some View {
        Menu {
            Button {
                withAnimation { shotType = .allShots }
            } label: {
                Label("All Shots", systemImage: shotType == .allShots ? "checkmark" : "")
            }
            Divider()
            Button {
                withAnimation { shotType = .layups }
            } label: {
                Label("Layups", systemImage: shotType == .layups ? "checkmark" : "")
            }
            Button {
                withAnimation { shotType = .freeThrows }
            } label: {
                Label("Free Throws", systemImage: shotType == .freeThrows ? "checkmark" : "")
            }
            Button {
                withAnimation { shotType = .midrange }
            } label: {
                Label("Midrange", systemImage: shotType == .midrange ? "checkmark" : "")
            }
            Button {
                withAnimation { shotType = .threePointers }
            } label: {
                Label("Threes", systemImage: shotType == .threePointers ? "checkmark" : "")
            }
            Button {
                withAnimation { shotType = .deep }
            } label: {
                Label("Deep", systemImage: shotType == .deep ? "checkmark" : "")
            }
        } label: {
            Text(shotType.rawValue)
                .frame(width: 125, height: 17.5)
                .foregroundStyle(lineColor)
                .fontWeight(.semibold)
                .padding(6)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray.opacity(0.25), lineWidth: 1)
                )
        }
    }
}

#Preview {
    @Previewable @State var shotType: ShotType = .allShots
    @Previewable @State var selectedMetric: GraphType = .average
    @Previewable @State var selectedDate: Date = .now
    
    return GraphTesting(shotType: $shotType, selectedMetric: $selectedMetric, selectedDate: $selectedDate)
        .modelContainer(HoopSession.preview)
}
