//
//  ShotSelection.swift
//  WatchTest Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct ShotSelection: View {
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                
                NavigationLink(destination: SessionSettings(shotSelection: "Layups")) {
                    Text("Layups")
                }
                .tint(.red)
                
                NavigationLink(destination: SessionSettings(shotSelection: "Free Throws")) {
                    Text("Free Throws")
                }
                .tint(.blue)
                
                NavigationLink(destination: SessionSettings(shotSelection: "Midrange")) {
                    Text("Midrange")
                }
                .tint(.blue)
                
                NavigationLink(destination: SessionSettings(shotSelection: "Three Pointers")) {
                    Text("Three Pointers")
                }
                .tint(.green)
                
                NavigationLink(destination: SessionSettings(shotSelection: "Deep")) {
                    Text("Deep")
                }
                .tint(.green)
                
            }
            .navigationTitle("Shot Type")

        }
    }
}

#Preview {
    ShotSelection()
}
