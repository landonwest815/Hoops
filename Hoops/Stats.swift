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
            VStack(spacing: 10) {
                Spacer()

                GraphTesting(shotType: $shotType)
                
                CourtTesting(type: $shotType)
                    .padding(.bottom)

            }
            .padding(.horizontal)
//            .toolbar() {
//                ToolbarItemGroup(placement: .navigationBarLeading) {
//                    HStack(spacing: 7.5) {
//                        Image(systemName: "chart.bar.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 20, height: 20)
//                            .foregroundStyle(.orange)
//                            .fontWeight(.semibold)
//                            
//                        Text("stats.")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .fontDesign(.rounded)
//                    }
//                }
//            }
           // .navigationTitle("Stats")
        }
    }
}

#Preview {
    Stats()
}
