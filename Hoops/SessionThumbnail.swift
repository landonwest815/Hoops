//
//  SessionThumbnail.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import SwiftUI

struct SessionThumbnail: View {
    
    var date: Date
    var makes: Int
    var average: Double
    let dateFormatter = DateFormatter()
    
    init(date: Date, makes: Int, average: Double) {
        self.date = date
        self.makes = makes
        self.average = average
        dateFormatter.dateFormat = "d MMM"
    }
    
    var body: some View {
        
        ZStack {
            HStack(spacing: 0) {
                HStack {
                    Image(systemName: "calendar")
                    Text("\(dateFormatter.string(from: date))")
                        .fontWeight(.heavy)
                    Spacer()
                }
                .fontDesign(.monospaced)
                .frame(width: 100)
                
                Spacer()

                HStack {
                    Image(systemName: "basketball.fill")
                    Text("\(makes)")
                    Spacer()
                }
                .fontWeight(.heavy)
                .fontDesign(.monospaced)
                .frame(width: 70)


                Spacer()
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .fontWeight(.bold)
                    Text("\(String(format: "%.1f", average))/min")
                        .fontWeight(.heavy)
                    Spacer()
                }
                .fontDesign(.monospaced)
                .frame(width: 135)
            }
        }
        .onAppear() {
            
        }
    }
}

#Preview {
    SessionThumbnail(date: Date.now, makes: 200, average: 257.1)
}
