//
//  CourtTesting.swift
//  Hoops
//
//  Created by Landon West on 3/9/24.
//

import SwiftUI
import SwiftData

struct CourtTesting: View {
    
    @Query(sort: \HoopSession.date, order: .reverse) var sessions: [HoopSession]
    @State private var showCourt = true
    @Binding var type: ShotType
    
    var body: some View {
        VStack(spacing: 15) {
            
            HStack(spacing: 10) {
                
                VStack {
                    Text("Shot Type")
                        .font(.caption)
                    
                    Text(type.rawValue)
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
                    Text("Time")
                        .font(.caption)
                    
                    Text(formattedTotalTime)
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
            
            ZStack {
                GeometryReader { geometry in
                    
                    if showCourt {
                        // Draw the center circle
                        Path { path in
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2.75), radius: geometry.size.width / 7, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                        }
                        .stroke(Color.white, lineWidth: 3)
                        .offset(x: 0, y: geometry.size.height / 8)
                        
                        // Three-point line
                        Path { path in
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                        }
                        .stroke(Color.white, lineWidth: 3)
                        
                        // Free-throw lane
                        Path { path in
                            path.move(to: CGPoint(x: geometry.size.width / 2.8, y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width / 2.8, y: geometry.size.height / 2))
                            path.addLine(to: CGPoint(x: geometry.size.width / (2.8/1.8), y: geometry.size.height / 2))
                            path.addLine(to: CGPoint(x: geometry.size.width / (2.8/1.8), y: 0))
                        }
                        .stroke(Color.white, lineWidth: 3)
                        
                        Path { path in
                            path.move(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: geometry.size.height / 3.8))
                        }
                        .stroke(Color.white, lineWidth: 3)
                        
                        Path { path in
                            path.move(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: geometry.size.height / 3.8))
                        }
                        .stroke(Color.white, lineWidth: 3)
                    }
                    
                    ZStack {
                        ZStack {
                            Path { path in
                                // Start with the first segment
                                path.move(to: CGPoint(x: geometry.size.width / 15, y: 0))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / 3.135, y: 0))
                                
                                // Move down to the arc start without drawing (to keep the shape connected)
                                path.addLine(to: CGPoint(x: geometry.size.width / 3.135, y: geometry.size.height / 6.25))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (3.135/2.135), y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (15/14), y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (15/14), y: geometry.size.height / 3.8))
                                
                                
                                // Connect to the second arc's start with a line implicitly by arc ending
                                // Second arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(5), endAngle: .degrees(175), clockwise: false)
                                
                                // Connect back to the starting point with lines, closing the loop
                                // Assuming the path needs to close back to the first line segment
                                // This part might need adjustment based on your exact shape requirements
                                path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: geometry.size.height / 3.8))
                                path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                                path.addLine(to: CGPoint(x: geometry.size.width / 15, y: 0)) // Close the path explicitly
                                
                            }
                            .fill(Color.blue.opacity(0.5)) // Fill color inside the shape
                            
                            Path { path in
                                // Repeat the above for the stroke, or ideally, use a function to generate the path to avoid duplication
                                // Start with the first segment
                                path.move(to: CGPoint(x: geometry.size.width / 15, y: 0))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / 3.135, y: 0))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (3.135/2.135), y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (15/14), y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (15/14), y: geometry.size.height / 3.8))
                                
                                
                                // Second arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(5), endAngle: .degrees(175), clockwise: false)
                                
                                // Connect back to the starting point with lines
                                path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: geometry.size.height / 3.8))
                                path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                                path.addLine(to: CGPoint(x: geometry.size.width / 15, y: 0)) // Close the path explicitly
                                
                            }
                            .stroke(Color.blue, lineWidth: 2.5)
                        }
                        .opacity((type == .midrange || type == .freeThrows || type == .allShots) ? 1.0 : 0.1)
                    }
                    .onTapGesture {
                        withAnimation {
                            if type == .midrange {
                                type = .allShots
                            } else {
                                type = .midrange
                            }
                        }
                    }
                    
                    
                    ZStack {
                        ZStack {
                            
                            Path { path in
                                
                                path.move(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2.2))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.95))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width - geometry.size.width * 0.05, y: geometry.size.height - geometry.size.width * 0.05), radius: geometry.size.width * 0.05, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: geometry.size.height * 0.05, y: geometry.size.height))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width * 0.05, y: geometry.size.height - geometry.size.width * 0.05), radius: geometry.size.width * 0.05, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: 0, y: geometry.size.height / 2.2))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 3.33), radius: geometry.size.width / 1.93, startAngle: .degrees(165), endAngle: .degrees(15), clockwise: true)
                                
                            }
                            .fill(Color.purple.opacity(0.5))
                            
                            Path { path in
                                
                                path.move(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2.2))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.95))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width - geometry.size.width * 0.05, y: geometry.size.height - geometry.size.width * 0.05), radius: geometry.size.width * 0.05, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: geometry.size.height * 0.05, y: geometry.size.height))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width * 0.05, y: geometry.size.height - geometry.size.width * 0.05), radius: geometry.size.width * 0.05, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: 0, y: geometry.size.height / 2.2))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 3.33), radius: geometry.size.width / 1.93, startAngle: .degrees(165), endAngle: .degrees(15), clockwise: true)
                                
                            }
                            .stroke(Color.purple, lineWidth: 2.5)
                        }
                        .opacity((type == .deep || type == .allShots) ? 1.0 : 0.1)
                        
                    }
                    .onTapGesture {
                        withAnimation {
                            if type == .deep {
                                type = .allShots
                            } else {
                                type = .deep
                            }
                        }
                    }
                    
                    
                    ZStack {
                        ZStack {
                            Path { path in
                                
                                path.move(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width * 0.95, y: 0))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width - geometry.size.width * 0.05, y: geometry.size.width * 0.05), radius: geometry.size.width * 0.05, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 3.33), radius: geometry.size.width / 1.93, startAngle: .degrees(15), endAngle: .degrees(165), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: 0, y: 0))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width * 0.05, y: geometry.size.width * 0.05), radius: geometry.size.width * 0.05, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: geometry.size.width * 0.05, y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / 14.5, y: 0))
                            }
                            .fill(Color.green.opacity(0.5))
                            
                            Path { path in
                                
                                path.move(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width * 0.95, y: 0))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width - geometry.size.width * 0.05, y: geometry.size.width * 0.05), radius: geometry.size.width * 0.05, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 3.33), radius: geometry.size.width / 1.93, startAngle: .degrees(15), endAngle: .degrees(165), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: 0, y: geometry.size.width * 0.05))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width * 0.05, y: geometry.size.width * 0.05), radius: geometry.size.width * 0.05, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: geometry.size.width * 0.05, y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / 14.5, y: 0))
                                
                            }
                            .stroke(Color.green, lineWidth: 2.5)
                        }
                        .opacity((type == .threePointers || type == .allShots) ? 1.0 : 0.1)
                        
                    }
                    .onTapGesture {
                        withAnimation {
                            if type == .threePointers {
                                type = .allShots
                            } else {
                                type = .threePointers
                            }
                        }
                    }
                    
                    // LAYUPS
                    ZStack {
                        ZStack {
                            // First, draw the path for the fill
                            Path { path in
                                // Start from the left bottom point of the layup area
                                path.move(to: CGPoint(x: geometry.size.width / 3.135, y: 0))
                                
                                // Draw the line up to the left arc start
                                path.addLine(to: CGPoint(x: geometry.size.width / 3.135, y: geometry.size.height / 6.25))
                                
                                // Draw the arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                                
                                // Draw the line down to the right bottom point of the layup area
                                path.addLine(to: CGPoint(x: geometry.size.width / (3.135/2.135), y: 0))
                                
                                // Close the path
                                path.closeSubpath()
                            }
                            .fill(Color.red.opacity(0.5)) // Use the color you want for the fill
                            
                            // Then, draw the path for the stroke
                            Path { path in
                                // Start from the left bottom point of the layup area
                                path.move(to: CGPoint(x: geometry.size.width / 3.135, y: 0))
                                
                                // Draw the line up to the left arc start
                                path.addLine(to: CGPoint(x: geometry.size.width / 3.135, y: geometry.size.height / 6.25))
                                
                                // Draw the arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                                
                                // Draw the line down to the right bottom point of the layup area
                                path.addLine(to: CGPoint(x: geometry.size.width / (3.135/2.135), y: 0))
                                
                                // Draw the line to close the shape back to the starting point
                                path.addLine(to: CGPoint(x: geometry.size.width / 3.135, y: 0))
                            }
                            .stroke(Color.red, lineWidth: 2.5) // Use the color and line width you want for the stroke
                        }
                        .opacity((type == .layups || type == .allShots) ? 1.0 : 0.1)
                    }
                    .onTapGesture {
                        withAnimation {
                            if type == .layups {
                                type = .allShots
                            } else {
                                type = .layups
                            }
                        }
                    }
                    
                    
                }
            }
            .aspectRatio(1.15, contentMode: .fit)
        }
        .padding(.horizontal, 5)
    }
    
    // Computed property for total makes
    private var totalMakes: Int {
        sessions
            .filter { $0.shotType == type }
            .reduce(0) { $0 + $1.makes }
    }
    
    // Computed property for formatted total time
    private var formattedTotalTime: String {
        let totalSeconds = sessions
            .filter { $0.shotType == type }
            .reduce(0) { $0 + $1.length }
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        return "\(hours)h \(minutes)m"
    }
    
}

#Preview {
    @Previewable @State var shotType: ShotType = .allShots
    return CourtTesting(type: $shotType)
}
