//
//  ShotSelection 2.swift
//  Hoops
//
//  Created by Landon West on 2/11/25.
//


//
//  ShotSelection.swift
//  WatchTest Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct SessionSelection: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                
                // MARK: Layups
                NavigationLink(destination: ShotSelection().navigationBarBackButtonHidden(false)) {
                        Text("Freestyle")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.blue)
                
                // MARK: Free Throws
                NavigationLink(destination: Session(shotType: .freeThrows).navigationBarBackButtonHidden(true)) {
                        Text("Challenges")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.red)
                
                // MARK: Three Pointers
                NavigationLink(destination: Session(shotType: .threePointers).navigationBarBackButtonHidden(true)) {
                        Text("Shooting Drills")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.green)
            }
            .navigationTitle("Session Type")
        }
    }
}

#Preview {
    SessionSelection()
}
