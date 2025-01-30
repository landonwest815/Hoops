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
    var length: Int
    var average: Double
    var shotType: ShotType
    let dateFormatter = DateFormatter()
    
    init(date: Date, makes: Int, length: Int, average: Double, shotType: ShotType) {
        self.date = date
        self.makes = makes
        self.length = length
        self.average = average
        self.shotType = shotType
        dateFormatter.dateFormat = "d MMM"
    }
    
    var body: some View {
            ZStack {
                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        HStack {
                            Image(systemName: "ruler.fill")
                            Text("\(shotType.rawValue)")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .fontDesign(.rounded)
                        //.frame(width: geometry.size.width / 2)
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "basketball.fill")
                            Text("\(makes)")
                            Spacer()
                        }
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        //.frame(width: geometry.size.width / 2)

                    }
                    
                    HStack(spacing: 0) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .fontWeight(.semibold)
                            Text("\(length / 60)m  \(length % 60)s")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .fontDesign(.rounded)
                        //.frame(width: geometry.size.width / 2)

                        Spacer()
                        
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .fontWeight(.semibold)
                            Text("\(String(format: "%.1f", average)) / min")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .fontDesign(.rounded)
                        //.frame(width: geometry.size.width / 2)
                    }
                }
                .padding()
                .frame(height: 75)
                .background(.ultraThinMaterial)
                .cornerRadius(18)
            }
        
    }
}

#Preview {
    SessionThumbnail(date: Date.now, makes: 5, length: 120, average: 2.5, shotType: .freeThrows)
}
