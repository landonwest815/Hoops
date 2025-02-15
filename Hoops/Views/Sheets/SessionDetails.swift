//
//  SessionDetails.swift
//  Hoops
//
//  Created by Landon West on 2/11/25.
//

import SwiftUI

struct SessionDetails: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss

    @Binding var session: HoopSession
    let dateFormatter = DateFormatter()
    
    var iconColor: Color {
        switch session.shotType {
        case .freeThrows:    return .blue
        case .midrange:      return .blue
        case .layups:        return .red
        case .threePointers: return .green
        case .deep:          return .purple
        case .allShots:      return .orange
        }
    }
    
    init(session: Binding<HoopSession>) {
        self._session = session
        dateFormatter.dateFormat = "h:mm a"
    }
    
    var body: some View {
        
        
        VStack {
            ZStack {
                VStack(spacing: 10) {
                    
                    HStack {
                        
                        HStack {
                            Image(systemName: "basketball.fill")
                            Text(session.shotType.rawValue)
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                        //.padding(5)
                        //.background(.green.opacity(0.5))
                        //.cornerRadius(10)
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "clock.fill")
                            Text(dateFormatter.string(from: session.date))
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Button {
                            context.delete(session)
                            dismiss()
                        } label: {
                            Image(systemName: "trash.fill")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(5)
                    
                    HStack(spacing: 0) {
                        
                        HoopSessionEditorView(session: session, color: iconColor)            .frame(maxWidth: .infinity, maxHeight: 150)
                        
                    }
                    
                }
                
                Image(systemName: "figure.basketball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(iconColor.opacity(0.1))
                    .frame(height: 120)
                    .offset(x: -150, y: 110)
                    .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)
                    .rotationEffect(.degrees(10))
                
                Image(systemName: "basketball.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(iconColor.opacity(0.1))
                    .frame(height: 300)
                    .offset(x: 60, y: 200)
                    .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)
                
                ZStack {
                    Circle()
                        .stroke(iconColor.opacity(0.1), lineWidth: 5)
                        .frame(height: 500)
                        .offset(x: -15, y: -250)
                    
                    Circle()
                        .stroke(iconColor.opacity(0.1), lineWidth: 5)
                        .frame(height: 150)
                        .offset(x: -35, y: -166)
                }
                .rotationEffect(.degrees(-15))
                .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)
                
            }
            .frame(maxWidth: .infinity, maxHeight: 250)

            .padding()
            .background(iconColor.opacity(0.5))
            
        }
        
    }
    
}

struct HoopSessionEditorView: View {
    @Bindable var session: HoopSession
    var color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            // Minutes Input
            VStack(spacing: 5) {
                Text("Min")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(color)
                
                EditableNumberField(value: Binding(
                    get: { session.length / 60 },   // Convert seconds to minutes
                    set: { session.length = ($0 * 60) + (session.length % 60) } // Update minutes while keeping seconds
                ), color: color)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 150)

            // Seconds Input
            VStack(spacing: 5) {
                Text("Sec")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(color)
                
                EditableNumberField(value: Binding(
                    get: { session.length % 60 },  // Get remaining seconds
                    set: { session.length = (session.length / 60 * 60) + $0 } // Update seconds while keeping minutes
                ), color: color)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 150)
            
            VStack(spacing: 5) {
                Text("Makes")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(color)
                
                EditableNumberField(value: $session.makes, color: color)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 150)
        }
    }
}

struct FullWidthStepper: View {
    @Binding var value: Int
    @State var text: String

    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    if value > 0 { value -= 1 }
                }
            }) {
                Image(systemName: "minus")
                    .font(.title)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .frame(maxWidth: 50, maxHeight: 20)
                    .padding()
                    .foregroundStyle(.gray)
            }
            
            
            Divider()
                .frame(width: 1, height: 30)

            HStack(spacing: 0) {
                Text("\(value)")
                    .font(.title)
                    .padding()
                    .contentTransition(.numericText())
                
                Text(text)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(width: 1, height: 30)

            Button(action: {
                withAnimation {
                    value += 1
                }
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .frame(maxWidth: 50, maxHeight: 20)
                    .padding()
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 20)
        .padding()
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    @Previewable @State var session = HoopSession(date: .now, makes: 15, length: 180, shotType: .threePointers)
    
    SessionDetails(session: $session)
}
