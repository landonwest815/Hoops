//
//  CourtTesting.swift
//  Hoops
//
//  Created by Landon West on 3/9/24.
//

import SwiftUI

struct CourtTesting: View {
    var body: some View {
            ZStack {
                GeometryReader { geometry in
                // Court background
                //Rectangle()
                    //.fill(Color.black)
                
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
                    path.move(to: CGPoint(x: geometry.size.width / 2.8, y: 10))
                    path.addLine(to: CGPoint(x: geometry.size.width / 2.8, y: geometry.size.height / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width / (2.8/1.8), y: geometry.size.height / 2))
                    path.addLine(to: CGPoint(x: geometry.size.width / (2.8/1.8), y: 10))
                }
                .stroke(Color.white, lineWidth: 3)
                
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 15.1, y: 10))
                    path.addLine(to: CGPoint(x: geometry.size.width / 15.1, y: geometry.size.height / 3.8))
                }
                .stroke(Color.white, lineWidth: 3)
                
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: 10))
                    path.addLine(to: CGPoint(x: geometry.size.width / (15.1/14.1), y: geometry.size.height / 3.8))
                }
                .stroke(Color.white, lineWidth: 3)
                    
                // 3 Right
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2.25))
                    path.addLine(to: CGPoint(x: geometry.size.width / 1.1, y: geometry.size.height / 2.5))
                }
                .stroke(Color.white, lineWidth: 1)
                   
                // 3 Top Right
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 1.1, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width / 1.35, y: geometry.size.height / 1.5))
                }
                .stroke(Color.white, lineWidth: 1)
                    
                // 3 Top Left
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width / (1.35/0.35), y: geometry.size.height / 1.5))
                }
                .stroke(Color.white, lineWidth: 1)
                    
                // 3 Left
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height / 2.25))
                    path.addLine(to: CGPoint(x: geometry.size.width / 11, y: geometry.size.height / 2.5))
                }
                .stroke(Color.white, lineWidth: 1)
                   
                // Mid Left
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 6.5, y: geometry.size.height / 1.85))
                    path.addLine(to: CGPoint(x: geometry.size.width / 2.8, y: geometry.size.height / 3.5))
                }
                .stroke(Color.white, lineWidth: 1)
                    
                // Mid Right
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / (6.5/5.5), y: geometry.size.height / 1.85))
                    path.addLine(to: CGPoint(x: geometry.size.width / (2.8/1.8), y: geometry.size.height / 3.5))
                }
                .stroke(Color.white, lineWidth: 1)
                    
                // Mid Right
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 1.325))
                    path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2.75))
                }
                .stroke(Color.white, lineWidth: 1)
                    
                // Layup Arc
                Path { path in
                    path.addArc(center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 7.25), radius: geometry.size.width / 5.5, startAngle: .degrees(175), endAngle: .degrees(5), clockwise: true)
                }
                .stroke(Color.white, lineWidth: 1)
                    
                // Layup Left
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / 3.135, y: geometry.size.height / 6.25))
                    path.addLine(to: CGPoint(x: geometry.size.width / 3.135, y: 10))
                }
                .stroke(Color.white, lineWidth: 1)
                    
                // Layup Left
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width / (3.135/2.135), y: geometry.size.height / 6.25))
                    path.addLine(to: CGPoint(x: geometry.size.width / (3.135/2.135), y: 10))
                }
                .stroke(Color.white, lineWidth: 1)
            }
        }
            //.frame(height: 300)
            .aspectRatio(1.25, contentMode: .fit)
    }
}

#Preview {
    CourtTesting()
}
