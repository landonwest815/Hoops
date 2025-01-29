//
//  CardView.swift
//  Hoops
//
//  Created by Landon West on 1/28/25.
//

import SwiftUI

struct CardView: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                HabitView(text: "Layups", icon: "basketball.fill", color: .red)
                HabitView(text: "Free Throws", icon: "basketball.fill", color: .blue)
                HabitView(text: "Midrange", icon: "basketball.fill", color: .blue)
            }
            HStack(spacing: 15) {
                HabitView(text: "Threes", icon: "basketball.fill", color: .green)
                HabitView(text: "Deep", icon: "basketball.fill", color: .purple)
                HabitView(text: "Any Shots", icon: "basketball.fill", color: .black)
            }
        }
    }
}

struct HabitView: View {
    var text: String
    var icon: String
    var color: Color

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.white)

                Text(text)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .frame(width: 75, height: 50)
                    .foregroundStyle(.white)
            }
            .frame(width: 107.5, height: 145)
            .background(.ultraThickMaterial)
            .background(.black.opacity(0.75))
            //.background(Color(red: 0.2, green: 0.2, blue: 0.2))
            .cornerRadius(20)
        }
    }
}

#Preview {
    CardView()
}
