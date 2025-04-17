//
//  Settings.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import SwiftUI
import SwiftData

struct Settings: View {
    // SwiftData
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Query var sessions: [HoopSession]
    @State private var showDeleteSheet = false
    
    var body: some View {
        ZStack {
            // Main Settings Content.
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
                .padding(.bottom, 15)
                
                // Button 1: App Icon
                UniformButton(
                    leftIconName: "square.fill",
                    leftText: "App Icon",
                    leftColor: .white
                ) {
                    Button {
                        // Action for App Icon
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.forward")
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(width: 100)
                }
                .padding()
                .cornerRadius(10)
                
                // Button 2: Accent Color
                UniformButton(
                    leftIconName: "paintbrush.pointed.fill",
                    leftText: "Accent Color",
                    leftColor: .white
                ) {
                    Button {
                        // Action for Accent Color
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.forward")
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(width: 100)
                }
                .padding()
                .cornerRadius(10)
                
                Divider()
                
                // Button 3: Date Format
                UniformButton(
                    leftIconName: "calendar",
                    leftText: "Date Format",
                    leftColor: .white
                ) {
                    DateFormatToggleButton()
                }
                .padding()
                .cornerRadius(10)
                
                // Button 4: Start of Week
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
                
                // Button 5: History
                UniformButton(
                    leftIconName: "list.clipboard.fill",
                    leftText: "History",
                    leftColor: .white
                ) {
                    Button {
                        // History action
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.forward")
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(width: 100)
                }
                .padding()
                .cornerRadius(10)
                
                // Button 6: App Data with Delete Option
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
                        Text("Delete Everything")
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .cornerRadius(10)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Inside your Settings view's body (within the ZStack)
            if showDeleteSheet {
                // A full-screen transparent layer that dismisses the sheet when tapped.
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showDeleteSheet = false
                        }
                    }
                    .zIndex(0) // Background layer for dismissal.
                
                // The bottom sheet itself.
                VStack {
                    Spacer()
                    DeleteConfirmationSheet(prompt: "Are you sure you want to delete everything?") {
                        withAnimation {
                            // Delete all sessions from the model.
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
        .padding(.top, 25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A custom confirmation sheet view that provides options to delete or cancel.
struct DeleteConfirmationSheet: View {
    let prompt: String
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(prompt)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            HStack {
                // Cancel Button.
                Button(action: {
                    onCancel()
                }) {
                    Text("Cancel")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
                // Delete Button.
                Button(action: {
                    onDelete()
                }) {
                    Text("Delete")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.red.opacity(0.33))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(red: 0.125, green: 0.125, blue: 0.125))
        .cornerRadius(28)
        .shadow(radius: 20)
        .padding(.horizontal)
    }
}




/// A customizable view that displays a uniform left section (icon + text) and flexible right content.
/// Depending on the `isButton` flag, it will either be interactive (using a Button) or just a plain view.
struct UniformButton<RightContent: View>: View {
    let leftIconName: String
    let leftText: String
    let leftColor: Color
    let rightContent: () -> RightContent
    
    // Consistent font styling for all instances.
    private let font: Font = .title3
    private let fontWeight: Font.Weight = .semibold
    private let fontDesign: Font.Design = .rounded

    var body: some View {
        HStack {
            // Left side: uniform icon and text.
            HStack(spacing: 15) {
                Image(systemName: leftIconName)
                Text(leftText)
            }
            .foregroundStyle(leftColor)
            
            Spacer()
            
            // Right side: customizable content.
            rightContent()
        }
        .font(font)
        .fontWeight(fontWeight)
        .fontDesign(fontDesign)
    }
}


struct DateFormatToggleButton: View {
    // A list of standard date format strings.
    private let formats = ["M dd, yyyy", "dd/MM/yyyy", "yyyy-MM-dd", "MMM d, yyyy"]
    // Index for the current format in the list.
    @State private var currentIndex: Int = 0
    
    var body: some View {
        Button {
            // Cycle through the formats.
            currentIndex = (currentIndex + 1) % formats.count
        } label: {
            Text(formats[currentIndex])
                .foregroundStyle(.gray)
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .contentTransition(.numericText())
        }
    }
}

struct StartOfWeekToggleButton: View {
    // List of week starting day names.
    private let days = ["Monday", "Sunday"]
    // Track the current index in the days array.
    @State private var currentIndex: Int = 0
    
    var body: some View {
        Button {
            // Cycle to the next day; when the end is reached, start over.
            currentIndex = (currentIndex + 1) % days.count
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
    return Settings()
        .modelContainer(HoopSession.preview)
}
