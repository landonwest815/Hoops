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
                NavigationLink(destination: Session(shotType: .layups).navigationBarBackButtonHidden(true)) {
                        Text("Layups")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.red)
                
                // MARK: Free Throws
                NavigationLink(destination: Session(shotType: .freeThrows).navigationBarBackButtonHidden(true)) {
                        Text("Free Throws")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.blue)
                
                // MARK: Midrange
                NavigationLink(destination: Session(shotType: .midrange).navigationBarBackButtonHidden(true)) {
                        Text("Midrange")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.blue)
                
                // MARK: Three Pointers
                NavigationLink(destination: Session(shotType: .threePointers).navigationBarBackButtonHidden(true)) {
                        Text("Three Pointers")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.green)
                
                // MARK: Deep
                NavigationLink(destination: Session(shotType: .deep).navigationBarBackButtonHidden(true)) {
                        Text("Deep")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.green)
                
                // MARK: All Shots
                NavigationLink(destination: Session(shotType: .allShots).navigationBarBackButtonHidden(true)) {
                        Text("All Shots")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.purple)
            }
            .navigationTitle("Shot Type")
        }
    }
}

#Preview {
    ShotSelection()
}
