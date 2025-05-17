//
//  AccoladeLogic.swift
//  Hoops
//
//  Created by Landon West on 5/13/25.
//


//
//  AccoladeLogic.swift
//  Hoops
//
//  Created by Landon West on [today’s date].
//

import Foundation

struct AccoladeLogic {
    
    static let storageKey = "PreviousTrophyLevels"

    static func computeAccolades(for sessions: [HoopSession]) -> [Accolade] {
        let sessionsAccolade = Accolade(title: "Sessions", value: sessions.count, thresholds: (10, 25, 50), icon: "basketball.fill")
        let makesAccolade = Accolade(title: "Makes", value: SessionsLogic.calculateTotalMakes(for: sessions), thresholds: (200, 500, 1000), icon: "scope")
        let daysAccolade = Accolade(title: "Days Hooped", value: SessionsLogic.calculateDaysHooped(for: sessions), thresholds: (7, 30, 100), icon: "calendar")
        return [sessionsAccolade, makesAccolade, daysAccolade]
    }

    static func getPersistedTrophyLevels() -> [String: TrophyLevel] {
        if let saved = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: Int] {
            return saved.reduce(into: [String: TrophyLevel]()) { result, pair in
                result[pair.key] = TrophyLevel(rawValue: pair.value) ?? TrophyLevel.none
            }
        }
        return [:]
    }

    static func setPersistedTrophyLevels(_ levels: [String: TrophyLevel]) {
        let converted = levels.mapValues { $0.rawValue }
        UserDefaults.standard.set(converted, forKey: storageKey)
    }

    static func checkForTrophyUpgrade(
        from sessions: [HoopSession],
        storedLevels: inout [String: TrophyLevel]
    ) -> Accolade? {
        for accolade in computeAccolades(for: sessions) {
            let newLevel = trophyLevel(for: accolade.value, thresholds: accolade.thresholds)
            let previousLevel = storedLevels[accolade.title] ?? .none

            if newLevel > previousLevel {
                storedLevels[accolade.title] = newLevel
                return accolade
            } else {
                storedLevels[accolade.title] = newLevel
            }
        }
        return nil
    }
}
