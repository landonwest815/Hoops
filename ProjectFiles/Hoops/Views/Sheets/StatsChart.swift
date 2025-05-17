//
//  GraphTesting.swift
//  Hoops
//
//  Created by Landon West on 3/7/24.
//

import SwiftUI
import Charts
import SwiftData

enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case allTime = "All"
    
    var id: String { self.rawValue }
}

struct StatsChart: View {
    @Environment(\.modelContext) var context
    @Query(sort: \HoopSession.date) var sessions: [HoopSession]
    
    @Binding var shotType: ShotType
    @Binding var selectedMetric: GraphType
    @Binding var selectedDate: Date
    @State var selectedTimeRange: TimeRange = .allTime

    @State private var currentActiveSession: HoopSession?
    @State private var computedData: [(date: Date, value: Double)] = []
    
    @AppStorage(AppSettingsKeys.dateFormat) private var dateFormat: String = "M dd, yyyy"

    var lineColor: Color {
        switch shotType {
        case .freeThrows, .midrange: return .blue
        case .layups:               return .red
        case .threePointers:        return .green
        case .deep:                 return .purple
        case .allShots:             return .orange
        }
    }
    
    var filteredSessions: [HoopSession] {
        shotType == .allShots ? sessions : sessions.filter { $0.shotType == shotType }
    }
    
    private enum Trend {
        case up, same, down
    }
    
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
    
    private var trendIcon: String {
        switch trend {
        case .up:   return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .same: return "arrow.right"
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .up:   return .green
        case .down: return .red
        case .same: return .gray
        }
    }
    
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
            
            HStack(spacing: 10) {
                ShotTypePicker(shotType: $shotType)
                TimeRangeSegmentedPicker(selectedTimeRange: $selectedTimeRange, shotType: $shotType)
            }
            
            chartView
            
            benchmarksView
        }
        .padding(.horizontal)
        .padding(.top)
        .onAppear(perform: updateComputedData)
        .onChange(of: sessions) { _, _ in updateComputedData() }
        .onChange(of: shotType) { _, _ in updateComputedData() }
        .onChange(of: selectedMetric) { _, _ in updateComputedData() }
        .onChange(of: selectedTimeRange) { _, _ in updateComputedData() }
    }
        
    private var headerView: some View {
        HStack(spacing: 20) {
            Text(selectedMetric.rawValue)
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
            
            HStack {
                Image(systemName: "calendar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 16)
                Text(formattedDate)
                    .id(selectedDate)
                    .transition(.opacity)
                    .contentTransition(.numericText())
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
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: selectedDate)
    }
    
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
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Metric", $0.value)
                    )
                    .foregroundStyle(lineColor)
                    .lineStyle(.init(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
                    
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
                    
                    RuleMark(y: .value("Average", ruleMarkPosition))
                        .lineStyle(.init(lineWidth: 1, dash: [2.5]))
                        .foregroundStyle(.gray.opacity(0.25))
                    
                    PointMark(
                        x: .value("Date", $0.date),
                        y: .value("Metric", $0.value)
                    )
                    .symbol(.circle)
                    .foregroundStyle(lineColor)
                    
                    if let latestPoint = computedData.max(by: { $0.date < $1.date }) {
                        PointMark(
                            x: .value("Date", latestPoint.date),
                            y: .value("Metric", latestPoint.value)
                        )
                        .foregroundStyle(lineColor)
                        .symbol(.circle)
                        
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
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        guard
                                            let plotArea = proxy.plotFrame,
                                            !computedData.isEmpty
                                        else { return }

                                        let frame = geometry[plotArea]
                                        let locationX = value.location.x - frame.origin.x
                                        guard let rawDate: Date = proxy.value(atX: locationX) else { return }

                                        if let nearest = computedData.min(
                                            by: { abs($0.date.timeIntervalSince(rawDate)) < abs($1.date.timeIntervalSince(rawDate)) }
                                        ) {
                                            if !Calendar.current.isDate(nearest.date, inSameDayAs: selectedDate) {
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                                withAnimation {
                                                    selectedDate = nearest.date
                                                }
                                            }
                                        }
                                    }
                            )
                    }
                }

            }
            
            if !computedData.isEmpty &&
               computedData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) == nil {
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
        .frame(maxWidth: .infinity, maxHeight: 175)
        .background(.black.opacity(0.125))
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        )
    }
    
    private var todayValue: String {
        guard
          let latest = computedData.last,
          Calendar.current.isDate(latest.date, inSameDayAs: Date())
        else {
          return "–"
        }

        if latest.value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(latest.value))"
        } else {
            return String(format: "%.2f", latest.value)
        }
    }
    
    private var benchmarksView: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                
                InfoCard(title: "Average", iconName: "lines.measurement.horizontal", iconColor: .red, textValue: String(averageValue))
                
                InfoCard(title: "Today", iconName: "calendar", iconColor: .blue, textValue: todayValue)
                
                InfoCard(title: "Trend", iconName: trendIcon, iconColor: trendColor, textValue: "")
                    .frame(maxWidth: 65)
            
            }
            
            HStack(alignment: .top, spacing: 10) {
                
                InfoCard(
                    title: "Best",
                    iconName: "trophy.fill",
                    iconColor: .yellow,
                    textValue: bestValue == 0
                        ? "-"
                        : (bestValue.truncatingRemainder(dividingBy: 1) == 0
                            ? "\(Int(bestValue))"
                            : String(format: "%.2f", bestValue))
                )
                
                InfoCard(
                    title: "Worst",
                    iconName: "trash.fill",
                    iconColor: .gray,
                    textValue: worstValue == 0
                        ? "-"
                        : (worstValue.truncatingRemainder(dividingBy: 1) == 0
                           ? "\(Int(worstValue))"
                           : String(format: "%.2f", worstValue))
                )
                
                
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
    
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
            
            let timeFilteredSessions = filteredSessions.filter { $0.date >= startDate }
            
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
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray.opacity(0.25), lineWidth: 1)
                )
        }
    }
}

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
                        .foregroundStyle(selectedTimeRange == range ? lineColor : .gray)
                        .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 17.5)
        .foregroundStyle(lineColor)
        .fontWeight(.semibold)
        .padding(6)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        )
    }
}


struct InfoCard: View {
    let title: String
    let iconName: String
    let iconColor: Color
    private let textValue: String?
    private let symbolValue: String?
    
    init(title: String,
         iconName: String,
         iconColor: Color = .white,
         textValue: String)
    {
        self.title = title
        self.iconName = iconName
        self.iconColor = iconColor
        self.textValue = textValue
        self.symbolValue = nil
    }

    init(title: String,
         iconName: String,
         iconColor: Color = .white,
         symbolValue: String)
    {
        self.title = title
        self.iconName = iconName
        self.iconColor = iconColor
        self.symbolValue = symbolValue
        self.textValue = nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2.5) {
            HStack {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 16)
                    .foregroundColor(iconColor)
                    .fontWeight(.semibold)

                if let text = textValue {
                    Text(text)
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .contentTransition(.numericText())
                        .foregroundColor(.white)
                        .frame(height: 25)
                }
                else if let sym = symbolValue {
                    Image(systemName: sym)
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundColor(iconColor)
                }
                
                Spacer()
            }

            Text(title)
                .font(.caption)
                .fontDesign(.rounded)
                .fontWeight(.regular)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundColor(.gray.opacity(0.25))
        )
    }
}

#Preview {
    @Previewable @State var shotType: ShotType = .allShots
    @Previewable @State var selectedMetric: GraphType = .average
    @Previewable @State var selectedDate: Date = .now
    
    return StatsChart(shotType: $shotType, selectedMetric: $selectedMetric, selectedDate: $selectedDate)
        .modelContainer(HoopSession.preview)
}
