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
        
        // Provide sensible defaults if there are no sessions:
        let minYValue = filteredValues.min() ?? 0
        let maxYValue = filteredValues.max() ?? 1
        
        // Add some “padding” around the min/max values.
        // For example, 10% on top/bottom:
        let range = maxYValue - minYValue
        let domainStart = max(0, minYValue - 0.1 * range)
        let domainEnd   = maxYValue + 0.1 * range
        
        ZStack {
            
            Chart(filteredSessions) {
                LineMark(
                    x: .value("Month", $0.date.description),
                    y: .value("Hours of Sunshine", Double($0.makes) / (Double($0.length) / 60.0))
                )
                .foregroundStyle(lineColor)
                .lineStyle(.init(lineWidth: 3))
                .interpolationMethod(.catmullRom)
                
                //let makes = $0.makes
                //let length = $0.length / 60
                
                PointMark(
                    x: .value("Index", $0.date.description),
                    y: .value("Value", Double($0.makes) / (Double($0.length) / 60.0))
                )
                .foregroundStyle(.white)
                
                if let currentActiveSession,currentActiveSession.id == $0.id {
                    RuleMark(x: .value("Index", currentActiveSession.date.description))
                        .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2], dashPhase: 5))
                        .annotation(position: .top) {
                            HStack(spacing: 18) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Makes")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                    
                                    Text(String(currentActiveSession.makes))
                                        .font(.title3.bold())
                                        .foregroundStyle(.orange)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Length")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                    
                                    let minutes = Double(currentActiveSession.length) / 60.0
                                    
                                    
                                    Text(String(format: "%.1f", minutes) + "min")
                                        .font(.title3.bold())
                                        .foregroundStyle(.orange)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    
                                    Text("AVG")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                    
                                    let avg = Double(currentActiveSession.makes) / (Double(currentActiveSession.length) / 60.0)
                                    
                                    Text(String(format: "%.1f", avg))
                                        .font(.title3.bold())
                                        .foregroundStyle(.orange)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(.black.shadow(.drop(radius: 2)))
                            }
                        }
                }
                
                
            }
            .frame(height: 150)
            .chartYScale(domain: domainStart ... domainEnd)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartOverlay(content: { proxy in
                GeometryReader {innerProxy in
                    Rectangle()
                        .fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged{value in
                                    let location = value.location
                                    
                                    if let date: String = proxy.value(atX: location.x) {
                                        
                                        if let currentSession = sessions.first(where: { item in
                                            item.date.description == date
                                        }) {
                                            self.currentActiveSession = currentSession
                                            self.plotWidth = proxy.plotSize.width
                                        }
                                    }
                                }.onEnded {value in
                                    self.currentActiveSession = nil
                                }
                        )
                    
                    
                }
            })
            .padding(.vertical)
            //.background(.ultraThinMaterial)
            .cornerRadius(15)
        }
        .onDisappear() {
            isOn = false
        }
    }
    
    var filteredSessions: [HoopSession] {
        sessions.filter { $0.shotType == shotType }
    }
}

#Preview {
    @Previewable @State var shotType: ShotType = .threePointers
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
