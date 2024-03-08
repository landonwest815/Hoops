//
//  GraphTesting.swift
//  Hoops
//
//  Created by Landon West on 3/7/24.
//

import SwiftUI
import Charts

struct GraphTesting: View {
    
    struct HoopSession: Identifiable {
        var id = UUID()
        var date: Date
        var averageMakes: Double
        var dayMonthString: String {
                let dateFormatter = DateFormatter()
                // Choose the desired format here:
                dateFormatter.dateFormat = "MM/dd" // for numeric month and day, e.g., "03/04"
                // Or
                // dateFormatter.dateFormat = "d MMM" // for day and abbreviated month, e.g., "4 Mar"
                return dateFormatter.string(from: date)
            }
    
        init(date: Date, averageMakes: Double) {
            self.date = date
            self.averageMakes = averageMakes
        }
    }
    
    
    var data: [HoopSession] = [
        HoopSession(date: Date(timeInterval: -86400, since: Date.now), averageMakes: 2.7),
        HoopSession(date: Date.now, averageMakes: 4.1),
        HoopSession(date: Date(timeInterval: 86400, since: Date.now), averageMakes: 3.6),
        HoopSession(date: Date(timeInterval: 3 * 86400, since: Date.now), averageMakes: 3.3),
        HoopSession(date: Date(timeInterval: 6 * 86400, since: Date.now), averageMakes: 4.2)
    ]
    
    
    var body: some View {
        
        ZStack {
            Chart(data) {
                LineMark(
                    x: .value("Month", $0.dayMonthString),
                    y: .value("Hours of Sunshine", $0.averageMakes)
                )
            }
            .frame(height: 300)
        }
        
    }
}

#Preview {
    GraphTesting()
}
