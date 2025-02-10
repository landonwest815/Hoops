//
//  CardView.swift
//  Hoops
//
//  Created by Landon West on 1/28/25.
//

import SwiftUI

struct CardView: View {
    var body: some View {
        VStack(spacing: 10) {
            
            HStack {
                Text("Shot Selection")
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .font(.title3)
                    .foregroundStyle(.gray)
                    .padding(.leading, 2.5)
                
                Spacer()
            }
            .padding(.top)
            
            HStack(spacing: 10) {
                HabitView(text: "Layups", icon: "basketball.fill", color: .red, shotType: .layups)
                HabitView(text: "Free Throws", icon: "basketball.fill", color: .blue, shotType: .freeThrows)
                HabitView(text: "Midrange", icon: "basketball.fill", color: .blue, shotType: .midrange)
            }
            HStack(spacing: 10) {
                HabitView(text: "Threes", icon: "basketball.fill", color: .green, shotType: .threePointers)
                HabitView(text: "Deep", icon: "basketball.fill", color: .purple, shotType: .deep)
                HabitView(text: "Any Shots", icon: "basketball.fill", color: .orange, shotType: .allShots)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct HabitView: View {
    var text: String
    var icon: String
    var color: Color
    var shotType: ShotType

    var body: some View {
            
        Button {
            
        } label: {
            ZStack {
                
                Image(systemName: "figure.basketball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(color.opacity(0.2))
                    .frame(height: 40)
                    .offset(x: -50, y: 20)
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                    .rotationEffect(.degrees(10))
                
                Image(systemName: "basketball.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(color.opacity(0.2))
                    .frame(height: 70)
                    .offset(x: 17.5, y: 52.5)
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 2)
                        .frame(height: 100)
                        .offset(x: -15, y: -77)
                    
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 2)
                        .frame(height: 30)
                        .offset(x: -15, y: -47.5)
                }
                .rotationEffect(.degrees(-10))
                .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                Text("\(getShotPoints(for: shotType)) pts")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .offset(x: 35, y: -22.5)
                    .rotationEffect(.degrees(12))
                    .foregroundStyle(color.opacity(0.2))
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                
                Text(text)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .frame(width: 75, height: 50)
                    .foregroundStyle(color)
            }
            .frame(maxWidth: .infinity, maxHeight: 75)
            .background(.ultraThinMaterial)
            .background(color.opacity(0.33))
            .cornerRadius(20)
        }

    }
}

#Preview {
    CardView()
}
