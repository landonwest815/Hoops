//
//  ShotSelection.swift
//  WatchTest Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct ShotSelection: View {
    
    @State var hapticsTrigger = 0

    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                NavigationLink(destination: SessionSettings(shotSelection: "Layups")) {
                    Text("Layups")
                }.simultaneousGesture(TapGesture().onEnded{
                    hapticsTrigger += 1
                })
                .sensoryFeedback(.selection, trigger: hapticsTrigger)
                .tint(.red)
                
                NavigationLink(destination: SessionSettings(shotSelection: "Free Throws")) {
                    Text("Free Throws")
                }.simultaneousGesture(TapGesture().onEnded{
                    hapticsTrigger += 1
                })
                .sensoryFeedback(.selection, trigger: hapticsTrigger)
                .tint(.blue)
                
                NavigationLink(destination: SessionSettings(shotSelection: "Midrange")) {
                    Text("Midrange")
                }.simultaneousGesture(TapGesture().onEnded{
                    hapticsTrigger += 1
                })
                .sensoryFeedback(.selection, trigger: hapticsTrigger)
                .tint(.blue)
                
                NavigationLink(destination: SessionSettings(shotSelection: "Three Pointers")) {
                    Text("Three Pointers")
                }.simultaneousGesture(TapGesture().onEnded{
                    hapticsTrigger += 1
                })
                .sensoryFeedback(.selection, trigger: hapticsTrigger)
                .tint(.green)
                
                NavigationLink(destination: SessionSettings(shotSelection: "Deep")) {
                    Text("Deep")
                }.simultaneousGesture(TapGesture().onEnded{
                    hapticsTrigger += 1
                })
                .sensoryFeedback(.selection, trigger: hapticsTrigger)
                .tint(.green)
                
            }
            .navigationTitle("Shot Type")

        }
    }
}

#Preview {
    ShotSelection()
}
