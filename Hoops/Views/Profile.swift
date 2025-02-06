//
//  Profile.swift
//  Hoops
//
//  Created by Landon West on 2/5/25.
//

import SwiftUI

struct Profile: View {
    
    @State var averageMakesPerMinute = 9.74
    
    var body: some View {
        ZStack(alignment: .top) {
            
            VStack(spacing: 25) {
                HStack(spacing: 12) {
                    
                    Text("My Hoopin' Career")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
//                    Circle()
//                        .frame(width: 5)
//                        .foregroundStyle(.gray)
//                    
//                    Text("Joined Aug 2024")
//                        .font(.subheadline)
//                        .fontWeight(.semibold)
//                        .fontDesign(.rounded)
//                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    
                    
//                    ZStack {
//                        Image(systemName: "flame.fill")
//                            .resizable()
//                            .frame(width: 35, height: 40)
//                        Image(systemName: "circle.fill")
//                            .resizable()
//                            .frame(width: 22, height: 22)
//                            .offset(y: 7)
//                        
//                        Text("\(3)")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .fontDesign(.rounded)
//                            .foregroundStyle(.white)
//                            .offset(x: -0.25, y: 3)
//                            .shadow(radius: 5)
//                            .contentTransition(.numericText())
//                    }
//                    .foregroundStyle(.red)
//                    .shadow(color: .red.opacity(0.25), radius: 5)
//                    .shadow(color: .red.opacity(0.125), radius: 12.5)
//                    .shadow(color: .red.opacity(0.05), radius: 20)
                    
                }
                
                
//                HStack {
//                    Image(systemName: "basketball.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundStyle(.blue)
//                        .frame(width: 75, height: 75)
//                }
//                .frame(height: 150)
                
                
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        
                        HStack {
                            //                        Image(systemName: "chart.bar.xaxis.ascending")
                            //                            .resizable()
                            //                            .aspectRatio(contentMode: .fit)
                            //                            .frame(height: 15)
                            //                            .foregroundStyle(.yellow)
                            //                            .fontWeight(.semibold)
                            
                            Text("Lifetime Stats")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 10) {
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "basketball.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 15)
                                        .foregroundStyle(.orange)
                                        .fontWeight(.semibold)
                                    
                                    
                                    Text("84")
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                        .fontWeight(.semibold)
                                        .contentTransition(.numericText())
                                        .foregroundStyle(.white)
                                }
                                
                                Text("Sessions")
                                    .font(.caption)
                                    .fontWeight(.regular)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 100)
                            .frame(height: 75)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "scope")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 16)
                                        .foregroundStyle(.red)
                                        .fontWeight(.semibold)
                                    
                                    
                                    Text("732")
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                        .fontWeight(.semibold)
                                        .contentTransition(.numericText())
                                        .foregroundStyle(.white)
                                }
                                
                                Text("Total Makes")
                                    .font(.caption)
                                    .fontWeight(.regular)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 100)
                            .frame(height: 75)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 16)
                                        .foregroundStyle(.blue)
                                        .fontWeight(.semibold)
                                        
                                    
                                    HStack(spacing: 5) {
                                        Text("\(averageMakesPerMinute, specifier: "%.2f")")
                                            .font(.headline)
                                            .fontDesign(.rounded)
                                            .fontWeight(.semibold)
                                            .contentTransition(.numericText())
                                            .foregroundStyle(.white)
                                        
                                        Text("/min")
                                            .font(.caption)
                                            .fontDesign(.rounded)
                                            .foregroundStyle(.gray)
                                            .offset(y: 1)
                                    }
                                }
                                
                                Text("Average Makes")
                                    .font(.caption)
                                    .fontWeight(.regular)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 150)
                            .frame(height: 75)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            
                        }
                        
                        
                        HStack(spacing: 10) {
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 15)
                                        .foregroundStyle(.green)
                                        .fontWeight(.semibold)
                                    
                                    
                                    Text("0d 18h 23m 37s")
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                        .fontWeight(.semibold)
                                        .contentTransition(.numericText())
                                        .foregroundStyle(.white)
                                }
                                
                                Text("Total Time Spent Hoopin'")
                                    .font(.caption)
                                    .fontWeight(.regular)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 16)
                                        .foregroundStyle(.purple)
                                        .fontWeight(.semibold)
                                    
                                    
                                    Text("14 days")
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                        .fontWeight(.semibold)
                                        .contentTransition(.numericText())
                                        .foregroundStyle(.white)
                                }
                                
                                Text("Days Hooped")
                                    .font(.caption)
                                    .fontWeight(.regular)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 150)
                            .frame(height: 75)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            
                        }
                        
                    }
                    
                    
                    VStack(spacing: 10) {
                        
                        HStack {
                            //                        Image(systemName: "trophy.fill")
                            //                            .resizable()
                            //                            .aspectRatio(contentMode: .fit)
                            //                            .frame(height: 15)
                            //                            .foregroundStyle(.yellow)
                            //                            .fontWeight(.semibold)
                            
                            Text("Records")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 10) {
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "basketball.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 15)
                                        .foregroundStyle(.orange)
                                        .fontWeight(.semibold)
                                    
                                    
                                    Text("7")
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                        .fontWeight(.semibold)
                                        .contentTransition(.numericText())
                                        .foregroundStyle(.white)
                                }
                                
                                Text("Most Sessions\n(in 1 Day)")
                                    .font(.caption2)
                                    .fontWeight(.regular)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 110)
                            .frame(height: 75)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "scope")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 16)
                                        .foregroundStyle(.red)
                                        .fontWeight(.semibold)
                                    
                                    
                                    Text("75")
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                        .fontWeight(.semibold)
                                        .contentTransition(.numericText())
                                        .foregroundStyle(.white)
                                }
                                
                                Text("Most Makes\n(in 1 Session)")
                                    .font(.caption2)
                                    .fontWeight(.regular)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 110)
                            .frame(height: 75)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 16)
                                        .foregroundStyle(.blue)
                                        .fontWeight(.semibold)
                                    
                                    HStack(spacing: 5) {
                                        Text("\(averageMakesPerMinute, specifier: "%.1f")")
                                            .font(.headline)
                                            .fontDesign(.rounded)
                                            .fontWeight(.semibold)
                                            .contentTransition(.numericText())
                                            .foregroundStyle(.white)
                                        
                                        Text("/min")
                                            .font(.caption2)
                                            .fontDesign(.rounded)
                                            .foregroundStyle(.gray)
                                            .offset(y: 1)
                                    }
                                }
                                
                                Text("Highest Average\n(in 1 Session)")
                                    .font(.caption2)
                                    .fontWeight(.regular)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .frame(height: 75)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            
                        }
                    }
                    
                    
                    VStack(spacing: 10) {
                        
                        HStack {
                            //                        Image(systemName: "trophy.fill")
                            //                            .resizable()
                            //                            .aspectRatio(contentMode: .fit)
                            //                            .frame(height: 15)
                            //                            .foregroundStyle(.yellow)
                            //                            .fontWeight(.semibold)
                            
                            Text("Accolades")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 10) {
                            
                            VStack {
                                
                                ZStack {
                                    Image(systemName: "trophy.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 100)
                                        .foregroundStyle(.brown)
                                    
                                    Image(systemName: "basketball.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 27.5)
                                            .foregroundStyle(.black.opacity(0.2))
                                            .offset(y: -20)
                                            .blendMode(.multiply)
                                            .shadow(color: .white.opacity(0.4), radius: 1, x: 1, y: 1)
                                            .shadow(color: .black.opacity(0.4), radius: 1, x: -1, y: -1)
                                }
                                
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 110)
                            .frame(height: 125)
                            
                            VStack(alignment: .leading) {
                                
                                ZStack {
                                    Image(systemName: "trophy.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 100)
                                        .foregroundStyle(.gray)
                                    
                                    Image(systemName: "scope")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .fontWeight(.semibold)
                                            .frame(width: 30)
                                            .foregroundStyle(.black.opacity(0.2))
                                            .offset(y: -20)
                                            .blendMode(.multiply)
                                            .shadow(color: .white.opacity(0.4), radius: 1, x: 1, y: 1)
                                            .shadow(color: .black.opacity(0.4), radius: 1, x: -1, y: -1)
                                }
                                
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 110)
                            .frame(height: 125)
                            
                            VStack(alignment: .leading) {
                                
                                ZStack {
                                    Image(systemName: "trophy.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 100)
                                        .foregroundStyle(.brown)
                                    
                                    Image(systemName: "calendar")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25)
                                            .foregroundStyle(.black.opacity(0.2))
                                            .offset(y: -20)
                                            .blendMode(.multiply)
                                            .shadow(color: .white.opacity(0.4), radius: 1, x: 1, y: 1)
                                            .shadow(color: .black.opacity(0.4), radius: 1, x: -1, y: -1)
                                }
                                
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .frame(maxWidth: 110)
                            .frame(height: 125)
                            
                        }
                    }
                    
                }
                
                Spacer()
            }
                        
//            ZStack(alignment: .top) {
//                
//                JerseySymbolView()
//                    .frame(width: 100)
//                
//                VStack(spacing: 5) {
//                    ResizableTextView(text: "west")
//
//                    Text("23")
//                        .font(.system(size: 120))
//                        .fontWeight(.semibold)
//                        .fontDesign(.rounded)
//                        .offset(y: -15)
//                }
//                .padding(.top, 20)
//            }
//            .ignoresSafeArea()
//            .offset(y: 350)
            
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //.background(.ultraThinMaterial)
            
    }
}

struct JerseySymbolView: View {
    var body: some View {
        ZStack {
            // Red-colored base
            Image(.jersey)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .foregroundStyle(.blue)

            // Jersey mesh texture masked inside the shape
            Image(.mesh)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 250, height: 250)
                .opacity(0.15)
                .blendMode(.multiply) // Helps blend texture with color
                .mask(
                    Image(.jersey)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                )
        }
        .offset(x: 3.5)
        .padding(.horizontal)
    }
}


struct ResizableTextView: View {
    let text: String
    let maxFontSize: CGFloat = 18 // Maximum font size
    
    var body: some View {
        GeometryReader { geometry in
            let characters = Array(text.uppercased())
            let count = characters.count
            let midIndex = count / 2
            let curveFactor: CGFloat = 1.2 // Adjust for a rounder curve
            let globalRotation: CGFloat = 2.5 // Slight clockwise rotation

            HStack(spacing: 5) { // Reduce spacing to keep letters closer
                ForEach(0..<count, id: \.self) { index in
                    let offset = CGFloat(index - midIndex) // Distance from middle
                    let angle = offset * 4.0 // Controls rotation effect
                    let yOffset = curveFactor * pow(offset, 2) * 0.7 // Quadratic curve for smooth rounding

                    Text(String(characters[index]))
                        .font(.system(size: min(maxFontSize, geometry.size.width * 1.25 / CGFloat(count))))
                        .fontWeight(.heavy)
                        .fontDesign(.rounded)
                        .rotationEffect(.degrees(angle)) // Rotates outward
                        .offset(y: yOffset) // Smooth downward curve
                        .minimumScaleFactor(0.01) // Allows shrinking within limits

                }
            }
            .rotationEffect(.degrees(globalRotation)) // Global slight clockwise shift
            .frame(width: geometry.size.width, height: geometry.size.height)
            .lineLimit(1)
        }
        .frame(width: 175, height: 50) // Fixed width and height
    }
}

#Preview {
    Profile()
}
