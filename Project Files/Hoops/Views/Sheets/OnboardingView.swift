//
//  OnboardingView.swift
//  Hoops
//
//  Created by Landon West on 05/15/25.
//

import SwiftUI

struct OnboardingView: View {
    /// Bind this to your ContentView’s @State showOnboarding
    @Binding var isPresented: Bool

    var body: some View {
        TabView {
            WelcomePage()
                .tag(0)

            Page1()
                .tag(1)

            Page2()
                .tag(2)

            Page3()
                .tag(3)

            Page4(isPresented: $isPresented)
                .tag(4)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }

    // MARK: –– Welcome Page
    struct WelcomePage: View {
        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                
                Image("curved2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.orange.opacity(0.8))

                Text("Welcome to Hoops!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your ultimate basketball companion.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .font(.body)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray)
                
                Spacer()
            }
            .padding()
            .padding(.bottom, 75)
        }
    }

    // MARK: –– Page 1
    struct Page1: View {
        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                
                HStack(spacing: 15) {
                    Image(systemName: "applewatch")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 125, height: 125)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                Text("Hoops uses your Apple Watch to track your shooting sessions. Make sure the Hoops companion app is installed on your watch. Accept the permission requests to allow Hoops to access your workout data.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .font(.body)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray)

                Spacer()
            }
            .padding()
        }
    }

    // MARK: –– Page 2
    struct Page2: View {
        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                
                HStack {
                    MetricButton(icon: "basketball.fill", title: "Sessions", value: "5", color: .orange, isSelected: false, variant: .compact, action: {})
                        .scaleEffect(0.75)
                        .opacity(0.75)
                    
                    MetricButton(icon: "scope", title: "Total Makes", value: "95", color: .red, isSelected: false, variant: .compact, action: {})
                    
                    MetricButton(icon: "chart.line.uptrend.xyaxis", title: "Avg Makes", value: "10", color: .blue, isSelected: false, variant: .compact, action: {})
                        .scaleEffect(0.75)
                        .opacity(0.75)
                }
                
                Text("Tap on any of the metric buttons under the Week View to get some insight into your performance. View session trends, total makes, and average makes over time.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .font(.body)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray)

                Spacer()
            }
            .padding()
        }
    }

    // MARK: –– Page 3
    struct Page3: View {
        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                
                StreakBadgeView(streak: 3)
                    .frame(width: 75, height: 30)
                    .background(.ultraThinMaterial)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                            .foregroundColor(.gray.opacity(0.25))
                    )
                
                Text("Keep your streak alive by hooping at least once a week. Every session you log grows your streak. Just don't miss a full week!")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .font(.body)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray)

                Spacer()
            }
            .padding()
        }
    }

    // MARK: –– Page 4
    struct Page4: View {
        @Binding var isPresented: Bool
        
        var body: some View {
                VStack(spacing: 24) {
                    Spacer()
                    
                    HStack {
                        
                        AccoladeView(accolade:
                            Accolade(
                                title: "Sessions",
                                value: 12,
                                thresholds: (bronze: 10, silver: 25, gold: 50),
                                icon: "basketball.fill")
                        )
                        .scaleEffect(0.75)
                        .frame(width: 110)

                        
                        AccoladeView(accolade:
                            Accolade(
                                title: "Makes",
                                value: 212,
                                thresholds: (bronze: 200, silver: 500, gold: 1000),
                                icon: "scope")
                        )
                        .frame(width: 125)
                        
                        AccoladeView(accolade:
                            Accolade(
                                title: "Days Hooped",
                                value: 7,
                                thresholds: (bronze: 7, silver: 30, gold: 100),
                                icon: "calendar")
                        )
                        .scaleEffect(0.75)
                        .frame(width: 110)

                    }
                    
                    Text("Earn accolades as you pour in the buckets. The more you shoot, the more you'll earn! \n\nTap \"hoops.\" up top to take a look! ")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .font(.body)
                        .fontDesign(.rounded)
                        .foregroundStyle(.gray)
                    
                                        
                    Button {
                        isPresented = false
                    } label: {
                        Text("Let's Hoop!")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .font(.headline)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                    
                    Spacer()
                    
                }
            
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var show = true
    OnboardingView(isPresented: $show)
}
