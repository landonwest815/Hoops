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
    
    var body: some View {
        
        NavigationStack {
            
            // MARK: - List of Wants
            ZStack {
                GraphTesting()
            }
            .padding()
            .toolbar() {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(.orange)
                }
            }
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    Stats()
}
