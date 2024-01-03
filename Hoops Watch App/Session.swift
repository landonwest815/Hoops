//
//  Session.swift
//  WatchTest Watch App
//
//  Created by Landon West on 1/2/24.
//

import SwiftUI

struct Session: View {
    
    @State var sessionTime: Int
    @State var copiedTime: Int
    
    @State var timer = Timer.publish (every: 1, on: .current, in: .common).autoconnect()

    @State var makes = 0
    
    @State var showingEndConfirmation = false
    @State var isHapticActive = false
    
    @State private var hapticTimer: Timer?
    
    @State var sessionEnd = false
    
    @State private var hapticsTrigger = 0
    @State private var exitHaptic = 0
    
    @State private var showingConfirmation = false
    @State private var backgroundColor = Color.white

    init(sessionTime: Int) {
            self._sessionTime = State(initialValue: sessionTime)
            self._copiedTime = State(initialValue: sessionTime)
    }
    
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
                    .confirmationDialog("End Session Early?",
                                        isPresented: $showingConfirmation) {
                        NavigationLink(destination: PostSession(sessionTimeInMin: copiedTime, makes: makes).navigationBarBackButtonHidden(true)            .navigationBarTitleDisplayMode(.inline)) {
                            Button("End", role: .destructive) {
                                exitHaptic += 1
                                sessionEnd = true
                            }
                            .sensoryFeedback(.error, trigger: exitHaptic)
                        }
                        .tint(.red)
                    }
                                        
                    
                    Spacer()
                    
                    Text(formatTime(seconds: sessionTime))
                    
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
                    sessionTime -= 11
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
            .onReceive(timer) { time in
                if !sessionEnd {
                    if sessionTime > 0 {
                        sessionTime -= 1
                    } else {
                        startHapticFeedback()
                        showingEndConfirmation = true
                        self.timer.upstream.connect().cancel()
                    }
                }
            }
            .sensoryFeedback(.success, trigger: hapticsTrigger)
            .edgesIgnoringSafeArea(.all)
            .confirmationDialog("End of Session",
                                isPresented: $showingEndConfirmation) {
                NavigationLink(destination: PostSession(sessionTimeInMin: copiedTime, makes: makes).navigationBarBackButtonHidden(true)            .navigationBarTitleDisplayMode(.inline)) {
                    Button("Exit", role: .destructive) {
                        startHapticFeedback()
                        exitHaptic += 1
                        sessionEnd = true
                    }
                    .sensoryFeedback(.error, trigger: exitHaptic)
                }
                .tint(.red)
            }
            .onDisappear {
                stopHapticFeedback()
            }
    }
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    func startHapticFeedback() {
           isHapticActive = true
           hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
               if self.isHapticActive {
                   WKInterfaceDevice.current().play(.notification)
               } else {
                   self.hapticTimer?.invalidate()
               }
           }
   }

   func stopHapticFeedback() {
       isHapticActive = false
       hapticTimer?.invalidate()
   }
    
}

#Preview {
    Session(sessionTime: 120)
}
