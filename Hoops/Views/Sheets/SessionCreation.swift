//
//  CardView.swift
//  Hoops
//
//  Created by Landon West on 1/28/25.
//

import SwiftUI

enum SessionTab: Int {
    case sessionTypeSelection = -1
    case focusSelection = 0
    case detailEntry = 1
}

// MARK: - Main CardView
// This view presents a multi-step tabbed interface for creating a new HoopSession.
// Users select a session type, a more detailed focus, and then enter specific session details.
struct SessionCreation: View {
    
    // MARK: - Environment and State
    @Environment(\.modelContext) var context        // Data context for inserting sessions.
    @Environment(\.dismiss) var dismiss               // Dismisses the current view.
    
    @State private var selectedTab: SessionTab = .sessionTypeSelection               // Controls the current tab in the TabView.
    @State private var shotType: ShotType = .allShots    // Currently selected shot type for the session.
    @State private var customTime = false              // Flag for custom time entry (not fully wired up).
    @State private var minutes = 5                     // Session duration minutes.
    @State private var seconds = 0                     // Session duration seconds.
    @State private var makes = 25                      // Number of made shots during the session.
    
    @FocusState private var isTextFieldFocused: Bool   // Used to focus editable fields.
    
    // Formatter for any potential usage
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // MARK: - Computed Properties
    
    /// Determines the icon color based on the current shot type.
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
            // First tab: Session type selection.
            sessionTypeSelection
                .tag(SessionTab.sessionTypeSelection)
            
            // Second tab: Focus selection (more granular shot types).
            focusSelection
                .tag(SessionTab.focusSelection)

            // Third tab: Entry of specific session details.
            detailEntry
                .tag(SessionTab.detailEntry)
        }
        // Change background color based on the selected tab.
        .background(selectedTab == .detailEntry ? iconColor.opacity(0.5) : Color.clear)
        .onAppear {
            // Disable scroll in the underlying UIScrollView for a page-like experience.
            UIScrollView.appearance().isScrollEnabled = false
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea(.all)
    }
    
    // MARK: - Tab Views
    
    /// First tab view: Allows the user to choose the type of session.
    private var sessionTypeSelection: some View {
        VStack(spacing: 10) {
            headerForSessionTypeSelection
            
            // Use TallCardView buttons for session type selection.
            HStack(spacing: 10) {
                TallCardView(
                    text: "Freestyle",
                    icon: "figure.cooldown",
                    color: .red,
                    onButtonPress: { selectSessionType(.layups, targetTab: .focusSelection) }
                )
                
                TallCardView(
                    text: "Challenge",
                    icon: "figure.bowling",
                    color: .blue,
                    onButtonPress: { selectSessionType(.freeThrows, targetTab: .focusSelection) }
                )
                
                TallCardView(
                    text: "Drill",
                    icon: "figure.basketball",
                    color: .green,
                    onButtonPress: { selectSessionType(.midrange, targetTab: .focusSelection) }
                )
            }
            Spacer()
        }
        .padding(.top, 12.5)
        .padding(.horizontal)
    }
    
    /// Second tab view: Provides more detailed focus options (shot type filtering).
    private var focusSelection: some View {
        VStack(spacing: 10) {
            headerForFocusSelection
            
            // Two rows of ShortCardView buttons for specific shot types.
            HStack(spacing: 10) {
                ShortCardView(
                    text: "Layups",
                    color: .red,
                    shotType: .layups,
                    onButtonPress: { selectSessionType(.layups, targetTab: .detailEntry) }
                )
                ShortCardView(
                    text: "Free Throws",
                    color: .blue,
                    shotType: .freeThrows,
                    onButtonPress: { selectSessionType(.freeThrows, targetTab: .detailEntry) }
                )
                ShortCardView(
                    text: "Midrange",
                    color: .blue,
                    shotType: .midrange,
                    onButtonPress: { selectSessionType(.midrange, targetTab: .detailEntry) }
                )
            }
            HStack(spacing: 10) {
                ShortCardView(
                    text: "Threes",
                    color: .green,
                    shotType: .threePointers,
                    onButtonPress: { selectSessionType(.threePointers, targetTab: .detailEntry) }
                )
                ShortCardView(
                    text: "Deep",
                    color: .purple,
                    shotType: .deep,
                    onButtonPress: { selectSessionType(.deep, targetTab: .detailEntry) }
                )
                ShortCardView(
                    text: "All Shots",
                    color: .orange,
                    shotType: .allShots,
                    onButtonPress: { selectSessionType(.allShots, targetTab: .detailEntry) }
                )
            }
            Spacer()
        }
        .padding(.top, 12.5)
        .padding(.horizontal)
    }
    
    /// Third tab view: Allows the user to enter session details like duration and makes.
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
    
    /// Header for the session type selection tab.
    private var headerForSessionTypeSelection: some View {
        HStack {
            // Invisible back button for symmetry.
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
    
    /// Header for the focus selection tab.
    private var headerForFocusSelection: some View {
        HStack {
            // Back button to return to the previous tab.
            Button {
                withAnimation { selectedTab = .sessionTypeSelection }
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
    
    /// Header for the detail entry tab.
    private var detailEntryHeader: some View {
        HStack {
            // Back button to return from detail entry.
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
            
            // Display the current shot type name.
            Text(shotType.rawValue)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .font(.title3)
                .foregroundStyle(.white)
            
            Spacer()
            
            // Confirmation button to insert the new session.
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
    
    /// Contains numeric entry fields for session duration and made shots.
    private var detailEntryContent: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                // Number fields for minutes, seconds, and makes.
                numberFieldView(title: "Min", value: $minutes)
                numberFieldView(title: "Sec", value: $seconds)
                numberFieldView(title: "Makes", value: $makes)
            }
        }
        .padding(.horizontal)
        .overlay(decorativeBackground)
    }
    
    /// Returns an editable number field with a title.
    private func numberFieldView(title: String, value: Binding<Int>) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(iconColor)
            
            // Custom number field that allows editing.
            EditableNumberField(value: value, color: iconColor)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 150)
    }
    
    /// Provides decorative background elements (images, shapes, and shadows) for the detail entry.
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
    
    /// Updates both the selected shot type and switches the tab.
    /// - Parameters:
    ///   - type: The selected shot type.
    ///   - targetTab: The target tab to switch to.
    private func selectSessionType(_ type: ShotType, targetTab: SessionTab) {
        withAnimation {
            shotType = type
            selectedTab = targetTab
        }
    }
    
    /// Handles the back action in the detail entry tab.
    /// If customTime is set, it resets it; otherwise it goes back one tab.
    private func handleDetailBackAction() {
        withAnimation {
            if customTime {
                customTime = false
            } else {
                selectedTab = .focusSelection
            }
        }
    }
    
    /// Constructs a new HoopSession from the current values, inserts it into the data context, and dismisses the view.
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

// MARK: - Supporting Editable Number Field
/// A custom view that displays a number which can be tapped to switch into a text field for editing.
struct EditableNumberField: View {
    @Binding var value: Int
    @FocusState private var isFocused: Bool
    @State private var isEditing: Bool = false
    var color: Color
    
    var body: some View {
        ZStack {
            if isEditing {
                // Editable text field version.
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
                    // A short delay ensures the text field properly receives focus.
                    DispatchQueue.main.async {
                        isFocused = true
                    }
                }
                .onChange(of: isFocused) { _, newFocus in
                    if !newFocus {
                        isEditing = false
                    }
                }
                .onSubmit {
                    isFocused = false
                    isEditing = false
                }
            } else {
                // Non-editable button version displaying the value.
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

// MARK: - ShortCardView
/// A compact card view used in the focus selection tab.
/// It displays an image background along with a text label and a points value.
/// Note: `getShotPoints(for:)` is assumed to be defined elsewhere.
struct ShortCardView: View {
    var text: String
    var icon: String? = nil
    var color: Color
    var shotType: ShotType?
    var onButtonPress: () -> Void  // Callback function for when the button is pressed.
    
    var body: some View {
        Button {
            withAnimation { onButtonPress() }
        } label: {
            ZStack {
                // Background design using basketball related images and shapes.
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
                
                // Additional circular decorative shapes.
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
                
                // Display shot points; uses an external function `getShotPoints(for:)`.
                Text("\(getShotPoints(for: shotType ?? .allShots)) pts")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .offset(x: 35, y: -22.5)
                    .rotationEffect(.degrees(12))
                    .foregroundStyle(color.opacity(0.2))
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                // Text label for the shot type.
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

// MARK: - TallCardView
/// A larger card view used in the session type selection tab.
/// It displays an icon, descriptive text, and shot points.
/// Note: `getShotPoints(for:)` is assumed to be defined elsewhere.
struct TallCardView: View {
    var text: String
    var icon: String
    var color: Color
    var shotType: ShotType? = nil
    var onButtonPress: () -> Void  // Callback function for when the button is pressed.
    
    var body: some View {
        Button {
            withAnimation { onButtonPress() }
        } label: {
            ZStack {
                // Background design with basketball themed images.
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
                
                // Additional circular decorative shapes.
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
                
                // Display shot points; uses an external function `getShotPoints(for:)`.
                Text("\(getShotPoints(for: shotType ?? .allShots)) pts")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .offset(x: 45, y: -25)
                    .rotationEffect(.degrees(12))
                    .foregroundStyle(color.opacity(0.2))
                    .shadow(color: color.opacity(0.66), radius: 5, x: 1.5)
                
                // Icon and descriptive text stacked vertically.
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
        }
    }
}

#Preview {
    SessionCreation()
        .modelContainer(HoopSession.preview)
}
