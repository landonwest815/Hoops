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
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        HStack {
                            Image(systemName: "ruler")
                            Text("\(shotType.rawValue)")
                                .fontWeight(.heavy)
                            Spacer()
                        }
                        .fontDesign(.monospaced)
                        .frame(width: geometry.size.width / 2)
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "basketball.fill")
                            Text("\(makes)")
                            Spacer()
                        }
                        .fontWeight(.heavy)
                        .fontDesign(.monospaced)
                        .frame(width: geometry.size.width / 2)

                    }
                    
                    HStack(spacing: 0) {
                        HStack {
                            Image(systemName: "clock")
                                .fontWeight(.semibold)
                            if length > 59 {
                                Text("\(length / 60) min")
                                    .fontWeight(.heavy)
                            } else {
                                Text("\(length) sec")
                                    .fontWeight(.heavy)
                            }
                            Spacer()
                        }
                        .fontDesign(.monospaced)
                        .frame(width: geometry.size.width / 2)

                        Spacer()
                        
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .fontWeight(.bold)
                            Text("\(String(format: "%.1f", average))/min")
                                .fontWeight(.heavy)
                            Spacer()
                        }
                        .fontDesign(.monospaced)
                        .frame(width: geometry.size.width / 2)
                    }
                }
            }
        }
    }
}

#Preview {
    SessionThumbnail(date: Date.now, makes: 5, length: 120, average: 2.5, shotType: .freeThrows)
}
