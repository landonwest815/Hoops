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
    
    let dateFormatter = DateFormatter()
    init() {
        dateFormatter.dateFormat = "d MMM"
    }
    
    var body: some View {
        
        ZStack {
            Chart(sessions) {
                LineMark(
//                    x: .value("Month", dateFormatter.string(from: $0.date)),
                    x: .value("Month", $0.date.formatted(date: .long, time: .shortened)),
                    y: .value("Hours of Sunshine", Double($0.makes) / (Double($0.length) / 60.0))
                )
                .foregroundStyle(Color.orange)
                .lineStyle(.init(lineWidth: 3))
                .interpolationMethod(.catmullRom)
                
                let makes = $0.makes
                let length = $0.length / 60
                        
                if (isOn) {

                PointMark(
                    x: .value("Index", $0.date.formatted(date: .long, time: .shortened)),
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
            .frame(height: 300)
            
            HStack {
                VStack {
                    Toggle(isOn: $isOn.animation()) {
                        Image(systemName: "eye")
                    }
                    .toggleStyle(.button)
                    .clipShape(.circle)
                    Spacer()
                }
                .frame(height: 285)
                Spacer()
            }
        }
        
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HoopSession.self, configurations: config)
    
    let hoopSession3 = HoopSession(date: Date(timeInterval: -86400, since: Date.now), makes: 15, length: 240)
    container.mainContext.insert(hoopSession3)

    let hoopSession1 = HoopSession(date: Date.now, makes: 5, length: 120)
    container.mainContext.insert(hoopSession1)
    
    let hoopSession2 = HoopSession(date: Date(timeInterval: 86400, since: Date.now), makes: 10, length: 90)
    container.mainContext.insert(hoopSession2)
    
    return GraphTesting()
           .modelContainer(container)
}
