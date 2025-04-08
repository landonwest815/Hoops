//
//  Profile.swift
//  Hoops
//
//  Created by Landon West on 2/5/25.
//

import SwiftUI

// MARK: - Trophy Level Helpers

enum TrophyLevel {
    case none, bronze, silver, gold
}

/// Returns the trophy level based on the value and the thresholds provided.
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

struct Accolade: Identifiable {
    let id = UUID()
    let title: String
    let value: Int
    let thresholds: (bronze: Int, silver: Int, gold: Int)
    let icon: String  // The system icon to overlay on the trophy
}

// MARK: - Accolade View

struct AccoladeView: View {
    let accolade: Accolade
    
    // Compute the trophy level based on the provided thresholds
    var level: TrophyLevel {
        trophyLevel(for: accolade.value, thresholds: accolade.thresholds)
    }
    
    // Choose a color based on the trophy level
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
    
    // Computes the next achievable threshold based on the current value.
    // Returns nil if the current value has already reached (or exceeded) the gold level threshold.
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
            ZStack {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundStyle(trophyColor)
                
                // Overlay the specified icon for this accolade,
                // which itself can have a subtle shadow or opacity effect.
                Image(systemName: accolade.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 27.5)
                    .foregroundStyle(.black.opacity(0.2))
                    .offset(y: -20)
            }
            .padding(.top, 5)
            .padding(.horizontal, 5)
            
            VStack(spacing: 0) {
                // Show current value along with the next achievable threshold, if applicable.
                HStack(spacing: 2) {
                    Text("\(accolade.value)")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                    
                    if let next = nextThreshold {
                        Text("/ \(next)")
                            .foregroundStyle(.gray)
                            .font(.caption)
                    } else {
                        // Optionally, show a message if the user has reached the highest threshold.
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

// MARK: - Main Profile View

struct Profile: View {
    
    // Existing metrics for the header stats
    let averageMakesPerMinute: Double
    @Binding var streak: Int
    
    // New dynamic accolade metrics.
    // In a real app these could come from your app's state, a model, or a backend.
    let sessionsCount: Int
    let makesCount: Int
    let daysHoopedCount: Int
    
    // Create a list of accolades with their intuitive thresholds.
    // You can adjust the threshold values based on your app’s scoring.
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
    
    // Set up grid columns for dynamic accolades layout.
    // Adjust the number of columns as needed.
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
                        // action for info button
                    } label: {
                        Image(systemName: "info.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal, 5)
                
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
                            // Average Makes per minute
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
                            
                            // Hoopin' streak display
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
                        
                        // Use a grid to render accolades dynamically:
                        LazyVGrid(columns: gridColumns, spacing: 10) {
                            ForEach(accolades) { accolade in
                                AccoladeView(accolade: accolade)
                            }
                        }
                    }
                    
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    @Previewable @State var streak = 4
    Profile(averageMakesPerMinute: 5.35,
            streak: $streak,
            sessionsCount: 25,
            makesCount: 200,
            daysHoopedCount: 14)
}
