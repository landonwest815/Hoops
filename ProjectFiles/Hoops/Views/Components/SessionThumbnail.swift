//
//  SessionThumbnail.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import SwiftUI

struct SessionThumbnail: View {
    let date: Date
    let makes: Int
    let length: Int
    let average: Double
    let shotType: ShotType

    private let dateFormatter: DateFormatter

    var iconColor: Color {
        switch shotType {
        case .freeThrows, .midrange: return .blue
        case .layups:                return .red
        case .threePointers:         return .green
        case .deep:                  return .purple
        case .allShots:              return .orange
        }
    }

    init(date: Date, makes: Int, length: Int, average: Double, shotType: ShotType) {
        self.date = date
        self.makes = makes
        self.length = length
        self.average = average
        self.shotType = shotType
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        self.dateFormatter = formatter
    }

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ZStack {
                    Image(systemName: "figure.basketball")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(iconColor.opacity(0.2))
                        .frame(height: 40)
                        .offset(x: -40, y: 20)
                        .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)
                        .rotationEffect(.degrees(10))

                    Image(systemName: "basketball.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(iconColor.opacity(0.2))
                        .frame(height: 70)
                        .offset(x: 17.5, y: 52.5)
                        .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)

                    ZStack {
                        Circle()
                            .stroke(iconColor.opacity(0.2), lineWidth: 2)
                            .frame(height: 100)
                            .offset(x: -20, y: -77)
                        Circle()
                            .stroke(iconColor.opacity(0.2), lineWidth: 2)
                            .frame(height: 30)
                            .offset(x: -20, y: -47.5)
                    }
                    .rotationEffect(.degrees(-15))
                    .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)

                    Text("\(getShotPoints(for: shotType)) pts")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .offset(x: 20, y: -22.5)
                        .rotationEffect(.degrees(12))
                        .foregroundStyle(iconColor.opacity(0.2))
                        .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)

                    HStack(spacing: 0) {
                        Text("\(shotType.rawValue)")
                            .fontWeight(.semibold)
                            .font(.headline)
                            .frame(width: 80)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .foregroundStyle(iconColor)
                            .shadow(color: iconColor.opacity(0.5), radius: 3)
                            .padding(.horizontal, 10)
                        
                        Divider()
                            .frame(width: 1)
                            .overlay(iconColor.opacity(0.5))
                            .shadow(color: iconColor.opacity(0.4), radius: 5, x: 1.5)
                            .shadow(color: iconColor.opacity(0.3), radius: 4, x: 1.5)
                            .shadow(color: iconColor.opacity(0.2), radius: 3, x: 1.5)
                    }
                }
                .background(iconColor.opacity(0.33))

                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        Spacer()

                        VStack(alignment: .leading, spacing: 5) {
                            Text("Makes")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            Text("\(makes)")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: 60)

                        Spacer()

                        VStack(alignment: .leading, spacing: 5) {
                            Text("Length")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            Text("\(length / 60)m \(length % 60)s")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)

                        Spacer()

                        VStack(alignment: .leading, spacing: 5) {
                            Text("Average")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            HStack(spacing: 2.5) {
                                Text(String(format: "%.1f", average))
                                    .foregroundStyle(.white)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("/ min")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .offset(y: 2)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        Spacer()
                    }
                }
            }
            .frame(height: 75)
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(.gray.opacity(0.25))
            )
            .padding(1)
        }
        .transition(.opacity)
    }
}

func getShotPoints(for shotType: ShotType) -> String {
    switch shotType {
    case .layups, .midrange, .freeThrows:
        return "+2"
    case .threePointers, .deep:
        return "+3"
    case .allShots:
        return "+"
    }
}

struct PlaceholderThumbnail: View {
    let prompt: String

    var body: some View {
        ZStack {
            HStack {
                Text(prompt)
                    .foregroundStyle(.gray.opacity(0.25))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
            }
            .frame(height: 72.5)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [7.5, 7.5]))
                    .foregroundColor(.gray.opacity(0.25))
            )
            .padding(2)
        }
    }
}

#Preview {
    VStack(spacing: 25) {
        SessionThumbnail(date: Date.now, makes: 125, length: 300, average: 2.3, shotType: .deep)
        PlaceholderThumbnail(prompt: "Run some Drills!")
    }
}
