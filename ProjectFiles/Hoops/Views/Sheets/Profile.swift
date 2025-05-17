//
//  Profile.swift
//  Hoops
//
//  Created by Landon West on 2/5/25.
//

import SwiftUI
import SwiftData

enum TrophyLevel: Int, Comparable {
    case none = 0, bronze, silver, gold
    static func < (lhs: TrophyLevel, rhs: TrophyLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

func trophyLevel(for value: Int, thresholds: (bronze: Int, silver: Int, gold: Int)) -> TrophyLevel {
    if value >= thresholds.gold { return .gold }
    if value >= thresholds.silver { return .silver }
    if value >= thresholds.bronze { return .bronze }
    return .none
}

struct Accolade: Identifiable {
    let id = UUID()
    let title: String
    let value: Int
    let thresholds: (bronze: Int, silver: Int, gold: Int)
    let icon: String

    var color: Color {
        switch title {
        case "Sessions": return .orange
        case "Makes":    return .red
        case "Average":  return .blue
        default:         return .gray
        }
    }
}

struct AccoladeView: View {
    let accolade: Accolade

    private var level: TrophyLevel {
        trophyLevel(for: accolade.value, thresholds: accolade.thresholds)
    }
    private var trophyColor: Color {
        switch level {
        case .bronze: return .brown
        case .silver: return .gray
        case .gold:   return .yellow
        default:      return .gray.opacity(0.25)
        }
    }
    private var nextThreshold: Int? {
        if accolade.value < accolade.thresholds.bronze { return accolade.thresholds.bronze }
        if accolade.value < accolade.thresholds.silver { return accolade.thresholds.silver }
        if accolade.value < accolade.thresholds.gold {   return accolade.thresholds.gold }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundStyle(trophyColor)
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
                HStack(spacing: 2) {
                    Text("\(accolade.value)")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                    if let next = nextThreshold {
                        Text("/ \(next)")
                            .foregroundStyle(.gray)
                            .font(.caption)
                    } else {
                        Text("(Max)")
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
        .frame(maxWidth: .infinity, maxHeight: 150)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(lineWidth: 1)
                .foregroundColor(.gray.opacity(0.25))
        )
    }
}

struct ShotTypeView: View {
    let shotType: ShotType
    let count: Int
    let totalSessions: Int

    private var percentage: Int {
        guard totalSessions > 0 else { return 0 }
        return Int(Double(count) / Double(totalSessions) * 100)
    }
    private var color: Color {
        switch shotType {
        case .freeThrows, .midrange: return .blue
        case .layups:                return .red
        case .threePointers:         return .green
        case .deep:                  return .purple
        case .allShots:              return .orange
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 2) {
                Text("\(percentage)")
                    .foregroundStyle(color)
                    .font(.title)
                Text("%")
                    .foregroundStyle(color)
                    .font(.headline)
                    .offset(y: 2.5)
            }
            Text(shotType.rawValue)
                .foregroundStyle(.gray)
                .font(.caption2)
        }
        .fontWeight(.semibold)
        .fontDesign(.rounded)
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: 75)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(lineWidth: 1)
                .foregroundColor(.gray.opacity(0.25))
        )
    }
}

struct Profile: View {
    @Environment(\.modelContext) private var context
    @Query private var sessions: [HoopSession]

    let averageMakesPerMinute: Double
    @Binding var streak: Int
    @Binding var shotType: ShotType
    let makesCount: Int
    let daysHoopedCount: Int

    private var sessionsCount: Int { sessions.count }
    private var shotTypeCounts: [ShotType: Int] {
        var counts = [ShotType: Int]()
        for s in sessions { counts[s.shotType, default: 0] += 1 }
        return counts
    }
    private var accolades: [Accolade] {
        [
            Accolade(title: "Sessions",
                     value: sessionsCount,
                     thresholds: (10, 25, 50),
                     icon: "basketball.fill"),
            Accolade(title: "Makes",
                     value: makesCount,
                     thresholds: (200, 500, 1000),
                     icon: "scope"),
            Accolade(title: "Days Hooped",
                     value: daysHoopedCount,
                     thresholds: (7, 30, 100),
                     icon: "calendar")
        ]
    }
    private let grid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Text("My Hoops")
                        .font(.title3).fontWeight(.semibold).fontDesign(.rounded)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal)

                VStack(spacing: 20) {
                    // Stats row
                    VStack(spacing: 10) {
                        HStack {
                            Text("Stats")
                                .font(.headline).fontWeight(.semibold).fontDesign(.rounded)
                                .foregroundStyle(.gray)
                            Spacer()
                        }
                        .padding(.horizontal)

                        HStack(spacing: 10) {
                            // Average
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .resizable().aspectRatio(contentMode: .fit)
                                        .frame(height: 18).foregroundStyle(.blue)
                                    HStack(spacing: 5) {
                                        Text("\(averageMakesPerMinute, specifier: "%.2f")")
                                            .font(.title3).fontDesign(.rounded)
                                            .fontWeight(.semibold).contentTransition(.numericText())
                                            .foregroundStyle(.white)
                                        Text("/min")
                                            .font(.headline).fontDesign(.rounded)
                                            .foregroundStyle(.gray)
                                            .offset(y: -1)
                                    }
                                    Spacer()
                                }
                                Text("Average Makes")
                                    .font(.caption).fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15).padding(.vertical, 10)
                            .frame(maxWidth: .infinity, maxHeight: 75)
                            .background(.ultraThinMaterial).cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(lineWidth: 1)
                                    .foregroundColor(.gray.opacity(0.25))
                            )

                            // Streak
                            VStack(alignment: .leading) {
                                HStack {
                                    StreakBadgeView(streak: streak)
                                    Text("Week\(streak == 1 ? "" : "s")")
                                        .font(.title3).fontDesign(.rounded)
                                        .fontWeight(.semibold)
                                        .contentTransition(.numericText())
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                                Text("Hoopin' Streak")
                                    .font(.caption).fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15).padding(.vertical, 10)
                            .frame(maxWidth: .infinity, maxHeight: 75)
                            .background(.ultraThinMaterial).cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(lineWidth: 1)
                                    .foregroundColor(.gray.opacity(0.25))
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Accolades grid
                    VStack(spacing: 10) {
                        HStack {
                            Text("Accolades")
                                .font(.headline).fontWeight(.semibold).fontDesign(.rounded)
                                .foregroundStyle(.gray)
                            Spacer()
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: grid, spacing: 10) {
                            ForEach(accolades) { AccoladeView(accolade: $0) }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
        .padding(.top, 25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    @Previewable @State var streak = 4
    @Previewable @State var shotType: ShotType = .allShots
    Profile(
        averageMakesPerMinute: 5.35,
        streak: $streak,
        shotType: $shotType,
        makesCount: 200,
        daysHoopedCount: 14
    )
}
