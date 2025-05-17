////
////  PostSession.swift
////  Hoops Watch App
////
////  Created by Landon West on 1/3/24.
////
//
//import SwiftUI
//
//struct PostSession: View {
//    @StateObject var watchConnector = WatchToiOSConnector()
//    @Environment(\.dismiss) private var dismiss
//    
//    var shotType: ShotType
//    
//    @State var sessionTimeInSec: Int
//    @State var makes: Int
//
//    var body: some View {
//        
//        NavigationView {
//            HStack(spacing: 20) {
//                VStack(spacing: 20) {
//                    
//                    VStack {
//                        Text("Length")
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .fontDesign(.rounded)
//                            .foregroundStyle(.gray)
//                        
//                        Text(formatTime(seconds: sessionTimeInSec))
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .fontDesign(.rounded)
//                    }
//                    .frame(height: 66)
//                    
//                    VStack {
//                        Text("Makes")
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .fontDesign(.rounded)
//                            .foregroundStyle(.gray)
//                        
//                        Text(String(makes))
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .fontDesign(.rounded)
//                    }
//                    .frame(height: 66)
//                }
//
//                VStack(spacing: 20) {
//                    
//                    VStack {
//                        Text("Avg")
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                            .fontDesign(.rounded)
//                            .foregroundStyle(.gray)
//                        
//                        Text(averageMakesPerMinute(sessionLength: sessionTimeInSec, makes: makes))
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .fontDesign(.rounded)
//                    }
//                    .frame(height: 66)
//                
//                    Button("Done") {
//                        sendSessionToiOS()
//                        dismiss()
//                    }
//                    .frame(width: 66, height: 66)
//                    .simultaneousGesture(TapGesture().onEnded{
//                        WKInterfaceDevice.current().play(.click)
//                    })
//                    .tint(.green)
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .fontDesign(.rounded)
//                    
//                }
//                .navigationBarBackButtonHidden(true)
//
//            }
//            .navigationTitle("Session Stats")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//        .onDisappear() {
//            sessionTimeInSec = 0
//            makes = 0
//        }
//        
//    }
//    
//    func formatTime(seconds: Int) -> String {
//        let minutes = seconds / 60
//        let remainingSeconds = seconds % 60
//        return String(format: "%02d:%02d", minutes, remainingSeconds)
//    }
//    
//    func averageMakesPerMinute(sessionLength: Int, makes: Int) -> String {
//        guard sessionLength > 0 else { return "0.0" }
//
//        let average = Double(makes) / (Double(sessionLength) / 60.0)
//        return String(format: "%.1f", round(10 * average) / 10)
//    }
//    
//    func sendSessionToiOS() {
//        let hoopSession = HoopSession(date: Date.now, makes: makes, length: sessionTimeInSec, shotType: shotType, sessionType: .freestyle)
//        watchConnector.sendSessionToiPhone(hoopSession: hoopSession)
//    }
//}
//
//#Preview {
//    PostSession(shotType: .allShots, sessionTimeInSec: 600, makes: 25)
//}
