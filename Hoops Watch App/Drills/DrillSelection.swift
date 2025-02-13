//
//  ShotSelection 2.swift
//  Hoops
//
//  Created by Landon West on 2/13/25.
//

import SwiftUI

struct DrillSelection: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                // MARK: Layups
                NavigationLink(destination: DrillView(shotType: .layups).navigationBarBackButtonHidden(true)) {
                        Text("Layups")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.red)
                
                // MARK: Free Throws
                NavigationLink(destination: DrillView(shotType: .freeThrows).navigationBarBackButtonHidden(true)) {
                        Text("Free Throws")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.blue)
                
                // MARK: Midrange
                NavigationLink(destination: DrillView(shotType: .midrange).navigationBarBackButtonHidden(true)) {
                        Text("Midrange")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.blue)
                
                // MARK: Three Pointers
                NavigationLink(destination: DrillView(shotType: .threePointers).navigationBarBackButtonHidden(true)) {
                        Text("Three Pointers")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.green)
                
                // MARK: Deep
                NavigationLink(destination: DrillView(shotType: .deep).navigationBarBackButtonHidden(true)) {
                        Text("Deep")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.purple)
                
//                // MARK: All Shots
//                NavigationLink(destination: DrillView(shotType: .allShots).navigationBarBackButtonHidden(true)) {
//                        Text("All Shots")
//                    }.simultaneousGesture(TapGesture().onEnded{
//                        WKInterfaceDevice.current().play(.click)
//                    })
//                    .tint(.orange)
            }
            .navigationTitle("Which Drill")
        }
    }
}

#Preview {
    DrillSelection()
}
