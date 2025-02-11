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
    @State var selectedTab = 0
    @State var shotType: ShotType = .allShots
    @State var customTime = false
    @State var customMinutes = 5
    @State var makes = 25
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            VStack(spacing: 10) {
                
                HStack {
                    
                    Image(systemName: "arrowshape.backward")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.title3)
                        .foregroundStyle(.clear)
                        .frame(width: 30)
                    
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
                        Image(systemName: "xmark.circle")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .frame(width: 30)
                    }
                }
                .padding(.vertical, 5)
                
                HStack(spacing: 10) {
                    HabitView(text: "Layups", icon: "basketball.fill", color: .red, shotType: .layups, onButtonPress: {
                                        selectedTab = 1
                                        shotType = .layups
                                    })
                    HabitView(text: "Free Throws", icon: "basketball.fill", color: .blue, shotType: .freeThrows, onButtonPress: {
                                                    selectedTab = 1
                                                    shotType = .freeThrows
                                                })
                    HabitView(text: "Midrange", icon: "basketball.fill", color: .blue, shotType: .midrange, onButtonPress: {
                                        selectedTab = 1
                                        shotType = .midrange
                                    })
                }
                HStack(spacing: 10) {
                    HabitView(text: "Threes", icon: "basketball.fill", color: .green, shotType: .threePointers, onButtonPress: {
                                            selectedTab = 1
                                            shotType = .threePointers
                                        })
                    HabitView(text: "Deep", icon: "basketball.fill", color: .purple, shotType: .deep, onButtonPress: {
                                                selectedTab = 1
                                                shotType = .deep
                                            })
                    HabitView(text: "Any Shots", icon: "basketball.fill", color: .orange, shotType: .allShots, onButtonPress: {
                                                selectedTab = 1
                                                shotType = .allShots
                                            })
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .tag(0)
            
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
                        Image(systemName: "arrowshape.backward")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .frame(width: 30)
                    }
                    
                    Spacer()
                    
                    Text("How long did you shoot for?")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.title3)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .frame(width: 30)
                    }
                }
                .padding(.vertical, 5)
                
                if false/*!customTime*/ {
                    HStack(spacing: 10) {
                        HabitView(text: "1 min", icon: "basketball.fill", color: .red, onButtonPress: { selectedTab = 2 })
                        HabitView(text: "5 min", icon: "basketball.fill", color: .blue, onButtonPress: { selectedTab = 2 })
                        HabitView(text: "10 min", icon: "basketball.fill", color: .green, onButtonPress: { selectedTab = 2 })
                    }
                    HStack(spacing: 10) {
                        HabitView(text: "20 min", icon: "basketball.fill", color: .purple, onButtonPress: { selectedTab = 2 })
                        HabitView(text: "30 min", icon: "basketball.fill", color: .orange, onButtonPress: { selectedTab = 2 })
                        HabitView(text: "Custom", icon: "basketball.fill", color: .gray, onButtonPress: { customTime = true })
                    }
                } else {
                    
                    HStack(spacing: 25) {
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                    customMinutes -= 1
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.title)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                                .frame(width: 25, height: 25)
                                .padding(5)
                                .background(.ultraThinMaterial)
                                .cornerRadius(5)
                        }
                        
                        VStack(spacing: 0) {
                            Text("\(customMinutes)")
                                .font(.system(size: 60))
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                                .frame(width: 80)
                            
                            Text("min")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                        }
                        .frame(width: 90)
                        .offset(y: 7.5)
                        
                        Button {
                            withAnimation {
                                if customMinutes < 60 {
                                    customMinutes += 1
                                }
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                                .frame(width: 25, height: 25)
                                .padding(5)
                                .background(.ultraThinMaterial)
                                .cornerRadius(5)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                selectedTab = 2
                            }
                        } label: {
                            Image(systemName: "checkmark.rectangle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 35)
                                .font(.title)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.green.opacity(0.75))
                                .padding(5)
                                .cornerRadius(5)
                        }
                        
                        Spacer()

                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .tag(1)
            
            VStack(spacing: 10) {
                HStack {
                    Button {
                        withAnimation {
                            selectedTab -= 1
                        }
                    } label: {
                        Image(systemName: "arrowshape.backward")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .frame(width: 30)
                    }
                    
                    Spacer()
                    
                    Text("How many shots were made?")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.title3)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .frame(width: 30)
                    }
                }
                .padding(.vertical, 5)
                
                HStack(spacing: 25) {
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            makes -= 1
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.gray)
                            .frame(width: 25, height: 25)
                            .padding(5)
                            .background(.ultraThinMaterial)
                            .cornerRadius(5)
                    }
                    
                    VStack(spacing: 0) {
                        Text("\(makes)")
                            .font(.system(size: 60))
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                        
                        Text("Shots")
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                    }
                    .frame(width: 90)
                    .offset(y: 7.5)
                    
                    Button {
                        withAnimation {
                            if makes < 99 {
                                makes += 1
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.gray)
                            .frame(width: 25, height: 25)
                            .padding(5)
                            .background(.ultraThinMaterial)
                            .cornerRadius(5)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            selectedTab = 3
                        }
                    } label: {
                        Image(systemName: "checkmark.rectangle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 35)
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.green.opacity(0.75))
                            .padding(5)
                            .cornerRadius(5)
                    }
                    
                    Spacer()
                    
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .tag(2)
            
            VStack {
                HStack {
                    Button {
                        withAnimation {
                            selectedTab -= 1
                        }
                    } label: {
                        Image(systemName: "arrowshape.backward")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .frame(width: 30)
                    }
                    
                    Spacer()
                    
                    Text("Everything look good?")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.title3)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .frame(width: 30)
                    }
                }
                .padding(.vertical, 5)
                
                SessionThumbnail(date: .now, makes: makes, length: customMinutes * 60, average: Double(makes) / (Double(customMinutes)), shotType: shotType)
                    .padding(.top, 5)
                
                HStack(spacing: 25) {
                    
                    Button {
                        withAnimation {
                            selectedTab = 2
                        }
                    } label: {
                        Image(systemName: "xmark.rectangle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 35)
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.red.opacity(0.75))
                            .padding(5)
                            .cornerRadius(5)
                    }
                    
                    Button {
                        var session = HoopSession(date: .now, makes: makes, length: customMinutes * 60, shotType: shotType)
                        withAnimation {
                            context.insert(session)
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark.rectangle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 35)
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.green.opacity(0.75))
                            .padding(5)
                            .cornerRadius(5)
                    }
                    
                }
                .padding(.top, 5)
                
                Spacer()
            }
            .padding(.horizontal)
            .tag(3)
        }
        .padding(.top, 12.5)
        .onAppear {
              UIScrollView.appearance().isScrollEnabled = false
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}


struct HabitView: View {
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
                    .frame(width: 75, height: 50)
                    .foregroundStyle(color)
            }
            .frame(maxWidth: .infinity, maxHeight: 75)
            .background(.ultraThinMaterial)
            .background(color.opacity(0.33))
            .cornerRadius(20)
        }

    }
}

#Preview {
    CardView()
}
