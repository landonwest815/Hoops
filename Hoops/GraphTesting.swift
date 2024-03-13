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
    @State private var color: Color = .orange
      
    var body: some View {
        
        ZStack {
            
            Chart(filteredSessions) {
                LineMark(
                    x: .value("Month", $0.date.description),
                    y: .value("Hours of Sunshine", Double($0.makes) / (Double($0.length) / 60.0))
                )
                .foregroundStyle(color)
                .lineStyle(.init(lineWidth: 3))
                .interpolationMethod(.catmullRom)
                .symbol(.circle)
                
                let makes = $0.makes
                let length = $0.length / 60
                        
                if (isOn) {

                PointMark(
                    x: .value("Index", $0.date),
                    y: .value("Value", Double($0.makes) / (Double($0.length) / 60.0))
                    )
                    .annotation(position: .automatic,
                                alignment: .bottomLeading,
                                spacing: 5) {
                        Text("\(makes) makes \n \(length) min")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                            .padding(5) // Add padding around the text
                            .background(Color.black.opacity(0.5)) // Semi-transparent black background
                            .clipShape(RoundedRectangle(cornerRadius: 5)) // Rounded corners
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.orange, lineWidth: 1) // White border for more contrast
                            )
                            .opacity(isOn ? 1.0 : 0.0)
                        
                    }
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 300)
            .onTapGesture {
                withAnimation {
                    isOn.toggle()
                }
            }
        }
        .onChange(of: shotType) {
                    switch shotType {
                    case .freeThrows:
                        color = .blue
                    case .midrange:
                        color = .blue
                    case .layups:
                        color = .red
                    case .threePointers:
                        color = .green
                    case .deep:
                        color = .purple
                    case .allShots:
                        color = .orange
                    }
            
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
    
    @State var shotType: ShotType = .threePointers
    
    return GraphTesting(shotType: $shotType)
           .modelContainer(container)
}
