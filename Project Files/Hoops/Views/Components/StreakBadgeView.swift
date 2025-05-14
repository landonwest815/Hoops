//
//  StreakBadgeView.swift
//  Hoops
//
//  Created by Landon West on 5/13/25.
//


import SwiftUI

struct StreakBadgeView: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 5) {
            ZStack {
                Image(systemName: "flame.fill")
                    .resizable()
                    .frame(width: 18, height: 20)
                    .foregroundStyle(.red)

                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 8, height: 10)
                    .offset(y: 3)
                    .foregroundStyle(.red)

                Image(systemName: "flame.fill")
                    .resizable()
                    .frame(width: 9, height: 11)
                    .offset(y: 2.5)
                    .foregroundStyle(.orange)
            }

            Text("\(streak)")
                .font(.headline)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
}
