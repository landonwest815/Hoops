//
//  BasketballCourtView.swift
//  Hoops
//
//  Created by Landon West on 1/21/25.
//


import SwiftUI

struct BasketballCourtView: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Canvas { context, size in
                // Court background
                context.fill(
                    Path { path in
                        path.addRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
                    },
                    with: .color(.white)
                )
                
                // Paint area rectangle
                let paintWidth = width * 0.16
                let paintHeight = height * 0.4
                let paintOriginX = (width - paintWidth) / 2
                let paintOriginY = height * 0.4
                let paintRect = CGRect(x: paintOriginX, y: paintOriginY, width: paintWidth, height: paintHeight)
                
                context.stroke(
                    Path { path in
                        path.addRect(paintRect)
                    },
                    with: .color(.black),
                    lineWidth: 2
                )
                
                // Free-throw semicircle
                let semicircleRadius = paintWidth / 2
                let semicircleCenter = CGPoint(x: width / 2, y: paintOriginY)
                
                context.stroke(
                    Path { path in
                        path.addArc(center: semicircleCenter, radius: semicircleRadius, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true)
                    },
                    with: .color(.black),
                    lineWidth: 2
                )
                
                // Three-point arc
                let threePointRadius = width * 0.45
                let threePointCenter = CGPoint(x: width / 2, y: height)
                
                context.stroke(
                    Path { path in
                        path.addArc(center: threePointCenter, radius: threePointRadius, startAngle: .degrees(22), endAngle: .degrees(158), clockwise: true)
                    },
                    with: .color(.black),
                    lineWidth: 2
                )
                
                // Hoop
                let hoopRadius = width * 0.03
                let hoopCenter = CGPoint(x: width / 2, y: paintOriginY - hoopRadius * 1.5)
                
                context.stroke(
                    Path { path in
                        path.addArc(center: hoopCenter, radius: hoopRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                    },
                    with: .color(.black),
                    lineWidth: 2
                )
                
                // Backboard
                let backboardWidth = paintWidth / 2
                let backboardHeight = 2
                let backboardOrigin = CGPoint(x: width / 2 - backboardWidth / 2, y: paintOriginY - hoopRadius * 2)
                
                context.stroke(
                    Path { path in
                        path.addRect(CGRect(origin: backboardOrigin, size: CGSize(width: backboardWidth, height: backboardHeight)))
                    },
                    with: .color(.black),
                    lineWidth: 2
                )
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct BasketballCourtView_Previews: PreviewProvider {
    static var previews: some View {
        BasketballCourtView()
            .frame(width: 300, height: 300)
    }
}
