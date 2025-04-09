//
//  GraphTesting.swift
//  Hoops
//
//  Created by Landon West on 3/7/24.
//

import SwiftUI
import Charts
import SwiftData

// MARK: - Supporting Enums
enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case allTime = "All"
    
    var id: String { self.rawValue }
}


// MARK: - GraphTesting View
struct GraphTesting: View {
    // MARK: Environment and Query Properties
    @Environment(\.modelContext) var context
    @Query(sort: \HoopSession.date) var sessions: [HoopSession]
    
    // MARK: Bindings
    @Binding var shotType: ShotType
    @Binding var selectedMetric: GraphType
    @Binding var selectedDate: Date
    @State var selectedTimeRange: TimeRange = .allTime

    
    // MARK: State Properties
    @State private var currentActiveSession: HoopSession?
    @State private var computedData: [(date: Date, value: Double)] = []
    
    // MARK: Computed Properties
    
    /// Returns the color for the chart based on the current shot type.
    var lineColor: Color {
        switch shotType {
        case .freeThrows, .midrange: return .blue
        case .layups:               return .red
        case .threePointers:        return .green
        case .deep:                 return .purple
        case .allShots:             return .orange
        }
    }
    
    /// Filters sessions based on selected shot type (or returns all sessions).
    var filteredSessions: [HoopSession] {
        shotType == .allShots ? sessions : sessions.filter { $0.shotType == shotType }
    }
    
    /// Enum representing the trend direction.
    private enum Trend {
        case up, same, down
    }
    
    /// Computes the overall trend by comparing the latest data value with the average.
    private var trend: Trend {
        guard !computedData.isEmpty, let lastValue = computedData.last?.value else {
            return .same
        }
        
        let total = computedData.reduce(0.0) { $0 + $1.value }
        let average = total / Double(computedData.count)
        let threshold = 0.15
        
        if average != 0 {
            if lastValue > average * (1 + threshold) {
                return .up
            } else if lastValue < average * (1 - threshold) {
                return .down
            } else {
                return .same
            }
        } else {
            return lastValue > 0 ? .up : (lastValue < 0 ? .down : .same)
        }
    }
    
    /// Returns the SF Symbol name based on the trend.
    private var trendIcon: String {
        switch trend {
        case .up:   return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .same: return "arrow.right"
        }
    }
    
    /// Returns the color corresponding to the trend.
    private var trendColor: Color {
        switch trend {
        case .up:   return .green
        case .down: return .red
        case .same: return .gray
        }
    }
    
    // MARK: Derived Chart Metrics
    private var chartYValues: [Double] {
        computedData.map { $0.value }
    }
    
    private var rawAverage: Double {
        guard !chartYValues.isEmpty else { return 0 }
        return chartYValues.reduce(0, +) / Double(chartYValues.count)
    }
    
    private var averageValue: Double {
        Double(round(10 * rawAverage) / 10)
    }
    
    private var ruleMarkPosition: Double {
        averageValue
    }
    
    private var minYValue: Double {
        chartYValues.min() ?? 0
    }
    
    private var maxYValue: Double {
        chartYValues.max() ?? 1
    }
    
    private var domainEnd: Double {
        let padding = averageValue
        return maxYValue + padding
    }
    
    private var bestValue: Double {
        chartYValues.max() ?? 0
    }
    
    private var worstValue: Double {
        chartYValues.filter { $0 > 0 }.min() ?? 0
    }
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 15) {
            headerView
            chartView
            
            HStack {
                ShotTypePicker(shotType: $shotType)
                TimeRangeSegmentedPicker(selectedTimeRange: $selectedTimeRange, shotType: $shotType)
            }
            .padding(.top, 5)
            .padding(.horizontal)
            
            benchmarksView
                .padding(.top, 20)
        }
        .padding(.horizontal)
        .padding(.top)
        .onAppear(perform: updateComputedData)
        .onChange(of: sessions) { _, _ in updateComputedData() }
        .onChange(of: shotType) { _, _ in updateComputedData() }
        .onChange(of: selectedMetric) { _, _ in updateComputedData() }
        .onChange(of: selectedTimeRange) { _, _ in updateComputedData() }
    }
    
    // MARK: Subviews
    
    /// Header section showing the selected metric and date.
    private var headerView: some View {
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
    }
    
    /// Chart section displaying the computed metric over time.
    private var chartView: some View {
        ZStack {
            if filteredSessions.isEmpty {
                Text("No data available.\nGo shoot some hoops!")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray.opacity(0.75))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
            }
            
            if let firstDate = computedData.first?.date,
               let lastDate = computedData.last?.date {
                let totalDuration = lastDate.timeIntervalSince(firstDate)
                let extraPadding = totalDuration * 0.1
                
                Chart(computedData, id: \.date) {
                    // Line mark
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Metric", $0.value)
                    )
                    .foregroundStyle(lineColor)
                    .lineStyle(.init(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
                    
                    // Filled area under the line
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
                    
                    // Average rule mark
                    RuleMark(y: .value("Average", ruleMarkPosition))
                        .lineStyle(.init(lineWidth: 1, dash: [2.5]))
                        .foregroundStyle(.gray.opacity(0.25))
                    
                    // Latest point marker
                    if let latestPoint = computedData.max(by: { $0.date < $1.date }) {
                        PointMark(
                            x: .value("Date", latestPoint.date),
                            y: .value("Metric", latestPoint.value)
                        )
                        .foregroundStyle(lineColor)
                        .symbol(.circle)
                        
                        // If the selected date matches the latest point, annotate it.
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
                    
                    // Selected point marker with annotation
                    if let selectedPoint = computedData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                        let isFirstEntry = computedData.count > 1 && computedData.first?.date == selectedPoint.date
                        PointMark(
                            x: .value("Date", selectedPoint.date),
                            y: .value("Metric", selectedPoint.value)
                        )
                        .foregroundStyle(.white)
                        .symbol(.circle)
                        .annotation(position: .top, alignment: .center) {
                            Text(selectedPoint.value.truncatingRemainder(dividingBy: 1) == 0 ?
                                 "\(Int(selectedPoint.value))" :
                                 String(format: "%.2f", selectedPoint.value))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                                .frame(width: 50)
                                .padding(5)
                                .padding(.horizontal, 2.5)
                                .padding(.bottom, 10)
                                .cornerRadius(5)
                                .offset(x: isFirstEntry ? 20 : 0)
                        }
                    }
                }
                .chartYScale(domain: 0 ... domainEnd)
                .chartXScale(domain: firstDate ... lastDate.addingTimeInterval(extraPadding))
                .cornerRadius(15)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
            }
            
            // Overlay if there is no data on the selected day.
            if computedData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) == nil {
                VStack {
                    Text("No data for the selected day")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray.opacity(0.75))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .padding(.top, 15)
                    Spacer()
                }
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
    }
    
    /// Benchmarks display showing average, today’s metric, trend, best, and worst values.
    private var benchmarksView: some View {
        VStack {
            HStack(alignment: .top, spacing: 50) {
                // Average Metric
                VStack(alignment: .leading, spacing: 5) {
                    Text("Average")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    Text(averageValue == 0 ? "-" :
                         (averageValue.truncatingRemainder(dividingBy: 1) == 0 ?
                             "\(Int(averageValue))" : String(format: "%.2f", averageValue)))
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(averageValue == 0 ? .gray : .white)
                }
                
                // Today's Metric
                VStack(alignment: .leading, spacing: 5) {
                    Text("Today")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    if let latest = computedData.last,
                       Calendar.current.isDate(latest.date, inSameDayAs: Date()) {
                        Text(latest.value.truncatingRemainder(dividingBy: 1) == 0 ?
                             "\(Int(latest.value))" :
                             String(format: "%.2f", latest.value))
                            .font(.title)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    } else {
                        Text("-")
                            .font(.title)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                    }
                }
                
                // Trend Metric
                VStack(alignment: .leading, spacing: 5) {
                    Text("Trend")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    Image(systemName: trendIcon)
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundColor(trendColor)
                        .padding(.top, 5)
                }
            }
            .padding(.horizontal)
            .padding(.top, 1)
            
            HStack(alignment: .top, spacing: 50) {
                // Best Metric
                VStack(alignment: .leading, spacing: 5) {
                    Text("Best")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    Text(bestValue == 0 ? "-" :
                         (bestValue.truncatingRemainder(dividingBy: 1) == 0 ?
                             "\(Int(bestValue))" : String(format: "%.2f", bestValue)))
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(bestValue == 0 ? .gray : .white)
                }
                
                // Worst Metric
                VStack(alignment: .leading, spacing: 5) {
                    Text("Worst")
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    Text(worstValue == 0 ? "-" :
                         (worstValue.truncatingRemainder(dividingBy: 1) == 0 ?
                             "\(Int(worstValue))" : String(format: "%.2f", worstValue)))
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundStyle(worstValue == 0 ? .gray : .white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 1)
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    /// Groups the filtered sessions by day and computes a metric value for each day.
    private func updateComputedData() {
        withAnimation(.easeInOut(duration: 0.5)) {
            let now = Date()
            let startDate: Date = {
                switch selectedTimeRange {
                case .week:
                    return Calendar.current.date(byAdding: .day, value: -7, to: now)!
                case .month:
                    return Calendar.current.date(byAdding: .month, value: -1, to: now)!
                case .allTime:
                    return Date.distantPast
                }
            }()
            
            // Filter sessions by the selected time range.
            let timeFilteredSessions = filteredSessions.filter { $0.date >= startDate }
            
            // Group sessions by the start of the day.
            let grouped = Dictionary(grouping: timeFilteredSessions) { session in
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

// MARK: - ShotTypePicker View
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
                .frame(width: 100, height: 17.5)
                .foregroundStyle(lineColor)
                .fontWeight(.semibold)
                .font(.headline)
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

/// A custom segmented picker for time ranges that updates the data scope.
struct TimeRangeSegmentedPicker: View {
    @Binding var selectedTimeRange: TimeRange
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
        HStack(spacing: 0) {
            ForEach(TimeRange.allCases) { range in
                Button(action: {
                    withAnimation { selectedTimeRange = range }
                }) {
                    Text(range.rawValue)
                        .font(.headline)
                        .lineLimit(1)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        // Change text color based on selection.
                        .foregroundStyle(selectedTimeRange == range ? lineColor : .gray)
                        // Highlight the selected segment.
//                        .background(
//                            RoundedRectangle(cornerRadius: 8)
//                                .fill(selectedTimeRange == range ? lineColor.opacity(0.5) : Color.clear)
//                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 17.5)
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

#Preview {
    @Previewable @State var shotType: ShotType = .allShots
    @Previewable @State var selectedMetric: GraphType = .average
    @Previewable @State var selectedDate: Date = .now
    
    return GraphTesting(shotType: $shotType, selectedMetric: $selectedMetric, selectedDate: $selectedDate)
        .modelContainer(HoopSession.preview)
}
