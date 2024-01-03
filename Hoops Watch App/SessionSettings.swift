//
//  SessionSettings.swift
//  WatchTest Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct SessionSettings: View {
    @State var shotSelection: String
    @State var selectedTime = 1
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                
                // MARK: Session Length Selection
                    Picker(selection: $selectedTime, label: Text("")) {
                        Text("1 min").tag(1)
                        Text("3 min").tag(3)
                        Text("5 min").tag(5)
                        Text("10 min").tag(10)
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .onChange(of: selectedTime) {
                        WKInterfaceDevice.current().play(.click)
                    }
                
                // MARK: Start Session Button
                    NavigationLink(destination: Session(sessionTime: selectedTime * 60).navigationBarBackButtonHidden(true)){
                        Text("Start")
                    }.simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(.green)
                
            }
            .navigationTitle("Session Length")
        }
    }
}

#Preview {
    SessionSettings(shotSelection: "Three Pointers")
}
