//
//  CourtTesting.swift
//  Hoops
//
//  Created by Landon West on 3/9/24.
//

import SwiftUI

struct CourtTesting: View {
    
    @State private var showCourt = true
    @Binding var type: ShotType
    
    var body: some View {
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
                        .opacity((type == .midrange || type == .allShots || type == .freeThrows ) ? 1.0 : 0.1)
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
                                
                                path.move(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2.35))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2.5), radius: geometry.size.width / 1.75, startAngle: .degrees(30), endAngle: .degrees(150), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: 0, y: geometry.size.height / 2.35))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4), radius: geometry.size.width / 1.93, startAngle: .degrees(165), endAngle: .degrees(15), clockwise: true)
                                
                            }
                            .fill(Color.purple.opacity(0.5))
                            
                            Path { path in
                                
                                path.move(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2.35))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2.5), radius: geometry.size.width / 1.75, startAngle: .degrees(30), endAngle: .degrees(150), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: 0, y: geometry.size.height / 2.35))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4), radius: geometry.size.width / 1.93, startAngle: .degrees(165), endAngle: .degrees(15), clockwise: true)
                                
                            }
                            .stroke(Color.purple, lineWidth: 2.5)
                        }
                        .opacity((type == .deep || type == .allShots ) ? 1.0 : 0.1)
                        
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
                                
                                path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4), radius: geometry.size.width / 1.93, startAngle: .degrees(15), endAngle: .degrees(165), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: 0, y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                            }
                            .fill(Color.green.opacity(0.5))
                            
                            Path { path in
                                
                                path.move(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
                                
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4), radius: geometry.size.width / 1.93, startAngle: .degrees(15), endAngle: .degrees(165), clockwise: false)
                                
                                path.addLine(to: CGPoint(x: 0, y: 0))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                                
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
                    .opacity((type == .layups || type == .allShots ) ? 1.0 : 0.1)
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
            .padding(10)
            //.frame(height: 300)
            .aspectRatio(1.25, contentMode: .fit)
    }
}

#Preview {
    @Previewable @State var shotType: ShotType = .midrange
    return CourtTesting(type: $shotType)
}
