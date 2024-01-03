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
                
                // MARK: Layups
                    NavigationLink(destination: SessionSettings(shotSelection: "Layups")) {
                        Text("Layups")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.red)
                
                // MARK: Free Throws
                    NavigationLink(destination: SessionSettings(shotSelection: "Free Throws")) {
                        Text("Free Throws")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.blue)
                
                // MARK: Midrange
                    NavigationLink(destination: SessionSettings(shotSelection: "Midrange")) {
                        Text("Midrange")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.blue)
                
                // MARK: Three Pointers
                    NavigationLink(destination: SessionSettings(shotSelection: "Three Pointers")) {
                        Text("Three Pointers")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.green)
                
                // MARK: Deep
                    NavigationLink(destination: SessionSettings(shotSelection: "Deep")) {
                        Text("Deep")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.green)
            }
            .navigationTitle("Shot Type")
        }
    }
}

#Preview {
    ShotSelection()
}
