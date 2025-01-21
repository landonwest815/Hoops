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
    @State private var shotType: ShotType = .allShots
    
    var body: some View {
        
        NavigationStack {
            
            // MARK: - List of Wants
            VStack(spacing: 30) {
                GraphTesting(shotType: $shotType)
                    .frame(height: 250)

                CourtTesting(type: $shotType)
                    .offset(y: 0)
                
                Spacer()
                
            }
            .padding()
            .toolbar() {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(color)
                }
            }
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    Stats()
}
