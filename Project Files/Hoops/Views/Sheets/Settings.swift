//
//  Settings.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import SwiftUI
import SwiftData


enum AppSettingsKeys {
    static let dateFormat = "M dd, yyyy"
    static let startOfWeek = "Sunday"
}



struct Settings: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Query var sessions: [HoopSession]
    
    @State private var showDeleteSheet = false
    @State private var currentIconName: String? = UIApplication.shared.alternateIconName
    
   // @State private var showHistory: Bool = false
    
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ZStack {
                VStack(spacing: 5) {
                    HStack(spacing: 12) {
                        Text("My Settings")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 25)
                    
                    VStack(spacing: 0) {
                        UniformButton(
                            leftIconName: "square.filled.on.square",
                            leftText: "App Icon",
                            leftColor: .white
                        ) { EmptyView() }
                            .padding()
                            .cornerRadius(10)
                        
                        // App Icon Picker
                        HStack(spacing: 25) {
                            appIconButton(name: nil, image: "iconImage0")
                            appIconButton(name: "AppIcon1", image: "iconImage1")
                            appIconButton(name: "AppIcon2", image: "iconImage2")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 3)
                        .padding(.bottom)
                        .cornerRadius(10)
                    }
    
                    
                    Divider()
                    
                    UniformButton(
                        leftIconName: "calendar",
                        leftText: "Date Format",
                        leftColor: .white
                    ) {
                        DateFormatToggleButton()
                    }
                    .padding()
                    .cornerRadius(10)
                    
                    UniformButton(
                        leftIconName: "1.circle.fill",
                        leftText: "Start of Week",
                        leftColor: .white
                    ) {
                        StartOfWeekToggleButton()
                    }
                    .padding()
                    .cornerRadius(10)
                    
                    Divider()
                    
//                    UniformButton(
//                        leftIconName: "list.clipboard.fill",
//                        leftText: "History",
//                        leftColor: .white
//                    ) {
//                        Button {
//                            showHistory = true
//                        } label: {
//                            HStack {
//                                Spacer()
//                                Text("Show me")
//                                    .font(.title3)
//                                    .fontWeight(.semibold)
//                                    .fontDesign(.rounded)
//                                    .foregroundStyle(.gray)
//                            }
//                        }
//                        .frame(width: 100)
//                    }
//                    .padding()
//                    .cornerRadius(10)
                    
                    UniformButton(
                        leftIconName: "questionmark.circle.fill",
                        leftText: "Onboarding",
                        leftColor: .white
                    ) {
                        Button {
                            dismiss()
                            showOnboarding = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Show me")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .frame(width: 100)
                    }
                    .padding()
                    .cornerRadius(10)
                    
                    Divider()
                    
                    UniformButton(
                        leftIconName: "archivebox.fill",
                        leftText: "App Data",
                        leftColor: .white
                    ) {
                        Button {
                            withAnimation {
                                showDeleteSheet = true
                            }
                        } label: {
                            Text("Full Reset")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .cornerRadius(10)
                    
                    Spacer()

                    VStack(spacing: 10) {
                        
                        Text("Made with ❤️ by Landon West")

                        HStack {
                            
                            
                            Text("© 2025")
                                                        
                            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                    
                }
                .padding(.horizontal)
//                .navigationDestination(isPresented: $showHistory) {
//                    SessionHistoryView() // This should be the view showing all sessions
//                }
            
            
            if showDeleteSheet {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showDeleteSheet = false }
                    }
                    .zIndex(0)
                
                VStack {
                    Spacer()
                    DeleteConfirmationSheet(prompt: "Are you sure you want to delete all of your Hoops data?", subprompt: "This cannot be undone.") {
                        withAnimation {
                            for session in sessions {
                                context.delete(session)
                            }
                            showDeleteSheet = false
                        }
                    } onCancel: {
                        withAnimation {
                            showDeleteSheet = false
                        }
                    }
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        //.padding(.top, 25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - App Icon Helper
    
    private func appIconButton(name: String?, image: String) -> some View {
        Button {
            withAnimation {
                switchAppIcon(to: name)
            }
        } label: {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 75, height: 75)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(selectionOverlay(for: name))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
        }
    }
    
    private func switchAppIcon(to name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        UIApplication.shared.setAlternateIconName(name) { error in
            if let error = error {
                print("Failed to switch icon: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    currentIconName = name
                }
            }
        }
    }
    
    private func selectionOverlay(for iconName: String?) -> some View {
        RoundedRectangle(cornerRadius: 18)
            .stroke(
                Color.white.opacity(currentIconName == iconName ? 0.66 : 0),
                lineWidth: currentIconName == iconName ? 2.5 : 0
            )
            .animation(.easeInOut(duration: 0.25), value: currentIconName)
    }
}

// MARK: - Supporting Views


struct DeleteConfirmationSheet: View {
    let prompt: String
    let subprompt: String
    let onDelete: () -> Void
    let onCancel: () -> Void

    @GestureState private var isPressing = false
    @State private var didComplete = false
    @State private var fillProgress: CGFloat = 0
    @StateObject private var haptics = HapticManager()

    var body: some View {
        VStack(spacing: 20) {
            // MARK: Prompts
            VStack(spacing: 10) {
                Text(prompt)
                Text(subprompt)
                    .foregroundStyle(.gray)
            }
            .font(.headline)
            .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                // Cancel button
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.title3).fontWeight(.semibold)
                        .foregroundStyle(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }

                // Delete long-press
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.red.opacity(0.33))
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: geo.size.width * fillProgress)
                        Text("Delete")
                            .font(.title3).fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                    .scaleEffect(didComplete ? 1.05 : 1)
                    .gesture(
                        LongPressGesture(minimumDuration: 1)
                            .updating($isPressing) { cur, state, _ in state = cur }
                            .onEnded { _ in
                                // stop continuous rumble
                                haptics.stopRumble()
                                // click haptic
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                                // pulse
                                withAnimation(.easeOut(duration: 0.15)) { didComplete = true }
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.15) {
                                    withAnimation(.easeIn(duration: 0.15)) { didComplete = false }
                                }

                                // finally fire delete after full pulse
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                                    onDelete()
                                    fillProgress = 0
                                }
                            }
                    )
                    .onChange(of: isPressing) { pressing in
                        if pressing && !didComplete {
                            // start continuous rumble & fill
                            haptics.startRumble()
                            withAnimation(.linear(duration: 1)) { fillProgress = 1 }
                        } else if !pressing && !didComplete {
                            // canceled early
                            haptics.stopRumble()
                            withAnimation(.easeOut(duration: 0.1)) { fillProgress = 0 }
                        }
                    }
                }
                .frame(height: 50)
            }
        }
        .padding()
        .background(Color(red: 0.125, green: 0.125, blue: 0.125))
        .cornerRadius(28)
        .shadow(radius: 20)
        .padding(.horizontal)    }
}


import CoreHaptics

/// Manages a continuous haptic pattern
class HapticManager: ObservableObject {
    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?

    init() { prepare() }

    private func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("⚠️ haptics failed:", error)
        }
    }

    /// Start a long‐running rumble (we’ll stop it manually)
    func startRumble() {
        guard let engine = engine else { return }
        // continuous event with moderate intensity/sharpness
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                .init(parameterID: .hapticIntensity, value: 0.5),
                .init(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0,
            duration: 10  // long enough; we’ll stop early
        )
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            player = try engine.makeAdvancedPlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("⚠️ failed to start rumble:", error)
        }
    }

    /// Stop any ongoing rumble
    func stopRumble() {
        do {
            try player?.stop(atTime: CHHapticTimeImmediate)
        } catch {
            print("⚠️ failed to stop rumble:", error)
        }
    }
}



struct UniformButton<RightContent: View>: View {
    let leftIconName: String
    let leftText: String
    let leftColor: Color
    let rightContent: () -> RightContent

    private let font: Font = .title3
    private let fontWeight: Font.Weight = .semibold
    private let fontDesign: Font.Design = .rounded

    var body: some View {
        HStack {
            HStack(spacing: 15) {
                Image(systemName: leftIconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 22.5)
                Text(leftText)
            }
            .foregroundStyle(leftColor)
            Spacer()
            rightContent()
        }
        .font(font)
        .fontWeight(fontWeight)
        .fontDesign(fontDesign)
    }
}

struct DateFormatToggleButton: View {
    private let formats = [
        "MM/dd/yyyy",     // e.g., 07/15/2025
        "MMM d, yyyy",    // e.g., Jul 15, 2025

        "MMM d",          // e.g., Jul 15
        "M/dd",           // e.g., 7/15
        "EEEE, MMM d",    // e.g., Tuesday, Jul 15
        "d MMM",          // e.g., 15 Jul
        "EEEE d"          // e.g., Tuesday 15
    ]
    
    @AppStorage(AppSettingsKeys.dateFormat) private var selectedFormat: String = "M dd, yyyy"
    
    var body: some View {
        let currentIndex = formats.firstIndex(of: selectedFormat) ?? 0
        let previewText = DateFormatter.formatted(date: Date(), with: selectedFormat)

        return Button {
            let nextIndex = (currentIndex + 1) % formats.count
            selectedFormat = formats[nextIndex]
        } label: {
            Text(previewText)
                .foregroundStyle(.gray)
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .contentTransition(.numericText())
        }
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static func formatted(date: Date, with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}



struct StartOfWeekToggleButton: View {
    private let days = ["Monday", "Sunday"]
    
    @AppStorage(AppSettingsKeys.startOfWeek) private var selectedDay: String = "Sunday"
    
    var body: some View {
        let currentIndex = days.firstIndex(of: selectedDay) ?? 0

        Button {
            let nextIndex = (currentIndex + 1) % days.count
            selectedDay = days[nextIndex]
        } label: {
            Text(days[currentIndex])
                .foregroundStyle(.gray)
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .contentTransition(.numericText())
        }
    }
}


#Preview {
    @Previewable @State var showOnboarding = false
    Settings(showOnboarding: $showOnboarding).modelContainer(HoopSession.preview)
}
