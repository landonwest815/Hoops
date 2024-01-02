//
//  Session.swift
//  WatchTest Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct Session: View {
    
    @State var sessionTime: Int
    @State var makes = 0
    
    @State private var hapticsTrigger = 0
    @State private var exitHaptic = 0
    
    @State private var showingConfirmation = false
    @State private var backgroundColor = Color.white

    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                
                Button {
                    // pause timer
                } label: {
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(.red)
                }
                .clipShape(.circle)
                .frame(width: 25, height: 25)
                .tint(.red)
                .simultaneousGesture(TapGesture().onEnded{
                    showingConfirmation = true
                })
                .confirmationDialog("Are you sure?",
                     isPresented: $showingConfirmation) {
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                        Button("Exit Session", role: .destructive) {
                            exitHaptic += 1
                        }
                        .sensoryFeedback(.error, trigger: exitHaptic)
                    }
                    .tint(.red)
                }
                
                Spacer()
                
                Text("\(sessionTime):00")
                
                Spacer()
                    
                Text("\(makes)")
                
                Spacer()
            }
            .padding(.top, 30)
            .font(.system(size: 30))
            .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                makes += 1
                hapticsTrigger += 1
            }) {
                Image(systemName: "basketball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 125, height: 160)
            }
            .edgesIgnoringSafeArea(.all)
            .tint(.green)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle(radius: 40))
            .sensoryFeedback(.success, trigger: hapticsTrigger)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    
}

#Preview {
    Session(sessionTime: 5)
}
