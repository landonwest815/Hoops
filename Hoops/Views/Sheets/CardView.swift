//
//  CardView.swift
//  Hoops
//
//  Created by Landon West on 1/28/25.
//

import SwiftUI

struct CardView: View {
    
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State var selectedTab = -1
    @State var shotType: ShotType = .allShots
    @State var customTime = false
    @State var minutes = 5
    @State var seconds = 00
    @State var makes = 25
    
    @FocusState private var isTextFieldFocused: Bool
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var iconColor: Color {
        switch shotType {
        case .freeThrows:    return .blue
        case .midrange:      return .blue
        case .layups:        return .red
        case .threePointers: return .green
        case .deep:          return .purple
        case .allShots:      return .orange
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            VStack(spacing: 10) {
                
                HStack {
                    
                    Image(systemName: "arrow.backward")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.title3)
                        .foregroundStyle(.clear)
                        .frame(width: 30)
                    
                    Spacer()
                    
                    Text("What type of Session?")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.title3)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 30)
                    }
                }
                .padding(.vertical, 5)
                
                HStack(spacing: 10) {
                    
                    TallCardView(text: "Freestyle", icon: "figure.cooldown", color: .red, onButtonPress: {
                        selectedTab = 0
                        shotType = .layups
                    })
                    
                    TallCardView(text: "Challenge", icon: "figure.bowling", color: .blue, onButtonPress: {
                        selectedTab = 0
                        shotType = .freeThrows
                    })
                    
                    TallCardView(text: "Drill", icon: "figure.basketball", color: .green, onButtonPress: {
                        selectedTab = 0
                        shotType = .midrange
                    })
                    
                }
                
                Spacer()
            }
            .padding(.top, 12.5)
            .padding(.horizontal)
            .tag(-1)
            
            VStack(spacing: 10) {
                
                HStack {
                    
                    Button {
                        withAnimation {
                            selectedTab -= 1
                        }
                    } label: {
                        Image(systemName: "arrow.backward")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 30)
                    }
                    
                    Spacer()
                    
                    Text("What did you focus on?")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.title3)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 30)
                    }
                }
                .padding(.vertical, 5)
                
                HStack(spacing: 10) {
                    ShortCardView(text: "Layups", color: .red, shotType: .layups, onButtonPress: {
                                        selectedTab = 1
                                        shotType = .layups
                                    })
                    ShortCardView(text: "Free Throws", color: .blue, shotType: .freeThrows, onButtonPress: {
                                                    selectedTab = 1
                                                    shotType = .freeThrows
                                                })
                    ShortCardView(text: "Midrange", color: .blue, shotType: .midrange, onButtonPress: {
                                        selectedTab = 1
                                        shotType = .midrange
                                    })
                }
                HStack(spacing: 10) {
                    ShortCardView(text: "Threes", color: .green, shotType: .threePointers, onButtonPress: {
                                            selectedTab = 1
                                            shotType = .threePointers
                                        })
                    ShortCardView(text: "Deep", color: .purple, shotType: .deep, onButtonPress: {
                                                selectedTab = 1
                                                shotType = .deep
                                            })
                    ShortCardView(text: "All Shots", color: .orange, shotType: .allShots, onButtonPress: {
                                                selectedTab = 1
                                                shotType = .allShots
                                            })
                }
                
                Spacer()
            }
            .padding(.top, 12.5)
            .padding(.horizontal)
            .tag(0)
            
            VStack {
                ZStack {
                    VStack(spacing: 10) {
                        
                        HStack {
                            Button {
                                withAnimation {
                                    if customTime {
                                        customTime = false
                                    } else {
                                        selectedTab -= 1
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.backward")
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 30)
                            }
                            
                            Spacer()
                            
                            Text(shotType.rawValue)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .font(.title3)
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    var session = HoopSession(date: .now, makes: makes, length: minutes * 60 + seconds, shotType: shotType)
                                    
                                    context.insert(session)
                                    
                                    dismiss()
                                }
                            } label: {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 30)
                            }
                        }
                        .padding(.vertical, 5)
                        
                        
                        HStack(spacing: 15) {
                            
                            VStack(spacing: 5) {
                                Text("Min")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(iconColor)
                                
                                EditableNumberField(value: $minutes, color: iconColor)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            
                            VStack(spacing: 5) {
                                Text("Sec")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(iconColor)
                                
                                EditableNumberField(value: $seconds, color: iconColor)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            
                            VStack(spacing: 5) {
                                Text("Makes")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(iconColor)
                                
                                EditableNumberField(value: $makes, color: iconColor)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: 150)
                            
                        }
                     
                    }
                    .padding(.horizontal)
                    
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
                            .offset(x: -15, y: -275)
                        
                        Circle()
                            .stroke(iconColor.opacity(0.1), lineWidth: 5)
                            .frame(height: 150)
                            .offset(x: -35, y: -175)
                    }
                    .rotationEffect(.degrees(-15))
                    .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: 225)
                
                
                Spacer()
            }
            .tag(1)
            
        }
        .background(selectedTab == 1 ? iconColor.opacity(0.5) : Color.clear)
        .onAppear {
              UIScrollView.appearance().isScrollEnabled = false
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea(.all)
        
    }
}


struct EditableNumberField: View {
    @Binding var value: Int
    @FocusState private var isFocused: Bool
    @State private var isEditing: Bool = false
    var color: Color
    
    var body: some View {
        ZStack {
            if isEditing {
                TextField("0", text: Binding(
                    get: { String(value) },
                    set: { newValue in
                        if let intValue = Int(newValue), intValue >= 0 {
                            value = intValue
                        }
                    }
                ))
                .keyboardType(.numberPad)
                .font(.system(size: 40))
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(10)
                .frame(height: 100)
                .background(color.opacity(0.3))
                .cornerRadius(18)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .allowsTightening(true)
                .focused($isFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isFocused = false
                            isEditing = false
                        }
                        .font(.headline)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isFocused = true
                    }
                }
                .onSubmit {
                    isFocused = false
                    isEditing = false
                }
                .onChange(of: isFocused) { newFocus in
                    if !newFocus {
                        isEditing = false
                    }
                }
            } else {
                Button {
                    isEditing = true
                } label: {
                    Text("\(value)")
                        .font(.system(size: 40))
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .frame(height: 100)
                        .background(color.opacity(0.3))
                        .cornerRadius(18)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                }
            }
        }
    }
}


struct ShortCardView: View {
    var text: String
    var icon: String?
    var color: Color
    var shotType: ShotType?
    var onButtonPress: () -> Void  // Callback function
    

    var body: some View {
            
        Button {
            withAnimation {
                onButtonPress()
            }
        } label: {
            ZStack {
                
                Image(systemName: "figure.basketball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(color.opacity(0.2))
                    .frame(height: 40)
                    .offset(x: -50, y: 20)
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                    .rotationEffect(.degrees(10))
                
                Image(systemName: "basketball.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(color.opacity(0.2))
                    .frame(height: 70)
                    .offset(x: 17.5, y: 52.5)
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 2)
                        .frame(height: 100)
                        .offset(x: -15, y: -77)
                    
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 2)
                        .frame(height: 30)
                        .offset(x: -15, y: -47.5)
                }
                .rotationEffect(.degrees(-10))
                .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                Text("\(getShotPoints(for: shotType ?? .allShots)) pts")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .offset(x: 35, y: -22.5)
                    .rotationEffect(.degrees(12))
                    .foregroundStyle(color.opacity(0.2))
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                
                    
                    Text(text)
                        .font(.headline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .frame(width: 80, height: 50)
                        .foregroundStyle(color)
                
            }
            .frame(maxWidth: .infinity, maxHeight: 75)
            .background(.ultraThinMaterial)
            .background(color.opacity(0.33))
            .cornerRadius(20)
        }

    }
}

struct TallCardView: View {
    var text: String
    var icon: String
    var color: Color
    var shotType: ShotType?
    var onButtonPress: () -> Void  // Callback function
    

    var body: some View {
            
        Button {
            withAnimation {
                onButtonPress()
            }
        } label: {
            ZStack {
                
                Image(systemName: "figure.basketball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(color.opacity(0.2))
                    .frame(height: 40)
                    .offset(x: -52.5, y: 5)
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                    .rotationEffect(.degrees(10))
                
                Image(systemName: "basketball.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(color.opacity(0.2))
                    .frame(height: 70)
                    .offset(x: 17.5, y: 75)
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 2)
                        .frame(height: 250)
                        .offset(x: -15, y: -120)
                    
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 2)
                        .frame(height: 30)
                        .offset(x: -15, y: -85)
                }
                .rotationEffect(.degrees(-10))
                .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                Text("\(getShotPoints(for: shotType ?? .allShots)) pts")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .offset(x: 45, y: -25)
                    .rotationEffect(.degrees(12))
                    .foregroundStyle(color.opacity(0.2))
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                
                VStack(spacing: 0) {
                    Image(systemName: icon ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                        .foregroundStyle(color)
                    
                    Text(text)
                        .font(.headline)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .frame(width: 80, height: 50)
                        .foregroundStyle(color)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 155)
            .background(.ultraThinMaterial)
            .background(color.opacity(0.33))
            .cornerRadius(20)
        }

    }
}

#Preview {
    CardView()
}
