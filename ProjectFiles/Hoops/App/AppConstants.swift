//
//  AppConstants.swift
//  Hoops
//
//  Created by Landon West on 5/13/25.
//

import SwiftUI

enum AppConstants {
    enum UserDefaultsKeys {
        static let previousTrophyLevels = "PreviousTrophyLevels"
    }

    enum SheetHeights {
        struct Fractions {
            let stats: CGFloat
            let profile: CGFloat
            let creation: CGFloat
            let details: CGFloat
            let settings: CGFloat
            let onboarding: CGFloat
        }

        static let small = Fractions(
            stats: 0.70, profile: 0.96,
            creation: 0.40, details: 0.40,
            settings: 0.96, onboarding: 0.96
        )

        static let medium = Fractions(
            stats: 0.75, profile: 0.96,
            creation: 0.30, details: 0.30,
            settings: 0.96, onboarding: 0.70
        )

        static let large = Fractions(
            stats: 0.75, profile: 0.96,
            creation: 0.30, details: 0.30,
            settings: 0.96, onboarding: 0.70
        )

        static var current: Fractions {
            // grab the height in “points”
            let h = UIScreen.main.bounds.height
            print("🔍 Screen height = \(h)pt")

            switch h {
            case ...667:
                print("→ small group")
                return small
            case ...896:
                print("→ medium group")
                return medium
            default:
                print("→ large group")
                return large
            }
        }
    }
}
