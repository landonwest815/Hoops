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
    @Binding var selectedGraph: GraphType
    
    var body: some View {
        
        NavigationStack {
            
            // MARK: - List of Wants
            VStack(spacing: 10) {
                
                
                
                //StatCards(type: $shotType)
                
                GraphTesting(shotType: $shotType)
                
                Text(shotType.rawValue)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .font(.title3)
                    .contentTransition(.numericText())
                    .padding(.top)
                
                CourtTesting(type: $shotType)
                    .frame(width: 300)
                    .padding(.bottom)
                    
                
            }
            .padding(.horizontal)
        }
//        .onDisappear() {
//            withAnimation {
//                selectedGraph = .none
//            }
//        }
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
    @Previewable @State var selectedGraph = GraphType.none
    
    return Stats(shotType: $shotType, selectedGraph: $selectedGraph)
        .modelContainer(HoopSession.preview)
}
