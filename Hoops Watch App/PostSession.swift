//
//  PostSession.swift
//  Hoops Watch App
//
//  Created by Landon West on 1/3/24.
//

import SwiftUI

struct PostSession: View {
    
    @State var sessionTimeInMin: Int
    @State var makes: Int
        
    init(sessionTimeInMin: Int, makes: Int) {
        self.sessionTimeInMin = sessionTimeInMin / 60
        self.makes = makes
    }

    var body: some View {
        
        NavigationView {
            HStack {
                Form {
                    Section(header: Text("Time")) {
                        Text("\(sessionTimeInMin):00")
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
                            Text(averageMakesPerMinute(sessionLength: sessionTimeInMin, makes: makes))
                                .font(.system(size: 25))
                        }
                        .listRowBackground(Color.clear)
                        
                    }
                    .scrollDisabled(true)
                    
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark")
                            Spacer()
                        }
                    }.simultaneousGesture(TapGesture().onEnded{
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
        
    }
    
    func averageMakesPerMinute(sessionLength: Int, makes: Int) -> String {
        guard sessionLength > 0 else { return "0.0" }

        let average = Double(makes) / Double(sessionLength)
        return String(format: "%.1f", round(10 * average) / 10)
    }
}

#Preview {
    PostSession(sessionTimeInMin: 600, makes: 25)
}
