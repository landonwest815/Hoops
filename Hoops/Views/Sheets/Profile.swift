//
//  Profile.swift
//  Hoops
//
//  Created by Landon West on 2/5/25.
//

import SwiftUI
import SwiftData

// MARK: - Trophy Level Helpers

/// An enumeration representing different trophy levels.
/// Conforms to `Comparable` based on its raw value.
enum TrophyLevel: Int, Comparable {
    case none = 0, bronze, silver, gold

    static func < (lhs: TrophyLevel, rhs: TrophyLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Determines the trophy level based on a given value and associated thresholds.
/// - Parameters:
///   - value: The numeric value (e.g., total sessions, makes, etc.).
///   - thresholds: A tuple containing the bronze, silver, and gold thresholds.
/// - Returns: A `TrophyLevel` based on the thresholds.
func trophyLevel(for value: Int, thresholds: (bronze: Int, silver: Int, gold: Int)) -> TrophyLevel {
    if value >= thresholds.gold {
        return .gold
    } else if value >= thresholds.silver {
        return .silver
    } else if value >= thresholds.bronze {
        return .bronze
    } else {
        return .none
    }
}

// MARK: - Accolade Data Model

/// Represents an accolade or achievement with thresholds and an associated icon.
struct Accolade: Identifiable {
    let id = UUID()
    let title: String
    let value: Int
    let thresholds: (bronze: Int, silver: Int, gold: Int)
    let icon: String  // The system icon to overlay on the trophy
    
    /// Provides a color associated with the accolade based on its title.
    var color: Color {
        switch title {
        case "Sessions":
            return .orange
        case "Makes":
            return .red
        case "Average":
            return .blue
        default:
            return .gray
        }
    }
}

// MARK: - Accolade View

/// A view that displays a trophy along with numeric progress for an accolade.
struct AccoladeView: View {
    let accolade: Accolade
    
    /// The computed trophy level based on the accolade's value and thresholds.
    var level: TrophyLevel {
        trophyLevel(for: accolade.value, thresholds: accolade.thresholds)
    }
    
    /// Chooses a color based on the trophy level.
    var trophyColor: Color {
        switch level {
        case .bronze:
            return .brown
        case .silver:
            return .gray
        case .gold:
            return .yellow
        case .none:
            return .gray.opacity(0.25)
        }
    }
    
    /// Computes the next threshold that has not yet been reached.
    /// Returns `nil` if the gold threshold (or beyond) is reached.
    var nextThreshold: Int? {
        if accolade.value < accolade.thresholds.bronze {
            return accolade.thresholds.bronze
        } else if accolade.value < accolade.thresholds.silver {
            return accolade.thresholds.silver
        } else if accolade.value < accolade.thresholds.gold {
            return accolade.thresholds.gold
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Trophy image with an overlay icon.
            ZStack {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundStyle(trophyColor)
                
                // Overlay the specific icon for this accolade.
                Image(systemName: accolade.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 27.5)
                    .foregroundStyle(.black.opacity(0.2))
                    .offset(y: -20)
            }
            .padding(.top, 5)
            .padding(.horizontal, 5)
            
            // Display the numerical progress and title.
            VStack(spacing: 0) {
                HStack(spacing: 2) {
                    Text("\(accolade.value)")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                    
                    if let next = nextThreshold {
                        Text("/ \(next)")
                            .foregroundStyle(.gray)
                            .font(.caption)
                    } else {
                        Text(" (Max)")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }
                Text(accolade.title)
                    .foregroundStyle(.gray)
                    .font(.caption2)
            }
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .padding(.bottom, 5)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundColor(.gray.opacity(0.25))
        )
    }
}

// MARK: - Shot Type View

/// Displays information for a given shot type including the percentage of sessions.
/// This view is used to show the distribution of different shot types.
struct ShotTypeView: View {
    let shotType: ShotType
    let count: Int          // Number of sessions for this shot type.
    let totalSessions: Int  // Total number of sessions overall.
    
    /// Calculates the percentage of sessions that correspond to this shot type.
    var percentage: Int {
        guard totalSessions > 0 else { return 0 }
        return Int((Double(count) / Double(totalSessions)) * 100)
    }
    
    /// Selects a color based on the shot type.
    var color: Color {
        switch shotType {
        case .freeThrows, .midrange: return .blue
        case .layups:               return .red
        case .threePointers:        return .green
        case .deep:                 return .purple
        case .allShots:             return .orange
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 5) {
                // Display the percentage.
                HStack(spacing: 2) {
                    Text("\(percentage)")
                        .foregroundStyle(color)
                        .font(.title)
                    Text("%")
                        .foregroundStyle(color)
                        .font(.headline)
                        .offset(y: 2.5)
                }
                
                // Display the shot type name.
                Text(shotType.rawValue)
                    .foregroundStyle(.gray)
                    .font(.caption2)
            }
            .fontWeight(.semibold)
            .fontDesign(.rounded)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 75)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundColor(.gray.opacity(0.25))
        )
    }
}

// MARK: - Main Profile View

/// The main profile view, displaying session metrics, accolades, and other statistics.
struct Profile: View {
    // MARK: Environment & Query
    @Environment(\.modelContext) var context    // Data context for database queries.
    @Query var sessions: [HoopSession]            // Fetch sessions from the database.
    
    // MARK: Header Metrics
    let averageMakesPerMinute: Double           // Average makes per minute.
    @Binding var streak: Int                    // Current hooping streak.
    @Binding var shotType: ShotType             // Selected shot type (for filtering, if needed).
    
    // Metrics not directly derived from sessions.
    let makesCount: Int
    let daysHoopedCount: Int
    
    /// The total number of sessions.
    var sessionsCount: Int {
        sessions.count
    }
    
    /// Calculates the counts for each shot type.
    var shotTypeCounts: [ShotType: Int] {
        var counts: [ShotType: Int] = [:]
        for session in sessions {
            counts[session.shotType, default: 0] += 1
        }
        return counts
    }
    
    /// Creates a list of accolades based on current session statistics.
    var accolades: [Accolade] {
        [
            Accolade(title: "Sessions",
                     value: sessionsCount,
                     thresholds: (bronze: 10, silver: 25, gold: 50),
                     icon: "basketball.fill"),
            
            Accolade(title: "Makes",
                     value: makesCount,
                     thresholds: (bronze: 200, silver: 500, gold: 1000),
                     icon: "scope"),
            
            Accolade(title: "Days Hooped",
                     value: daysHoopedCount,
                     thresholds: (bronze: 7, silver: 30, gold: 100),
                     icon: "calendar")
        ]
    }
    
    // MARK: Grid Configuration for Accolades and (Commented) Shot Types
    let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                // MARK: Header Section
                HStack(spacing: 12) {
                    Text("My Hoops")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        // Info button action placeholder.
                    } label: {
                        Image(systemName: "info.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal, 5)
                .padding(.horizontal)
                
                // MARK: Stats Section
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Stats")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            // Average Makes per Minute Display
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 18)
                                        .foregroundStyle(.blue)
                                        .fontWeight(.semibold)
                                    
                                    HStack(spacing: 5) {
                                        Text("\(averageMakesPerMinute, specifier: "%.2f")")
                                            .font(.title3)
                                            .fontDesign(.rounded)
                                            .fontWeight(.semibold)
                                            .contentTransition(.numericText())
                                            .foregroundStyle(.white)
                                        
                                        Text("/min")
                                            .font(.headline)
                                            .fontDesign(.rounded)
                                            .foregroundStyle(.gray)
                                            .offset(y: -1)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Text("Average Makes")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(style: StrokeStyle(lineWidth: 1))
                                    .foregroundColor(.gray.opacity(0.25))
                            )
                            
                            // Hoopin' Streak Display
                            VStack(alignment: .leading) {
                                HStack {
                                    ZStack {
                                        Image(systemName: "flame.fill")
                                            .resizable()
                                            .frame(width: 21, height: 23)
                                            .foregroundStyle(.red)
                                        
                                        Image(systemName: "circle.fill")
                                            .resizable()
                                            .frame(width: 11, height: 12)
                                            .offset(y: 3)
                                            .foregroundStyle(.red)
                                        
                                        Image(systemName: "flame.fill")
                                            .resizable()
                                            .frame(width: 11, height: 12)
                                            .offset(y: 3)
                                            .foregroundStyle(.orange)
                                    }
                                    
                                    Text("\(streak) Days")
                                        .font(.title3)
                                        .fontDesign(.rounded)
                                        .fontWeight(.semibold)
                                        .contentTransition(.numericText())
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                }
                                
                                Text("Hoopin' Streak")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(style: StrokeStyle(lineWidth: 1))
                                    .foregroundColor(.gray.opacity(0.25))
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: Accolades Section
                    VStack(spacing: 10) {
                        HStack {
                            Text("Accolades")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: gridColumns, spacing: 10) {
                            ForEach(accolades) { accolade in
                                AccoladeView(accolade: accolade)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: Shot Types Section (Commented Out)
                    /*
                    VStack(spacing: 10) {
                        HStack {
                            Text("Shot Types")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: gridColumns, spacing: 10) {
                            ForEach(ShotType.allCases, id: \.self) { shotType in
                                // For .allShots, display overall session count. Otherwise, use the computed count.
                                let count = shotType == .allShots ? sessionsCount : (shotTypeCounts[shotType] ?? 0)
                                ShotTypeView(shotType: shotType,
                                             count: count,
                                             totalSessions: sessionsCount)
                            }
                        }
                    }
                    .padding(.horizontal)
                    */
                }
                
                Spacer()
            }
        }
        .padding(.top, 25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var streak = 4
    @Previewable @State var shotType: ShotType = .allShots
    // For preview purposes, supplying sample values for makesCount and daysHoopedCount.
    Profile(averageMakesPerMinute: 5.35,
            streak: $streak,
            shotType: $shotType,
            makesCount: 200,
            daysHoopedCount: 14)
}
