//
//  ModeSelection.swift
//  Hoops
//
//  Created by Landon West on 5/14/25.
//


// ModeSelection.swift
import SwiftUI

struct ModeSelection: View {
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack {
                ForEach([SessionMode.freestyle, .challenge, .drill], id: \.self) { mode in
                    NavigationLink(value: AppRoute.shotSelection(mode: mode)) {
                        Text(mode == .challenge ? "Challenges"
                             : (mode == .freestyle ? "Freestyle" : "Drills"))
                    }
                    .hapticNavLinkStyle()
                    .tint(mode.color)
                }
                Spacer()
            }
        }
        .navigationTitle("Session Type")
    }
}
