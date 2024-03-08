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
    @Query var sessions: [HoopSession]
    
    let dateFormatter = DateFormatter()
    init() {
        dateFormatter.dateFormat = "d MMM"
    }
    
    var body: some View {
        
        ZStack {
            Chart(sessions) {
                LineMark(
//                    x: .value("Month", dateFormatter.string(from: $0.date)),
                    x: .value("Month", $0.date.description),
                    y: .value("Hours of Sunshine", Double($0.makes) / (Double($0.length) / 60.0))
                )
            }
            .frame(height: 300)
        }
        
    }
}

#Preview {
    GraphTesting()
}
