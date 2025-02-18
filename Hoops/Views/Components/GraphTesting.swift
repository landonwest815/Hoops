//
//  GraphTesting.swift
//  Hoops
//
//  Created by Landon West on 3/7/24.
//

import SwiftUI
import Charts
import SwiftData

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
        let result = shotType == .allShots ? sessions : sessions.filter { $0.shotType == shotType }
        print("Filtered Sessions for \(shotType):", result.count)
        return result
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
        let data: [(Date, Double)] = groupedSessions.map { (dateString, sessions) in
            let totalMakes = sessions.reduce(0) { $0 + $1.makes }
            let totalTimeInMinutes = sessions.reduce(0) { $0 + ($1.length) } // Convert length to total minutes

            let averageMakesPerMinute = totalTimeInMinutes > 0 ? Double(totalMakes) / (Double(totalTimeInMinutes) / 60.0) : 0

            let sessionCount = Double(sessions.count)

            let yValue: Double
            switch selectedMetric {
            case .makes:
                yValue = Double(totalMakes)
            case .average:
                yValue = averageMakesPerMinute
            case .sessions:
                yValue = sessionCount
            case .none:
                yValue = 0
            }

            // Convert date string back to actual Date object
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.date(from: dateString) ?? Date()

            print("Date: \(date), Y-Value: \(yValue)") // Debugging output
            return (date, yValue)
        }
        .sorted { $0.0 < $1.0 }

        print("Computed Data Count:", data.count)
        return data
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
            
            HStack(spacing: 15) {
                
                Text(selectedMetric.rawValue)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                
                Text("\(averageValue.formatted(.number.precision(.fractionLength(2))))")
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .font(.headline)
                    .foregroundStyle(.gray)
                
                Spacer()
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
                }
                .frame(height: 175)
                .chartYScale(domain: domainStart ... domainEnd)
                .cornerRadius(15)
                .chartXAxis(.hidden)
                .padding(.bottom)
                //.chartYAxis(.hidden)
                
            }
            .onChange(of: shotType) {
                print("Total Sessions: \(sessions.count)")
                print("Filtered Sessions: \(filteredSessions.count)")
            }
            .padding(.horizontal)
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
    }
}

#Preview {
    @Previewable @State var shotType: ShotType = .allShots
    @Previewable @State var selectedMetric: GraphType = .sessions

    
    return GraphTesting(shotType: $shotType, selectedMetric: $selectedMetric)
        .modelContainer(HoopSession.preview)
}
