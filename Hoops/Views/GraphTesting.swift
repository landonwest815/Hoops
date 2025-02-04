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
    
      
    var body: some View {
        
        let filteredValues = filteredSessions.map {
            Double($0.makes) / (Double($0.length) / 60.0)
        }
        
        let averageValue = filteredValues.isEmpty ? 0 : filteredValues.reduce(0, +) / Double(filteredValues.count)

        // Provide sensible defaults if there are no sessions:
        let minYValue = filteredValues.min() ?? 0
        let maxYValue = filteredValues.max() ?? 1
        
        // Add some “padding” around the min/max values.
        // For example, 10% on top/bottom:
        let range = maxYValue - minYValue
        let domainStart = max(0, minYValue - 0.1 * range)
        let domainEnd   = maxYValue + 0.1 * range
    
        
        ZStack {
            
            if filteredSessions.isEmpty {
                Text("No data available.\nGo shoot some hoops!")
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            
            Chart(filteredSessions) {
                LineMark(
                    x: .value("Month", $0.id.description),
                    y: .value("Hours of Sunshine", Double($0.makes) / (Double($0.length) / 60.0))
                )
                .foregroundStyle(lineColor)
                .lineStyle(.init(lineWidth: 3))
                .interpolationMethod(.catmullRom)
                
                RuleMark(y: .value("Average", averageValue))
                    .lineStyle(.init(lineWidth: 1.5, dash: [5]))
                    .foregroundStyle(.gray)
//                    .annotation(position: .topTrailing) {
//                        Text("Avg: \(String(format: "%.2f", averageValue))")
//                            .font(.caption)
//                            .foregroundColor(.white)
//                            .padding(4)
//                            .background {
//                                RoundedRectangle(cornerRadius: 4)
//                                    .fill(.ultraThinMaterial)
//                            }
//                    }
                
                //let makes = $0.makes
                //let length = $0.length / 60
                
                PointMark(
                    x: .value("Index", $0.id.description),
                    y: .value("Value", Double($0.makes) / (Double($0.length) / 60.0))
                )
                .foregroundStyle(.white)
                    
                
//                if let currentActiveSession,currentActiveSession.id == $0.id {
//                    RuleMark(x: .value("Index", currentActiveSession.id.description))
//                        .lineStyle(.init(lineWidth: 1.5, miterLimit: 2, dash: [5], dashPhase: 5))
//                        .foregroundStyle(.white)
//                        .annotation(position: .top) {
//                            HStack(spacing: 10) {
//                                VStack(alignment: .center, spacing: 1) {
//                                    Text("Makes")
//                                        .font(.caption)
//                                        .foregroundStyle(.white)
//                                        .frame(width: 50)
//                                    
//                                    Text(String(makes))
//                                        .font(.title3.bold())
//                                        .foregroundStyle(.white)
//                                        .contentTransition(.numericText())
//                                        .animation(.easeInOut(duration: 0.3), value: makes)
//                                        .frame(width: 50)
//                                }
//                                .frame(height: 40)
//                                .padding(2.5)
//                                .background(.white.opacity(0.2))
//                                .cornerRadius(10)
//                                
//                                VStack(alignment: .center, spacing: 1) {
//                                    
//                                    Text("Avg")
//                                        .font(.caption)
//                                        .foregroundStyle(.white)
//                                        .frame(width: 50)
//                                                                        
//                                    Text(String(format: "%.1f", avg))
//                                        .font(.title3.bold())
//                                        .foregroundStyle(.white)
//                                        .contentTransition(.numericText())
//                                        .animation(.easeInOut(duration: 0.3), value: avg)
//                                        .frame(width: 50)
//                                        .sensoryFeedback(.increase, trigger: avg)
//                                }
//                                .frame(height: 40)
//                                .padding(2.5)
//                                .background(.white.opacity(0.2))
//                                .cornerRadius(10)
//                                
//                            }
//                            .padding(.horizontal, 10)
//                            .padding(.top, 30)
//                        }
//                } else {
                    RuleMark(y: .value("Average", averageValue))
                        .lineStyle(.init(lineWidth: 1.5, dash: [5]))
                        .foregroundStyle(.gray)
                        .annotation(position: .topTrailing) {
                            Text("Avg: \(String(format: "%.1f", averageValue))")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(4)
                                .offset(x: -66)
                        }
                    
                //}
                
                
            }
            .frame(height: 150)
            .chartYScale(domain: domainStart ... domainEnd)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .cornerRadius(15)
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
    
    var filteredSessions: [HoopSession] {
        shotType == .allShots ? sessions : sessions.filter { $0.shotType == shotType }
    }
}

#Preview {
    @Previewable @State var shotType: ShotType = .deep
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HoopSession.self, configurations: config)
    
    let hoopSession3 = HoopSession(date: Date(timeInterval: -86400, since: Date.now), makes: 15, length: 240, shotType: .threePointers)
    container.mainContext.insert(hoopSession3)
    
    let hoopSession1 = HoopSession(date: Date.now, makes: 5, length: 120, shotType: .threePointers)
    container.mainContext.insert(hoopSession1)
    
    let hoopSession6 = HoopSession(date: Date(timeInterval: -8400, since: Date.now), makes: 20, length: 120, shotType: .threePointers)
    container.mainContext.insert(hoopSession6)
    
    let hoopSession2 = HoopSession(date: Date(timeInterval: 86400, since: Date.now), makes: 10, length: 90, shotType: .threePointers)
    container.mainContext.insert(hoopSession2)
    
    let hoopSession4 = HoopSession(date: Date(timeInterval: 6 * 86400, since: Date.now), makes: 6, length: 90, shotType: .threePointers)
    container.mainContext.insert(hoopSession4)
    
    let hoopSession8 = HoopSession(date: Date(timeInterval: 7 * 86400, since: Date.now), makes: 11, length: 90, shotType: .threePointers)
    container.mainContext.insert(hoopSession8)
    
    let hoopSession9 = HoopSession(date: Date(timeInterval: 8 * 86400, since: Date.now), makes: 15, length: 90, shotType: .threePointers)
    container.mainContext.insert(hoopSession9)
    
    let hoopSession10 = HoopSession(date: Date(timeInterval: 15 * 86400, since: Date.now), makes: 4, length: 90, shotType: .threePointers)
    container.mainContext.insert(hoopSession10)
    
    let hoopSession11 = HoopSession(date: Date(timeInterval: 60 * 86400, since: Date.now), makes: 3, length: 90, shotType: .threePointers)
    container.mainContext.insert(hoopSession11)
    
    return GraphTesting(shotType: $shotType)
        .modelContainer(container)
}
