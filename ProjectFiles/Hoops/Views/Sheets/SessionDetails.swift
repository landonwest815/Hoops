//
//  SessionDetails.swift
//  Hoops
//
//  Created by Landon West on 2/11/25.
//

import SwiftUI

/// A view that displays detailed information and an editor for a single session.
/// It also allows the user to delete the session.
struct SessionDetails: View {
    // MARK: - Environment
    @Environment(\.modelContext) var context    // The data context for persistence.
    @Environment(\.dismiss) var dismiss           // Dismisses the current modal view.
    
    // MARK: - Bindings and State
    @Binding var session: HoopSession             // The session that is being displayed/edited.
    let dateFormatter = DateFormatter()           // Formatter for displaying the session's time.
    
    @State private var showConfirmDelete = false  // Flag to present the delete confirmation dialog.
    
    // MARK: - Computed Properties
    
    /// Determines the accent color based on the session's shot type.
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
    
    // MARK: - Initializer
    /// Initializes the view and sets up the date formatter.
    init(session: Binding<HoopSession>) {
        self._session = session
        // Set desired time format (e.g. "1:30 PM")
        dateFormatter.dateFormat = "h:mm a"
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            // The main container with a decorative background.
            ZStack {
                // Foreground content
                VStack(spacing: 10) {
                    // Header displaying the session information and delete button.
                    HStack {
                        // Left side: Icon and shot type description.
                        HStack {
                            // Display an icon based on the session type.
                            Image(systemName: iconName(for: session.sessionType.rawValue))
                                .font(.title3)
                            // Display the session's shot type.
                            Text(session.shotType.rawValue)
                                .font(.title2)
                        }
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        
                        Spacer()
                        
                        // Display the session's formatted time.
                        Text(dateFormatter.string(from: session.date))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                        
                        // Delete button to trigger a confirmation dialog.
                        Button {
                            showConfirmDelete = true
                        } label: {
                            Image(systemName: "trash.fill")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.white)
                        }
                        .padding(.leading)
                    }
                    .padding(5)
                    
                    // An editor view for modifying session details.
                    HStack(spacing: 0) {
                        HoopSessionEditorView(session: session, color: iconColor)
                            .frame(maxWidth: .infinity, maxHeight: 150)
                    }
                }
                
                // MARK: - Decorative Background Elements
                // These images and shapes provide visual decoration and ignore hit testing.
                Image(systemName: "figure.basketball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(iconColor.opacity(0.1))
                    .frame(height: 120)
                    .offset(x: -150, y: 110)
                    .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)
                    .rotationEffect(.degrees(10))
                    .allowsHitTesting(false)
                
                Image(systemName: "basketball.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(iconColor.opacity(0.1))
                    .frame(height: 300)
                    .offset(x: 60, y: 200)
                    .shadow(color: iconColor.opacity(0.66), radius: 5, x: 1.5)
                    .allowsHitTesting(false)
                
                ZStack {
                    // Two concentric circles to enhance the visual background.
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
                .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, maxHeight: 250)
            .padding()
            .background(iconColor.opacity(0.5))
        }
        // MARK: - Delete Confirmation Dialog
        .confirmationDialog("Are you sure you want to delete this session?", isPresented: $showConfirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                // Delete the session from the context and dismiss the view.
                context.delete(session)
                dismiss()
            }
            Button("Nevermind", role: .cancel) { }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Determines which icon to use based on the session type.
    /// - Parameter sessionType: A string representing the session type.
    /// - Returns: A system icon name for the session type.
    func iconName(for sessionType: String) -> String {
        switch sessionType {
        case "Freestyle": return "figure.cooldown"
        case "Challenge": return "figure.bowling"
        case "Drill":     return "figure.basketball"
        default:          return "questionmark.circle"
        }
    }
}

/// A subview for editing the session details (length and makes).
struct HoopSessionEditorView: View {
    @Bindable var session: HoopSession  // Allows two-way binding on the session object.
    var color: Color                   // The color used for styling based on the shot type.
    
    var body: some View {
        HStack(spacing: 15) {
            // Minutes input field.
            VStack(spacing: 5) {
                Text("Min")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(color)
                EditableNumberField(value: Binding(
                    get: { session.length / 60 },   // Convert seconds to minutes.
                    set: { session.length = ($0 * 60) + (session.length % 60) }
                ), color: color)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 150)
            
            // Seconds input field.
            VStack(spacing: 5) {
                Text("Sec")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(color)
                EditableNumberField(value: Binding(
                    get: { session.length % 60 },
                    set: { session.length = (session.length / 60 * 60) + $0 }
                ), color: color)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 150)
            
            // Makes input field.
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

// MARK: - Preview
#Preview {
    @Previewable @State var session = HoopSession(date: .now, makes: 15, length: 180, shotType: .threePointers)
    
    SessionDetails(session: $session)
        .modelContainer(HoopSession.preview)
}
