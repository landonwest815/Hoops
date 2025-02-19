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
    
    @State private var isOn = false
    
    @State private var selectedRange: TimeRange = .sevenDays
    @Binding var shotType: ShotType
    let dateFormatter: () = DateFormatter().dateFormat = "d MMM"
    
    @State private var currentActiveSession: HoopSession?
    @State private var plotWidth: CGFloat = 0
    
    @State private var avg: Double = 0.0
    @State private var makes: Int = 0
    
    @Binding var selectedMetric: GraphType
    
    var lineColor: Color {
        switch shotType {
        case .freeThrows:    return .blue
        case .midrange:      return .blue
        case .layups:        return .red
        case .threePointers: return .green
        case .deep:          return .purple
        case .allShots:      return .orange
        }
    }
    
    var filteredSessions: [HoopSession] {
        let allSessions = shotType == .allShots ? sessions : sessions.filter { $0.shotType == shotType }
        let now = Date()
        
        switch selectedRange {
        case .sevenDays:
            return allSessions.filter { $0.date >= Calendar.current.date(byAdding: .day, value: -7, to: now)! }
        case .month:
            return allSessions.filter { $0.date >= Calendar.current.date(byAdding: .month, value: -1, to: now)! }
        case .allTime:
            return allSessions
        }
    }
    
    var groupedSessions: [String: [HoopSession]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Ensure consistent formatting
        formatter.locale = Locale(identifier: "en_US_POSIX") // Avoid localization issues

        let grouped = Dictionary(grouping: filteredSessions) { session in
            formatter.string(from: session.date)
        }
        
        print("Grouped Sessions:", grouped) // Debugging output
        return grouped
    }
    
    var computedData: [(date: Date, value: Double)] {
        let grouped = Dictionary(grouping: filteredSessions) { session in
            Calendar.current.startOfDay(for: session.date)
        }
        
        return grouped.map { (date, sessions) in
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
    
      
    var body: some View {

        let yValues = computedData.map { $0.value }
        let averageValue = yValues.isEmpty ? 0 : yValues.reduce(0, +) / Double(yValues.count)

        // Calculate a 10% buffer around the average
        //let bufferAmount = (yValues.max() ?? 1) * 0.1
        let ruleMarkPosition = averageValue /*+ bufferAmount*/
        
        let minYValue = yValues.min() ?? 0
        let maxYValue = yValues.max() ?? 1

        // Add padding around the min/max values
        let range = maxYValue - minYValue
        let padding = max(range * 0.1, 2)
        let domainStart = minYValue >= 0 ? max(0, minYValue - padding) : minYValue - padding
        let domainEnd = maxYValue + padding
        
        VStack {
            
            HStack(alignment: .top, spacing: 15) {
                
                VStack(alignment: .leading) {
                    Text(selectedMetric.rawValue)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .contentTransition(.numericText())
                    
                    Text("\(averageValue.formatted(.number.precision(.fractionLength(1))))")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.title)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Picker("Select Range", selection: $selectedRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedRange) { _ in
                    withAnimation(.easeInOut(duration: 0.5)) { } // Ensures the transition is smooth
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            ZStack {
                
                if filteredSessions.isEmpty {
                    Text("No data available.\nGo shoot some hoops!")
                        .fontWeight(.regular)
                        .fontDesign(.rounded)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                
                
                if let firstDate = computedData.first?.date,
                   let lastDate = computedData.last?.date {
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
                        .foregroundStyle(lineColor.opacity(0.25))
                        .lineStyle(.init(lineWidth: 3))
                        .interpolationMethod(.catmullRom)
                        
                        RuleMark(y: .value("Average", ruleMarkPosition))
                            .lineStyle(.init(lineWidth: 1.5, dash: [5]))
                            .foregroundStyle(.gray)
                        
                        if let latestPoint = computedData.last {
                            PointMark(
                                x: .value("Date", latestPoint.date),
                                y: .value("Metric", latestPoint.value)
                            )
                            .foregroundStyle(.white)
                            .symbol(.circle)
                            .annotation(position: .top, alignment: .center) {
                                Text("\(latestPoint.value, specifier: "%.1f")")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .bold()
                                    .padding(4)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .chartYScale(domain: 0 ... domainEnd)
                    .chartXScale(domain: firstDate ... lastDate.addingTimeInterval(100000)) // Slightly reduce right side
                    .cornerRadius(15)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                }
                
            }
            .onChange(of: shotType) {
                print("Total Sessions: \(sessions.count)")
                print("Filtered Sessions: \(filteredSessions.count)")
            }
            //.padding(.horizontal)
            .onDisappear() {
                isOn = false
            }
            .onChange(of: currentActiveSession) { newSession in
                if let currentActiveSession = newSession {
                    let newAvg = Double(currentActiveSession.makes) / (Double(currentActiveSession.length) / 60.0)
                    if avg != newAvg {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            avg = newAvg
                        }
                    }
                }
            }
            
            
        }
        .frame(height: 200)
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
    @Previewable @State var selectedMetric: GraphType = .sessions

    
    return GraphTesting(shotType: $shotType, selectedMetric: $selectedMetric)
        .modelContainer(HoopSession.preview)
}
