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
    
    @Binding var shotType: ShotType
    let dateFormatter: () = DateFormatter().dateFormat = "d MMM"
    
    @State private var currentActiveSession: HoopSession?
    @State private var plotWidth: CGFloat = 0
    
    @State private var avg: Double = 0.0
    @State private var makes: Int = 0
    
    @Binding var selectedMetric: GraphType
    @Binding var selectedDate: Date
    
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
        return allSessions
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
        let padding = max(range * 0.5, 2)
        let domainStart = minYValue >= 0 ? max(0, minYValue - padding) : minYValue - padding
        let domainEnd = maxYValue + padding
        
        ZStack(alignment: .bottom) {
            
            VStack {
                HStack {
                    Text(selectedMetric.rawValue)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.title2)
                        .foregroundStyle(.gray)
                        .contentTransition(.numericText())
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                HStack(alignment: .top, spacing: 30) {
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Average")
                        }
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
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Today")
                        }
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .contentTransition(.numericText())
                        
                        if let latest = computedData.last {
                            Text("\(latest.value.formatted(.number.precision(.fractionLength(0))))")
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .font(.title)
                                .foregroundStyle(.white)
                        } else {
                            Text("N/a")
                        }
                    }
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
                .padding(.top, 1)
                
                Spacer()
            }
            .frame(height: 200)
            
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
                    
                    let totalDuration = lastDate.timeIntervalSince(firstDate)
                    let padding = totalDuration * 0.1 // 10% padding, adjust as needed
                    
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
                            .lineStyle(.init(lineWidth: 1.5, dash: [2.5]))
                            .foregroundStyle(.gray)
                        
                        if let selectedPoint = computedData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }),
                            let currentPoint = computedData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {
                            
                            // Orange dot for the current date
                            PointMark(
                                x: .value("Date", currentPoint.date),
                                y: .value("Metric", currentPoint.value)
                            )
                            .foregroundStyle(.orange)
                            .symbol(.circle)
                            
                            PointMark(
                                x: .value("Date", selectedPoint.date),
                                y: .value("Metric", selectedPoint.value)
                            )
                            .foregroundStyle(.white)
                            .symbol(.circle)
                            .annotation(position: .top, alignment: .center) {
                                Text("\(selectedPoint.value, specifier: "%.1f")")
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
                    .chartXScale(domain: firstDate ... lastDate.addingTimeInterval(padding)) // Proportional right-side padding
                    .cornerRadius(15)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)

                }
                
            }
            .frame(height: 125)
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
    @Previewable @State var selectedMetric: GraphType = .makes
    @Previewable @State var selectedDate: Date = .now

    
    return GraphTesting(shotType: $shotType, selectedMetric: $selectedMetric, selectedDate: $selectedDate)
        .modelContainer(HoopSession.preview)
}
