//
//  CardView.swift
//  Hoops
//
//  Created by Landon West on 1/28/25.
//

import SwiftUI

struct CardView: View {
    
    // MARK: - Environment and State
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab = -1
    @State private var shotType: ShotType = .allShots
    @State private var customTime = false
    @State private var minutes = 5
    @State private var seconds = 0
    @State private var makes = 25
    
    @FocusState private var isTextFieldFocused: Bool
    
    // Formatter for any potential usage
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // MARK: - Computed Properties
    
    // Determines the icon color based on the current shot type.
    private var iconColor: Color {
        switch shotType {
        case .freeThrows:    return .blue
        case .midrange:      return .blue
        case .layups:        return .red
        case .threePointers: return .green
        case .deep:          return .purple
        case .allShots:      return .orange
        }
    }
    
    // MARK: - Main Body
    var body: some View {
        TabView(selection: $selectedTab) {
            sessionTypeSelection
                .tag(-1)
            
            focusSelection
                .tag(0)
            
            detailEntry
                .tag(1)
        }
        .background(selectedTab == 1 ? iconColor.opacity(0.5) : Color.clear)
        .onAppear {
            UIScrollView.appearance().isScrollEnabled = false
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea(.all)
    }
    
    // MARK: - Tab Views
    
    // First tab: Session type selection.
    private var sessionTypeSelection: some View {
        VStack(spacing: 10) {
            headerForSessionTypeSelection
            HStack(spacing: 10) {
                TallCardView(
                    text: "Freestyle",
                    icon: "figure.cooldown",
                    color: .red,
                    onButtonPress: { selectSessionType(.layups, targetTab: 0) }
                )
                
                TallCardView(
                    text: "Challenge",
                    icon: "figure.bowling",
                    color: .blue,
                    onButtonPress: { selectSessionType(.freeThrows, targetTab: 0) }
                )
                
                TallCardView(
                    text: "Drill",
                    icon: "figure.basketball",
                    color: .green,
                    onButtonPress: { selectSessionType(.midrange, targetTab: 0) }
                )
            }
            Spacer()
        }
        .padding(.top, 12.5)
        .padding(.horizontal)
    }
    
    // Second tab: Focus selection.
    private var focusSelection: some View {
        VStack(spacing: 10) {
            headerForFocusSelection
            HStack(spacing: 10) {
                ShortCardView(
                    text: "Layups",
                    color: .red,
                    shotType: .layups,
                    onButtonPress: { selectSessionType(.layups, targetTab: 1) }
                )
                ShortCardView(
                    text: "Free Throws",
                    color: .blue,
                    shotType: .freeThrows,
                    onButtonPress: { selectSessionType(.freeThrows, targetTab: 1) }
                )
                ShortCardView(
                    text: "Midrange",
                    color: .blue,
                    shotType: .midrange,
                    onButtonPress: { selectSessionType(.midrange, targetTab: 1) }
                )
            }
            HStack(spacing: 10) {
                ShortCardView(
                    text: "Threes",
                    color: .green,
                    shotType: .threePointers,
                    onButtonPress: { selectSessionType(.threePointers, targetTab: 1) }
                )
                ShortCardView(
                    text: "Deep",
                    color: .purple,
                    shotType: .deep,
                    onButtonPress: { selectSessionType(.deep, targetTab: 1) }
                )
                ShortCardView(
                    text: "All Shots",
                    color: .orange,
                    shotType: .allShots,
                    onButtonPress: { selectSessionType(.allShots, targetTab: 1) }
                )
            }
            Spacer()
        }
        .padding(.top, 12.5)
        .padding(.horizontal)
    }
    
    // Third tab: Detail entry for session parameters.
    private var detailEntry: some View {
        VStack(spacing: 10) {
            detailEntryHeader
            detailEntryContent
            
            Spacer()
        }
        .padding(.top, 12.5)
        .padding(.horizontal)
    }
    
    // MARK: - Header Views
    
    private var headerForSessionTypeSelection: some View {
        HStack {
            // Invisible back button for layout symmetry.
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
    }
    
    private var headerForFocusSelection: some View {
        HStack {
            Button {
                withAnimation { selectedTab -= 1 }
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
    }
    
    private var detailEntryHeader: some View {
        HStack {
            Button {
                withAnimation { handleDetailBackAction() }
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
                withAnimation { insertSessionAndDismiss() }
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
    }
    
    // MARK: - Detail Entry Content & Decorations
    
    private var detailEntryContent: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                numberFieldView(title: "Min", value: $minutes)
                numberFieldView(title: "Sec", value: $seconds)
                numberFieldView(title: "Makes", value: $makes)
            }
        }
        .padding(.horizontal)
        .overlay(decorativeBackground)
    }
    
    /// A helper view that renders a titled editable number field.
    private func numberFieldView(title: String, value: Binding<Int>) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(iconColor)
            
            EditableNumberField(value: value, color: iconColor)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 150)
    }
    
    /// Decorative background images and shapes.
    private var decorativeBackground: some View {
        ZStack {
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
    }
    
    // MARK: - Action Handlers
    
    /// Updates both the selected tab and shot type.
    private func selectSessionType(_ type: ShotType, targetTab: Int) {
        withAnimation {
            shotType = type
            selectedTab = targetTab
        }
    }
    
    /// Handles the back action for the detail entry tab.
    private func handleDetailBackAction() {
        withAnimation {
            if customTime {
                customTime = false
            } else {
                selectedTab -= 1
            }
        }
    }
    
    /// Inserts a new session based on the current values and then dismisses the view.
    private func insertSessionAndDismiss() {
        let session = HoopSession(
            date: .now,
            makes: makes,
            length: minutes * 60 + seconds,
            shotType: shotType
        )
        context.insert(session)
        dismiss()
    }
}

// MARK: - Supporting Views

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
                .onChange(of: isFocused) { newFocus, _ in
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
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundColor(color.opacity(0.25))
        )
    }
}

struct ShortCardView: View {
    var text: String
    var icon: String? = nil
    var color: Color
    var shotType: ShotType?
    var onButtonPress: () -> Void  // Callback function
    
    var body: some View {
        Button {
            withAnimation { onButtonPress() }
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
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(color.opacity(0.25))
            )
        }
    }
}

struct TallCardView: View {
    var text: String
    var icon: String
    var color: Color
    var shotType: ShotType? = nil
    var onButtonPress: () -> Void  // Callback function
    
    var body: some View {
        Button {
            withAnimation { onButtonPress() }
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
                    Image(systemName: icon)
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
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(color.opacity(0.25))
            )
        }
    }
}

#Preview {
    CardView()
}
