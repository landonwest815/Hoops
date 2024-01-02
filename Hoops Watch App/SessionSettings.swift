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
    @State var pickerHapticsTrigger = 0
    @State var hapticsTrigger = 0
    
    var body: some View {
        NavigationStack {
    
            VStack(spacing: 15) {
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
                    pickerHapticsTrigger += 1
                }
                .sensoryFeedback(.selection, trigger: pickerHapticsTrigger)
                
                NavigationLink(destination: Session(sessionTime: selectedTime).navigationBarBackButtonHidden(true)){
                    Text("Start")
                }.simultaneousGesture(TapGesture().onEnded{
                    hapticsTrigger += 1
                })
                .sensoryFeedback(.start, trigger: hapticsTrigger)
                .tint(.green)
            }
            .navigationTitle("Session Length")
        }
    }
}

#Preview {
    SessionSettings(shotSelection: "Three Pointers")
}
