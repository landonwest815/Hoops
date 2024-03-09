//
//  CourtTesting.swift
//  Hoops
//
//  Created by Landon West on 3/9/24.
//

import SwiftUI

struct CourtTesting: View {
    
    @State private var showCourt = true
    @State private var type: ShotType? = .threePointers
    
    var body: some View {
            ZStack {
                GeometryReader { geometry in
                    // Court background
                    //Rectangle()
                    //.fill(Color.black)
                    
                    if showCourt {
                        // Draw the center circle
                        Path { path in
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2.75), radius: geometry.size.width / 7, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                        }
                        .stroke(Color.white, lineWidth: 5)
                        .offset(x: 0, y: geometry.size.height / 8)
                        
                        // Three-point line
                        Path { path in
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                        }
                        .stroke(Color.white, lineWidth: 5)
                        
                        // Free-throw lane
                        Path { path in
                            path.move(to: CGPoint(x: geometry.size.width / 2.8, y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width / 2.8, y: geometry.size.height / 2))
                            path.addLine(to: CGPoint(x: geometry.size.width / (2.8/1.8), y: geometry.size.height / 2))
                            path.addLine(to: CGPoint(x: geometry.size.width / (2.8/1.8), y: 0))
                        }
                        .stroke(Color.white, lineWidth: 5)
                        
                        Path { path in
                            path.move(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: geometry.size.height / 3.8))
                        }
                        .stroke(Color.white, lineWidth: 5)
                        
                        Path { path in
                            path.move(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: geometry.size.height / 3.8))
                        }
                        .stroke(Color.white, lineWidth: 5)
                        
//                        // 3 Right
//                        Path { path in
//                            path.move(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2.25))
//                            path.addLine(to: CGPoint(x: geometry.size.width / 1.1, y: geometry.size.height / 2.5))
//                        }
//                        .stroke(Color.white, lineWidth: 1)
//                        
//                        // 3 Top Right
//                        Path { path in
//                            path.move(to: CGPoint(x: geometry.size.width / 1.1, y: geometry.size.height))
//                            path.addLine(to: CGPoint(x: geometry.size.width / 1.35, y: geometry.size.height / 1.5))
//                        }
//                        .stroke(Color.white, lineWidth: 1)
//                        
//                        // 3 Top Left
//                        Path { path in
//                            path.move(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height))
//                            path.addLine(to: CGPoint(x: geometry.size.width / (1.35/0.35), y: geometry.size.height / 1.5))
//                        }
//                        .stroke(Color.white, lineWidth: 1)
//                        
//                        // 3 Left
//                        Path { path in
//                            path.move(to: CGPoint(x: 0, y: geometry.size.height / 2.25))
//                            path.addLine(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height / 2.5))
//                        }
//                        .stroke(Color.white, lineWidth: 1)
//                        
//                        
//                        // Mid Right
//                        Path { path in
//                            path.move(to: CGPoint(x: geometry.size.width / (6.5/5.5), y: geometry.size.height / 1.85))
//                            path.addLine(to: CGPoint(x: geometry.size.width / (2.8/1.8), y: geometry.size.height / 3.5))
//                        }
//                        .stroke(Color.white, lineWidth: 1)
//                        
//                        // Mid Center
//                        Path { path in
//                            path.move(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 1.325))
//                            path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2.75))
//                        }
//                        .stroke(Color.white, lineWidth: 1)
//                        
//                        // Mid Left
//                        Path { path in
//                            path.move(to: CGPoint(x: geometry.size.width / (6.5), y: geometry.size.height / 1.85))
//                            path.addLine(to: CGPoint(x: geometry.size.width / (2.8), y: geometry.size.height / 3.5))
//                        }
//                        .stroke(Color.white, lineWidth: 1)
                        
                    }
                    
                    
                    
                    // MID LEFT
                    if (type == .midrange || type == .allShots) {
                        ZStack {
                            Path { path in
                                // Start with the first segment
                                path.move(to: CGPoint(x: geometry.size.width / 15, y: 0))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / 3.135, y: 0))
                                
                                // Move down to the arc start without drawing (to keep the shape connected)
                                path.addLine(to: CGPoint(x: geometry.size.width / 3.135, y: geometry.size.height / 6.25))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(175), endAngle: .degrees(141), clockwise: true)
                                
                                // Connect to the second arc's start with a line implicitly by arc ending
                                // Second arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(143), endAngle: .degrees(175), clockwise: false)
                                
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
                                
                                // Move down to the arc start without drawing
                                path.addLine(to: CGPoint(x: geometry.size.width / 3.135, y: geometry.size.height / 6.25))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(175), endAngle: .degrees(141), clockwise: true)
                                
                                // Second arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(143), endAngle: .degrees(175), clockwise: false)
                                
                                // Connect back to the starting point with lines
                                path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: geometry.size.height / 3.8))
                                path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: 0))
                                path.addLine(to: CGPoint(x: geometry.size.width / 15, y: 0)) // Close the path explicitly
                                
                            }
                            .stroke(Color.blue, lineWidth: 2.5)
                        }
                    }
                    
                if (type == .midrange || type == .allShots) {
                    ZStack {
                        Path { path in
                            // Start with the first segment
                            path.move(to: CGPoint(x: geometry.size.width / (6.55), y: geometry.size.height / 1.86))
                            
                            // Connect to the top horizontal line
                            path.addLine(to: CGPoint(x: geometry.size.width / (2.79), y: geometry.size.height / 3.525))
                            
                            // First arc
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(140), endAngle: .degrees(90), clockwise: true)
                            
                            // Connect to the second arc's start with a line implicitly by arc ending
                            // Second arc
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(90), endAngle: .degrees(143), clockwise: false)
                            
                        }
                        .fill(Color.blue.opacity(0.5))
                        
                        Path { path in
                            // Start with the first segment
                            path.move(to: CGPoint(x: geometry.size.width / (6.55), y: geometry.size.height / 1.86))
                            
                            // Connect to the top horizontal line
                            path.addLine(to: CGPoint(x: geometry.size.width / (2.79), y: geometry.size.height / 3.525))
                            
                            // First arc
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(140), endAngle: .degrees(90), clockwise: true)
                            
                            // Connect to the second arc's start with a line implicitly by arc ending
                            // Second arc
                            path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(90), endAngle: .degrees(143), clockwise: false)
                            
                        }
                        .stroke(Color.blue, lineWidth: 2.5)
                    }
                }
                    
                    
                    if (type == .midrange || type == .allShots) {
                        // MID TOP RIGHT
                        ZStack {
                            Path { path in
                                // Start with the first segment
                                path.move(to: CGPoint(x: geometry.size.width / (6.55/5.55), y: geometry.size.height / 1.86))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / (2.79/1.79), y: geometry.size.height / 3.525))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(40), endAngle: .degrees(90), clockwise: false)
                                
                                // Connect to the second arc's start with a line implicitly by arc ending
                                // Second arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(90), endAngle: .degrees(37), clockwise: true)
                                
                            }
                            .fill(Color.blue.opacity(0.5))
                            
                            Path { path in
                                // Start with the first segment
                                path.move(to: CGPoint(x: geometry.size.width / (6.55/5.55), y: geometry.size.height / 1.86))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / (2.79/1.79), y: geometry.size.height / 3.525))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(40), endAngle: .degrees(90), clockwise: false)
                                
                                // Connect to the second arc's start with a line implicitly by arc ending
                                // Second arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(90), endAngle: .degrees(37), clockwise: true)
                                
                            }
                            .stroke(Color.blue, lineWidth: 2.5)
                        }
                    }
                    
                    
                    
                    
                    if (type == .threePointers || type == .allShots) {
                        ZStack {
                            
                            Path { path in
                                
                                // Connect to the top horizontal line
                                path.move(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height))
                                path.addLine(to: CGPoint(x: geometry.size.width / (1.35/0.35), y: geometry.size.height))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (1.1), y: geometry.size.height))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / (1.35), y: geometry.size.height / 1.5))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(56.5), endAngle: .degrees(123.5), clockwise: false)
                            }
                            .fill(Color.green.opacity(0.5))
                            
                            Path { path in
                                
                                // Connect to the top horizontal line
                                path.move(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height))
                                path.addLine(to: CGPoint(x: geometry.size.width / (1.35/0.35), y: geometry.size.height))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width / (1.1), y: geometry.size.height))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / (1.35), y: geometry.size.height / 1.5))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(58.5), endAngle: .degrees(123.5), clockwise: false)
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height))
                            }
                            .stroke(Color.green, lineWidth: 2.5)
                        }
                    }
                    
                    if (type == .midrange || type == .allShots) {
                        // MID RIGHT
                        ZStack {
                            Path { path in
                                // Start with the first segment
                                path.move(to: CGPoint(x: geometry.size.width / (15/14), y: 0))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / (3.135/2.135), y: 0))
                                
                                // Move down to the arc start without drawing (to keep the shape connected)
                                path.addLine(to: CGPoint(x: geometry.size.width / (3.135/2.135), y: geometry.size.height / 6.25))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(5), endAngle: .degrees(39), clockwise: false)
                                
                                // Connect to the second arc's start with a line implicitly by arc ending
                                // Second arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(37), endAngle: .degrees(5), clockwise: true)
                                
                                // Connect back to the starting point with lines, closing the loop
                                // Assuming the path needs to close back to the first line segment
                                // This part might need adjustment based on your exact shape requirements
                                path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: geometry.size.height / 3.8))
                                path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: 0))
                                path.addLine(to: CGPoint(x: geometry.size.width / 15, y: 0)) // Close the path explicitly
                                
                            }
                            .fill(Color.blue.opacity(0.5)) // Fill color inside the shape
                            
                            Path { path in
                                // Start with the first segment
                                path.move(to: CGPoint(x: geometry.size.width / (15/14), y: 0))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / (3.135/2.135), y: 0))
                                
                                // Move down to the arc start without drawing (to keep the shape connected)
                                path.addLine(to: CGPoint(x: geometry.size.width / (3.135/2.135), y: geometry.size.height / 6.25))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(5), endAngle: .degrees(39), clockwise: false)
                                
                                // Connect to the second arc's start with a line implicitly by arc ending
                                // Second arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(37), endAngle: .degrees(5), clockwise: true)
                                
                                // Connect back to the starting point with lines, closing the loop
                                // Assuming the path needs to close back to the first line segment
                                // This part might need adjustment based on your exact shape requirements
                                path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: geometry.size.height / 3.8))
                                path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: 0))
                                path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: 0)) // Close the path explicitly
                                
                            }
                            .stroke(Color.blue, lineWidth: 2.5)
                        }
                    }
                    
                    if (type == .deep || type == .allShots) {
                        
                        ZStack {
                            
                            Path { path in
                                
                                // Connect to the top horizontal line
                                path.move(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height))
                                path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                                
                                path.addLine(to: CGPoint(x: 0, y: geometry.size.height / 2.25))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / (11), y: geometry.size.height / 2.5))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(160), endAngle: .degrees(123.5), clockwise: true)
                            }
                            .fill(Color.purple.opacity(0.5))
                            
                            Path { path in
                                
                                // Connect to the top horizontal line
                                path.move(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height))
                                path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                                
                                path.addLine(to: CGPoint(x: 0, y: geometry.size.height / 2.25))
                                path.addLine(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height / 2.5))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(160), endAngle: .degrees(123.5), clockwise: true)
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height))
                            }
                            .stroke(Color.purple, lineWidth: 2.5)
                        }
                        
                        
                        ZStack {
                            
                            Path { path in
                                
                                // Connect to the top horizontal line
                                path.move(to: CGPoint(x: geometry.size.width / (11/10), y: geometry.size.height))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2.25))
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / (11/10), y: geometry.size.height / 2.5))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(30), endAngle: .degrees(56), clockwise: false)
                            }
                            .fill(Color.purple.opacity(0.5))
                            
                            Path { path in
                                
                                // Connect to the top horizontal line
                                path.move(to: CGPoint(x: geometry.size.width / (11/10), y: geometry.size.height))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                                
                                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2.25))
                                path.addLine(to: CGPoint(x: geometry.size.width / (11/10), y: geometry.size.height / 2.5))
                                
                                // First arc
                                path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 4.75), radius: geometry.size.width / 2.3, startAngle: .degrees(30), endAngle: .degrees(56), clockwise: false)
                                
                                // Connect to the top horizontal line
                                path.addLine(to: CGPoint(x: geometry.size.width / (11/10), y: geometry.size.height))
                            }
                            .stroke(Color.purple, lineWidth: 2.5)
                        }
                        
                    }

            // LAYUPS
                    if (type == .layups || type == .allShots) {
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
                    }
            }
        }
            .padding(10)
            //.frame(height: 300)
            .aspectRatio(1.25, contentMode: .fit)
    }
}

#Preview {
    CourtTesting()
}
