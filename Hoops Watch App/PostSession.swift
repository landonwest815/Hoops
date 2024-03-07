//
//  PostSession.swift
//  Hoops Watch App
//
//  Created by Landon West on 1/3/24.
//

import SwiftUI

struct PostSession: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State var sessionTimeInSec: Int
    @State var makes: Int

    var body: some View {
        
        NavigationView {
            HStack {
                Form {
                    Section(header: Text("Time")) {
                        Text(formatTime(seconds: sessionTimeInSec))
                            .font(.system(size: 25))
                    }
                    .listRowBackground(Color.clear)

                    Section(header: Text("Makes")) {
                        Text("\(makes)")
                            .font(.system(size: 25))
                    }
                    .listRowBackground(Color.clear)

                }
                .scrollDisabled(true)
                
                VStack {
                    
                    Form {
                        
                        Section(header: Text("AVG/Min")) {
                            Text(averageMakesPerMinute(sessionLength: sessionTimeInSec, makes: makes))
                                .font(.system(size: 25))
                        }
                        .listRowBackground(Color.clear)
                        
                    }
                    .scrollDisabled(true)
                    
//                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
//                        HStack {
//                            Spacer()
//                            Image(systemName: "checkmark")
//                            Spacer()
//                        }
//                    }
                    Button("Done") {
                        dismiss()
                    }
                    .simultaneousGesture(TapGesture().onEnded{
                        WKInterfaceDevice.current().play(.click)
                    })
                    .navigationBarBackButtonHidden(true)
                    .tint(.green)
                    .padding(.trailing, 20)
                    
                }

            }
            .navigationTitle("Session Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onDisappear() {
            sessionTimeInSec = 0
            makes = 0
        }
        
    }
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    func averageMakesPerMinute(sessionLength: Int, makes: Int) -> String {
        guard sessionLength > 0 else { return "0.0" }

        let average = Double(makes) / (Double(sessionLength) / 60.0)
        return String(format: "%.1f", round(10 * average) / 10)
    }
    
    func sendToiPhone() {
        //let Session(date:)
    }
}

#Preview {
    PostSession(sessionTimeInSec: 600, makes: 25)
}
