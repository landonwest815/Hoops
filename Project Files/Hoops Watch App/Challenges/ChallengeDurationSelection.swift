//
//  ChallengeDurationSelection.swift
//  Hoops
//
//  Created by Landon West on 5/13/25.
//


import SwiftUI

struct ChallengeDurationSelection: View {
    let shotType: ShotType
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(Array(zip([60, 300, 600], [Color.red, Color.blue, Color.green])), id: \.0) { duration, color in
                    NavigationLink(destination: ChallengeSession(shotType: shotType, timeLimit: duration).navigationBarBackButtonHidden(true)) {
                        Text("\(duration / 60) Min")
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(color)
                }
            }
            .navigationTitle("Pick Duration")
        }
    }
}
