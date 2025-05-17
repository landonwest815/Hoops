//
//  AccoladeLogic.swift
//  Hoops
//
//  Created by Landon West on 5/13/25.
//

import Foundation

struct AccoladeLogic {
    private static let storageKey = "PreviousTrophyLevels"

    static func computeAccolades(for sessions: [HoopSession]) -> [Accolade] {
        [
            Accolade(
                title: "Sessions",
                value: sessions.count,
                thresholds: (10, 25, 50),
                icon: "basketball.fill"
            ),
            Accolade(
                title: "Makes",
                value: SessionsLogic.calculateTotalMakes(for: sessions),
                thresholds: (200, 500, 1000),
                icon: "scope"
            ),
            Accolade(
                title: "Days Hooped",
                value: SessionsLogic.calculateDaysHooped(for: sessions),
                thresholds: (7, 30, 100),
                icon: "calendar"
            )
        ]
    }

    static func loadTrophyLevels() -> [String: TrophyLevel] {
        (UserDefaults.standard
            .dictionary(forKey: storageKey) as? [String: Int] ?? [:]
        ).mapValues { TrophyLevel(rawValue: $0) ?? .none }
    }

    static func saveTrophyLevels(_ levels: [String: TrophyLevel]) {
        UserDefaults.standard.set(
            levels.mapValues { $0.rawValue },
            forKey: storageKey
        )
    }

    static func checkForTrophyUpgrade(
        sessions: [HoopSession],
        currentLevels: inout [String: TrophyLevel]
    ) -> Accolade? {
        for accolade in computeAccolades(for: sessions) {
            let newLevel = trophyLevel(
                for: accolade.value,
                thresholds: accolade.thresholds
            )
            let oldLevel = currentLevels[accolade.title] ?? .none
            currentLevels[accolade.title] = newLevel

            if newLevel > oldLevel {
                return accolade
            }
        }
        return nil
    }
}

