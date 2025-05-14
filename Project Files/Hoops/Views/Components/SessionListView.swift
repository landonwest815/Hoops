//
//  SessionListView.swift
//  Hoops
//
//  Created by Landon West on 4/10/25.
//

import SwiftUI
import SwiftData

/// A view that displays a list of HoopSession items organized by session type (e.g., "Freestyle", "Challenge", "Drill").
/// It also supports deletion and launching an editing detail view.
struct SessionListView: View {
    // MARK: - Properties
    
    /// All sessions loaded from the data store.
    let sessions: [HoopSession]
    /// The context used for data operations.
    let context: ModelContext
    /// The currently selected session (to show details).
    @Binding var selectedSession: HoopSession
    /// The selected date used to trigger scrolling or filtering.
    @Binding var selectedDate: Date
    /// Controls which shot types are visible based on user-selected filters.
    let shotTypeVisibility: [ShotType: Bool]
    /// Callback invoked when a session is selected.
    let onSessionSelected: () -> Void
    
    /// Used to store the session marked for deletion.
    @State private var sessionToDelete: HoopSession? = nil
    /// Controls whether the delete confirmation dialog is shown.
    @State private var showConfirmDelete: Bool = false
    
    /// A fixed list of session type names to ensure consistent grouping and ordering.
    let sessionTypes: [String] = ["Freestyle", "Challenge", "Drill"]
    
    
    // MARK: - Computed Properties
    
    /// Returns the sessions grouped by their session type.
    /// If no shot type filters are active, all sessions are shown; otherwise, only sessions whose shot type is visible.
    /// The grouping uses the rawValue of the sessionType to form groups.
    var groupedSessions: [String: [HoopSession]] {
        // Determine whether none of the shot type filters are active.
        let allTogglesOff = shotTypeVisibility.values.allSatisfy { !$0 }
        
        // If none are active, display all sessions; otherwise, filter sessions based on shotTypeVisibility.
        let filteredSessions = allTogglesOff ? sessions : sessions.filter { session in
            shotTypeVisibility[session.shotType] == true
        }
        
        // Group sessions by their session type's raw value.
        var grouped = Dictionary(grouping: filteredSessions, by: { $0.sessionType.rawValue })
        
        // Ensure that each expected session type exists in the dictionary, even if empty.
        for type in sessionTypes {
            if grouped[type] == nil {
                grouped[type] = []
            }
        }
        
        return grouped
    }
    
    
    // MARK: - Body
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 15) {
                    // An invisible spacer to allow smooth scrolling.
                    Color.clear
                        .frame(height: 1)
                    
                    // For each session type (ordered by sessionTypes array)
                    ForEach(sessionTypes, id: \.self) { sessionType in
                        VStack(alignment: .leading, spacing: 10) {
                            // Session type header with an icon and title.
                            HStack {
                                Image(systemName: iconName(for: sessionType))
                                Text(sessionType)
                                Spacer()
                            }
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 15)
                            .padding(.top, 5)
                            // A scroll transition that fades out the header when scrolling.
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    // You can uncomment scaleEffect or blur for additional effects.
                                    //.scaleEffect(phase.isIdentity ? 1 : 0.75)
                                    //.blur(radius: phase.isIdentity ? 0 : 10)
                            }
                            
                            // For the current session type, display a list of sessions if available.
                            if let sessions = groupedSessions[sessionType], !sessions.isEmpty {
                                ForEach(sessions, id: \.id) { session in
                                    SessionThumbnail(
                                        date: session.date,
                                        makes: session.makes,
                                        length: session.length,
                                        average: Double(session.makes) / (Double(session.length) / 60.0),
                                        shotType: session.shotType
                                    )
                                    .transition(.identity)
                                    // Context menu for editing or deleting the session.
                                    .contextMenu {
                                        Button {
                                            // Set the selected session and invoke the editing callback.
                                            selectedSession = session
                                            onSessionSelected()
                                        } label: {
                                            Label("Edit Session", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            // Mark the session for deletion.
                                            sessionToDelete = session
                                            showConfirmDelete = true
                                        } label: {
                                            Label("Delete Session", systemImage: "trash")
                                        }
                                    }
                                    // Also respond to a tap gesture by selecting the session.
                                    .onTapGesture {
                                        selectedSession = session
                                        onSessionSelected()
                                    }
                                    .frame(height: 75)
                                    // Use the session's ID to track scrolling changes.
                                    .id(session.id)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0.25)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                            // Additional effects (like blur) can be added if desired.
                                            //.blur(radius: phase.isIdentity ? 0 : 10)
                                    }
                                }
                            } else {
                                // If there are no sessions for this type, show a placeholder thumbnail.
                                PlaceholderThumbnail(prompt: promptText(for: sessionType))
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0.25)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                            //.blur(radius: phase.isIdentity ? 0 : 10)
                                    }
                            }
                        }
                    }
                    // Add extra spacing at the bottom to allow scrolling past the last content.
                    Spacer(minLength: 200)
                }
                // Hide scroll indicators and animate changes to the sessions array.
                .scrollIndicators(.hidden)
                .animation(.smooth, value: sessions)
            }
            // Additional scroll settings.
            .scrollIndicators(.hidden)
            // Use the selectedDate to control scrolling (for example, when the date filter changes).
            .id(selectedDate)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .ignoresSafeArea()
        }
        // Confirmation dialog for deleting a session.
        .confirmationDialog("Are you sure you want to delete this session?", isPresented: $showConfirmDelete, titleVisibility: .visible) {
            if let session = sessionToDelete {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        context.delete(session)
                    }
                    sessionToDelete = nil
                }
            }
            Button("Nevermind", role: .cancel) {
                sessionToDelete = nil
            }
        }
    }
    
    
    // MARK: - Helper Functions
    
    /// Returns the SF Symbol name for a session type.
    /// - Parameter sessionType: A string representing the session type.
    /// - Returns: The SF Symbol name associated with that session type.
    func iconName(for sessionType: String) -> String {
        switch sessionType {
        case "Freestyle": return "figure.cooldown"
        case "Challenge": return "figure.bowling"
        case "Drill": return "figure.basketball"
        default: return "questionmark.circle"
        }
    }
    
    /// Returns a color for the session type icon. (This helper isn't currently used in the view.)
    func iconColor(for sessionType: String) -> Color {
        switch sessionType {
        case "Freestyle": return .red
        case "Challenge": return .blue
        case "Drill": return .green
        default: return .white
        }
    }
    
    /// Returns a prompt text for the placeholder thumbnail for a given session type.
    /// - Parameter sessionType: A string representing the session type.
    /// - Returns: A friendly prompt for that session type.
    func promptText(for sessionType: String) -> String {
        switch sessionType {
        case "Freestyle": return "Shoot hoops!"
        case "Challenge": return "Challenge yourself!"
        case "Drill": return "Hit some Drills!"
        default: return "Shoot hoops!"
        }
    }
}


// MARK: - FloatingActionButton

/// A floating action button that can be used to trigger actions (e.g., adding a new session).
struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 15) {
            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 66)
                    
                    Image(systemName: "basketball.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundStyle(.orange)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(.gray.opacity(0.25))
                )
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom)
    }
}


// MARK: - HeaderView

/// Displays a header with the selected date and filter options.
struct HeaderView: View {
    @Binding var shotTypeVisibility: [ShotType: Bool]
    @Binding var selectedDate: Date
    
    @AppStorage(AppSettingsKeys.dateFormat) private var dateFormat: String = "M dd, yyyy"
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        HStack {
            // A button displaying the current date.
            Button(action: {
                // Action placeholder (e.g., show profile details)
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 18)
                    
                    Text(formattedDate)
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                // The following modifiers ensure smooth numeric transitions.
                .contentTransition(.numericText())
                .foregroundStyle(.orange)
                .fontWeight(.semibold)
                .frame(height: 20)
                .padding(.leading, 5)
            }
            Spacer()
            
            // Filter menu for shot type visibility.
            FilterMenuView(shotTypeVisibility: $shotTypeVisibility)
            
            // A button (with sort/filter icon) for additional actions.
            Button(action: {
                // Additional action for sorting or filtering can be added here.
            }) {
                Image(systemName: "arrow.up.arrow.down")
                    .buttonStyle()
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                            .foregroundColor(.gray.opacity(0.25))
                    )
            }
        }
        .padding(.horizontal)
    }
}


// MARK: - FilterMenuView

/// A menu that allows the user to filter the session list based on shot type.
struct FilterMenuView: View {
    @Binding var shotTypeVisibility: [ShotType: Bool]
    
    var body: some View {
        Menu {
            // Option to clear all selections (i.e., show all sessions).
            Button {
                withAnimation {
                    for key in shotTypeVisibility.keys {
                        shotTypeVisibility[key] = false
                    }
                }
            } label: {
                // Show "All Shots" with a checkmark if no filter is active.
                let anyShotSelected = shotTypeVisibility.values.contains(true)
                Label("All Shots", systemImage: anyShotSelected ? "" : "checkmark")
            }
            
            Divider()
            
            // Each subsequent button will clear existing selections and apply a single shot type filter.
            Button {
                withAnimation {
                    for key in shotTypeVisibility.keys {
                        shotTypeVisibility[key] = false
                    }
                    shotTypeVisibility[.layups] = true
                }
            } label: {
                Label("Layups", systemImage: shotTypeVisibility[.layups, default: false] ? "checkmark" : "")
            }
            
            Button {
                withAnimation {
                    for key in shotTypeVisibility.keys {
                        shotTypeVisibility[key] = false
                    }
                    shotTypeVisibility[.freeThrows] = true
                }
            } label: {
                Label("Free Throws", systemImage: shotTypeVisibility[.freeThrows, default: false] ? "checkmark" : "")
            }
            
            Button {
                withAnimation {
                    for key in shotTypeVisibility.keys {
                        shotTypeVisibility[key] = false
                    }
                    shotTypeVisibility[.midrange] = true
                }
            } label: {
                Label("Midrange", systemImage: shotTypeVisibility[.midrange, default: false] ? "checkmark" : "")
            }
            
            Button {
                withAnimation {
                    for key in shotTypeVisibility.keys {
                        shotTypeVisibility[key] = false
                    }
                    shotTypeVisibility[.threePointers] = true
                }
            } label: {
                Label("Threes", systemImage: shotTypeVisibility[.threePointers, default: false] ? "checkmark" : "")
            }
            
            Button {
                withAnimation {
                    for key in shotTypeVisibility.keys {
                        shotTypeVisibility[key] = false
                    }
                    shotTypeVisibility[.deep] = true
                }
            } label: {
                Label("Deep", systemImage: shotTypeVisibility[.deep, default: false] ? "checkmark" : "")
            }
        } label: {
            // The label for the filter menu shows an icon that changes color if any filter is active.
            Image(systemName: "line.3.horizontal.decrease")
                .aspectRatio(contentMode: .fit)
                .frame(width: 17.5, height: 17.5)
                .foregroundStyle(shotTypeVisibility.values.contains(true) ? .black.opacity(0.875) : .orange)
                .fontWeight(.semibold)
                .padding(6)
                .background(.ultraThinMaterial)
                .background(shotTypeVisibility.values.contains(true) ? .orange : .clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(.gray.opacity(shotTypeVisibility.values.contains(true) ? 0 : 0.25))
                )
        }
    }
}

#Preview {
    // Sample sessions for preview.
    @Previewable @State var selectedSession = HoopSession(date: Date(), makes: 15, length: 300, shotType: .layups, sessionType: .freestyle)
   
    
    SessionListView(
        sessions: [],
        context: HoopSession.preview.mainContext,
        selectedSession: $selectedSession,
        selectedDate: .constant(Date()),
        shotTypeVisibility: [
            .layups: true,
            .freeThrows: false,
            .midrange: false,
            .threePointers: false,
            .deep: false,
            .allShots: true
        ],
        onSessionSelected: { }
    )
    .modelContainer(HoopSession.preview)
}
