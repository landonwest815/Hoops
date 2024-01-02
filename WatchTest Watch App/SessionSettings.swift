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
    
            VStack(spacing: 15) {
                Picker(selection: $selectedTime, label: Text("")) {
                    Text("1").tag(1)
                    Text("3").tag(3)
                    Text("5").tag(5)
                    Text("10").tag(10)
                }
                .pickerStyle(.wheel)
                
                NavigationLink(destination: Text("test")) {
                    Text("Start")
                }
                .tint(.green)
            }
            .navigationTitle(                Text("\(selectedTime) min"))
        }
    }
}

#Preview {
    SessionSettings(shotSelection: "Three Pointers")
}
