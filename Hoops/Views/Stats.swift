//
//  Stats.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import SwiftUI
import SwiftData

struct Stats: View {
    
    @Environment(\.modelContext) var context
    
    @Query var sessions: [HoopSession]
    
    @State private var color: Color = .orange
    @Binding var shotType: ShotType
    
    var body: some View {
        
        NavigationStack {
            
            // MARK: - List of Wants
            VStack(spacing: 10) {
                
                Text(shotType.rawValue)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .font(.title3)
                    .contentTransition(.numericText())
                
                StatCards(type: $shotType)
                
                GraphTesting(shotType: $shotType)
                
                CourtTesting(type: $shotType)
                    .padding(.bottom)
                
            }
            .padding(.horizontal)
        }
    }
}


struct StatCards: View {
    @Query(sort: \HoopSession.date, order: .reverse) var sessions: [HoopSession]
    @Binding var type: ShotType

    var body: some View {
        HStack(spacing: 10) {
            
            VStack {
                Text("Total Time")
                    .font(.caption)
                
                Text(formattedTotalTime)
                    .contentTransition(.numericText())
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            
            VStack {
                Text("Makes")
                    .font(.caption)
                
                Text(String(totalMakes))
                    .contentTransition(.numericText())
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .font(.headline)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            
            
            VStack {
                Text("Avg")
                    .font(.caption)
                
                HStack(spacing: 5) {
                    Text(String(format: "%.1f", averageShotsPerMinute))
                        .contentTransition(.numericText())
                    Text("/ min")
                        .foregroundStyle(.gray)
                }
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .font(.headline)
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
        }
    }
    
    // Computed property for total makes
    private var totalMakes: Int {
        (type == .allShots ? sessions : sessions.filter { $0.shotType == type })
            .reduce(0) { $0 + $1.makes }
    }

    // Computed property for formatted total time
    private var formattedTotalTime: String {
        let totalSeconds = (type == .allShots ? sessions : sessions.filter { $0.shotType == type })
            .reduce(0) { $0 + $1.length }

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        return "\(hours)h \(minutes)m"
    }

    // Computed property for average shots per minute
    private var averageShotsPerMinute: Double {
        let sessionAverages = (type == .allShots ? sessions : sessions.filter { $0.shotType == type })
            .map { Double($0.makes) / (Double($0.length) / 60.0) } // Shots per minute for each session

        guard !sessionAverages.isEmpty else { return 0.0 } // Avoid division by zero

        return sessionAverages.reduce(0, +) / Double(sessionAverages.count)
    }
}

#Preview {
    @Previewable @State var shotType = ShotType.threePointers
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HoopSession.self, configurations: config)
    
    // -- LAYUPS (3 examples) --
    let layups1 = HoopSession(
        date: Date(timeInterval: -86400 * 3, since: .now), // 3 days ago
        makes: 12,
        length: 180,
        shotType: .layups
    )
    container.mainContext.insert(layups1)
    
    let layups2 = HoopSession(
        date: Date(timeInterval: -86400 * 2, since: .now), // 2 days ago
        makes: 9,
        length: 220,
        shotType: .layups
    )
    container.mainContext.insert(layups2)
    
    let layups3 = HoopSession(
        date: Date(timeInterval: -86400, since: .now), // 1 day ago
        makes: 15,
        length: 240,
        shotType: .layups
    )
    container.mainContext.insert(layups3)
    
    // -- MIDRANGE (3 examples) --
    let midrange1 = HoopSession(
        date: Date(), // now
        makes: 5,
        length: 100,
        shotType: .midrange
    )
    container.mainContext.insert(midrange1)
    
    let midrange2 = HoopSession(
        date: Date(timeInterval: 86400, since: .now), // +1 day
        makes: 6,
        length: 130,
        shotType: .midrange
    )
    container.mainContext.insert(midrange2)
    
    let midrange3 = HoopSession(
        date: Date(timeInterval: 86400 * 2, since: .now), // +2 days
        makes: 4,
        length: 90,
        shotType: .midrange
    )
    container.mainContext.insert(midrange3)
    
    // -- FREE THROWS (3 examples) --
    let freeThrows1 = HoopSession(
        date: Date(timeInterval: -86400 * 2, since: .now),
        makes: 10,
        length: 120,
        shotType: .freeThrows
    )
    container.mainContext.insert(freeThrows1)
    
    let freeThrows2 = HoopSession(
        date: Date(timeInterval: -86400, since: .now),
        makes: 12,
        length: 90,
        shotType: .freeThrows
    )
    container.mainContext.insert(freeThrows2)
    
    let freeThrows3 = HoopSession(
        date: Date(timeInterval: 86400, since: .now),
        makes: 8,
        length: 110,
        shotType: .freeThrows
    )
    container.mainContext.insert(freeThrows3)
    
    // -- THREE POINTERS (3 examples) --
    let threePointers1 = HoopSession(
        date: Date(timeInterval: -86400, since: .now),
        makes: 5,
        length: 150,
        shotType: .threePointers
    )
    container.mainContext.insert(threePointers1)
    
    let threePointers2 = HoopSession(
        date: Date(), // now
        makes: 7,
        length: 180,
        shotType: .threePointers
    )
    container.mainContext.insert(threePointers2)
    
    let threePointers3 = HoopSession(
        date: Date(timeInterval: 86400, since: .now), // +1 day
        makes: 9,
        length: 200,
        shotType: .threePointers
    )
    container.mainContext.insert(threePointers3)
    
    // -- ALL SHOTS (3 examples) --
    let allShots1 = HoopSession(
        date: Date(timeInterval: -86400 * 3, since: .now),
        makes: 10,
        length: 210,
        shotType: .allShots
    )
    container.mainContext.insert(allShots1)
    
    let allShots2 = HoopSession(
        date: Date(), // now
        makes: 6,
        length: 95,
        shotType: .allShots
    )
    container.mainContext.insert(allShots2)
    
    let allShots3 = HoopSession(
        date: Date(timeInterval: 86400 * 3, since: .now), // +3 days
        makes: 11,
        length: 160,
        shotType: .allShots
    )
    container.mainContext.insert(allShots3)

    // Return your main view with the model container attached
    return Stats(shotType: $shotType)
        .modelContainer(container)
}
