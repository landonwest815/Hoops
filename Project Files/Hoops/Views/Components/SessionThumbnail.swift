//
//  SessionThumbnail.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import SwiftUI

/// A view that displays a compact thumbnail for a HoopSession.
/// It shows decorative graphics along with key details such as the number of makes, session length, and average makes per minute.
struct SessionThumbnail: View {
    
    // MARK: - Properties
    
    let date: Date         // The date of the session.
    let makes: Int         // Number of successful shots.
    let length: Int        // Session length in seconds.
    let average: Double    // Average makes per minute.
    let shotType: ShotType // The type of shot attempted during the session.
    
    /// DateFormatter to format the session date in a readable style.
    let dateFormatter = DateFormatter()
    
    /// Determines the accent color based on the shot type.
    var iconColor: Color {
        switch shotType {
        case .freeThrows, .midrange: return .blue
        case .layups:                return .red
        case .threePointers:         return .green
        case .deep:                  return .purple
        case .allShots:              return .orange
        }
    }
    
    // MARK: - Initializer
    
    /// Initializes a new SessionThumbnail view.
    /// Sets up the date formatter to display the date as "day month" (e.g., "8 Mar").
    init(date: Date, makes: Int, length: Int, average: Double, shotType: ShotType) {
        self.date = date
        self.makes = makes
        self.length = length
        self.average = average
        self.shotType = shotType
        dateFormatter.dateFormat = "d MMM"
    }
    
    // MARK: - Body
    var body: some View {
        // The overall container uses a ZStack to layer the graphical elements with the session details.
        ZStack {
            // Left side: Decorative graphics and a label overlay.
            HStack(spacing: 0) {
                // The graphic area contains several layered elements (icons, shapes, labels).
                ZStack {
                    
                    // Basketball figure icon used as a background decorative element.
                    Image(systemName: "figure.basketball")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(iconColor.opacity(0.2))
                        .frame(height: 40)
                        .offset(x: -40, y: 20)
                        .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)
                        .rotationEffect(.degrees(10))
                    
                    // A filled basketball image overlay.
                    Image(systemName: "basketball.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(iconColor.opacity(0.2))
                        .frame(height: 70)
                        .offset(x: 17.5, y: 52.5)
                        .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)
                    
                    // Two circles drawn with strokes for extra decoration.
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
                    
                    // Display the shot points (e.g., "+3 pts") using a helper function.
                    Text("\(getShotPoints(for: shotType)) pts")
                        .font(.headline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .offset(x: 20, y: -22.5)
                        .rotationEffect(.degrees(12))
                        .foregroundStyle(iconColor.opacity(0.2))
                        .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)
                    
                    // A horizontal stack containing the shot type label and a decorative divider.
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
                
                // Right side: Numeric details of the session.
                VStack(spacing: 10) {
                    
                    HStack(spacing: 0) {
                        Spacer()
                        
                        // "Makes" information.
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Makes")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .fontWeight(.regular)
                            Text("\(makes)")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: 60)
                        
                        Spacer()
                        
                        // "Length" of session, presented as minutes and seconds.
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Length")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .fontWeight(.regular)
                            Text("\(length / 60)m \(length % 60)s")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        // "Average" metric information.
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Average")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .fontWeight(.regular)
                            // Display the average value with a "/ min" suffix.
                            HStack(spacing: 2.5) {
                                Text("\(String(format: "%.1f", average))")
                                    .foregroundStyle(.white)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("/ min")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .fontWeight(.semibold)
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
        // Use a simple opacity transition for appearing/disappearing.
        .transition(.opacity)
    }
}

/// A helper function that returns the shot points label based on the shot type.
/// - Parameter shotType: The shot type for which points need to be displayed.
/// - Returns: A String (e.g., "+2" or "+3").
func getShotPoints(for shotType: ShotType) -> String {
    switch shotType {
    case .layups, .midrange, .freeThrows:
        return "+2"
    case .threePointers, .deep:
        return "+3"
    case .allShots:
        return "+" // Use an appropriate label when all shots are considered.
    }
}

/// A placeholder view used when no session thumbnail data is available.
struct PlaceholderThumbnail: View {
    
    let prompt: String  // Prompt message to display.
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Text(prompt)
                    .foregroundStyle(.gray.opacity(0.25))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
            }
            .frame(height: 72.5)
            .frame(maxWidth: .infinity)
            .overlay(
                // A dashed border to indicate the placeholder state.
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
        // Preview an example session thumbnail.
        SessionThumbnail(date: Date.now, makes: 125, length: 300, average: 2.3, shotType: .deep)
        // Preview the placeholder thumbnail.
        PlaceholderThumbnail(prompt: "Go hit some Drills!")
    }
}
