import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            WelcomePage(currentPage: $currentPage).tag(0)
            NotificationPage(currentPage: $currentPage).tag(1)
            Page1(currentPage: $currentPage).tag(2)
            Page2(currentPage: $currentPage).tag(3)
            Page3(currentPage: $currentPage).tag(4)
            Page4(isPresented: $isPresented).tag(5)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }

    struct WelcomePage: View {
        @Binding var currentPage: Int

        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                Image("curved2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.orange.opacity(0.8))
                Text("Welcome to Hoops!")
                    .font(.largeTitle).fontWeight(.bold)
                Text("Your ultimate basketball companion.")
                    .font(.body).fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                Spacer()
                Button {
                    withAnimation { currentPage += 1 }
                } label: {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.gray)
                        .fontWeight(.bold).fontDesign(.rounded)
                        .frame(width: 100)
                        .padding(.vertical, 12).padding(.horizontal, 24)
                        .background(.ultraThinMaterial).cornerRadius(25)
                }
                .buttonStyle(.borderless)
            }
            .padding()
        }
    }
    
    struct NotificationPage: View {
        @Binding var currentPage: Int
        @EnvironmentObject var watchConnector: WatchConnector

        var body: some View {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "bell.badge.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.white.opacity(0.8))

                Text("Stay in the Loop")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Allow notifications so we can remind you about streaks, summaries, and more.")
                    .font(.body)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)

                Spacer()

                Button {
                    watchConnector.requestNotificationPermission()
                    withAnimation { currentPage += 1 }
                } label: {
                   Text("Enable Notifications")
                        .foregroundStyle(.gray)
                        .fontWeight(.bold).fontDesign(.rounded)
                        .padding(.vertical, 12).padding(.horizontal, 24)
                        .background(.ultraThinMaterial).cornerRadius(25)
                }
                .buttonStyle(.borderless)

                Button("Skip") {
                    withAnimation { currentPage += 1 }
                }
                .foregroundStyle(.gray)

            }
            .padding()
        }
    }

    struct Page1: View {
        @Binding var currentPage: Int

        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "applewatch")
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.white.opacity(0.8))
                Text("Hoops is designed around the Apple Watch to track your shooting sessions with ease.")
                    .font(.body).fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                Text("Make sure to allow all permission requests when prompted to allow smooth shooting sessions.")
                    .font(.body).fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.red)
                Spacer()
                Button {
                    withAnimation { currentPage += 1 }
                } label: {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.gray)
                        .fontWeight(.bold).fontDesign(.rounded)
                        .frame(width: 100)
                        .padding(.vertical, 12).padding(.horizontal, 24)
                        .background(.ultraThinMaterial).cornerRadius(25)
                }
                .buttonStyle(.borderless)
            }
            .padding()
        }
    }

    struct Page2: View {
        @Binding var currentPage: Int

        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                HStack(spacing: 15) {
                    MetricButton(icon: "basketball.fill", title: "Sessions", value: "5", color: .orange, isSelected: false, variant: .compact) {}
                        .scaleEffect(0.75).opacity(0.75)
                    MetricButton(icon: "scope", title: "Total Makes", value: "95", color: .red, isSelected: false, variant: .compact) {}
                    MetricButton(icon: "chart.line.uptrend.xyaxis", title: "Avg Makes", value: "10", color: .blue, isSelected: false, variant: .compact) {}
                        .scaleEffect(0.75).opacity(0.75)
                }
                Text("Tap on any of the metric buttons under the Week View to get some insight into your performance. View session trends, total makes, and average makes over time.")
                    .font(.body).fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                Spacer()
                Button {
                    withAnimation { currentPage += 1 }
                } label: {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.gray)
                        .fontWeight(.bold).fontDesign(.rounded)
                        .frame(width: 100)
                        .padding(.vertical, 12).padding(.horizontal, 24)
                        .background(.ultraThinMaterial).cornerRadius(25)
                }
                .buttonStyle(.borderless)
            }
            .padding()
        }
    }

    struct Page3: View {
        @Binding var currentPage: Int

        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                StreakBadgeView(streak: 3)
                    .frame(width: 75, height: 30)
                    .background(.ultraThinMaterial).cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(style: StrokeStyle(lineWidth: 1)).foregroundColor(.gray.opacity(0.25)))
                    .scaleEffect(1.25)
                Text("Keep your streak alive by hooping at least once a week. Every session you log grows your streak. Just don't miss a full week!")
                    .font(.body).fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                Spacer()
                Button {
                    withAnimation { currentPage += 1 }
                } label: {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.gray)
                        .fontWeight(.bold).fontDesign(.rounded)
                        .frame(width: 100)
                        .padding(.vertical, 12).padding(.horizontal, 24)
                        .background(.ultraThinMaterial).cornerRadius(25)
                }
                .buttonStyle(.borderless)
            }
            .padding()
        }
    }

    struct Page4: View {
        @Binding var isPresented: Bool

        var body: some View {
            VStack(spacing: 24) {
                Spacer()
                HStack {
                    AccoladeView(accolade: Accolade(title: "Sessions", value: 52, thresholds: (10, 25, 50), icon: "basketball.fill"))
                        .scaleEffect(0.75).frame(width: 110)
                    AccoladeView(accolade: Accolade(title: "Makes", value: 212, thresholds: (200, 500, 1000), icon: "scope"))
                        .frame(width: 125)
                    AccoladeView(accolade: Accolade(title: "Days Hooped", value: 31, thresholds: (7, 30, 100), icon: "calendar"))
                        .scaleEffect(0.75).frame(width: 110)
                }
                Text("Earn accolades as you pour in the buckets. The more you shoot, the more you'll earn!\n\nTap \"hoops.\" up top to take a look!")
                    .font(.body).fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                Spacer()
                Button {
                    withAnimation { isPresented = false }
                } label: {
                    Text("Let's Hoop!")
                        .foregroundStyle(.gray)
                        .fontWeight(.bold).fontDesign(.rounded)
                        .frame(width: 100)
                        .padding(.vertical, 12).padding(.horizontal, 24)
                        .background(.ultraThinMaterial).cornerRadius(25)
                }
                .buttonStyle(.borderless)
            }
            .padding()
        }
    }
}

#Preview {
    @Previewable @State var show = true
    OnboardingView(isPresented: $show)
}
