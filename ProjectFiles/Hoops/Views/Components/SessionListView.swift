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
    
    let sortMode: SortMode

    /// Callback invoked when a session is selected.
    let onSessionSelected: () -> Void
    
    /// Used to store the session marked for deletion.
    @State private var sessionToDelete: HoopSession? = nil
    /// Controls whether the delete confirmation dialog is shown.
    @State private var showConfirmDelete: Bool = false
    
    /// A fixed list of session type names to ensure consistent grouping and ordering.
    let sessionTypes: [String] = ["Freestyle", "Challenge", "Drill"]
    
    private var filteredSessionsForDay: [HoopSession] {
        sessions.filter { $0.date.startOfDay == selectedDate.startOfDay }
    }

    
    // MARK: - Computed Properties
    
    /// Returns the sessions grouped by their session type.
    /// If no shot type filters are active, all sessions are shown; otherwise, only sessions whose shot type is visible.
    /// The grouping uses the rawValue of the sessionType to form groups.
    var groupedSessions: [String: [HoopSession]] {
        
        let base = filteredSessionsForDay
        let allTogglesOff = shotTypeVisibility.values.allSatisfy { !$0 }
        let filteredSessions = allTogglesOff ? base : base.filter {
            shotTypeVisibility[$0.shotType] == true
        }

        // Group sessions by session type.
        var grouped = Dictionary(grouping: filteredSessions, by: { $0.sessionType.rawValue })

        // Ensure every expected session type is in the dictionary.
        for type in sessionTypes {
            if grouped[type] == nil {
                grouped[type] = []
            }
        }

        // Sort each group by date according to sort preference.
        for type in grouped.keys {
            switch sortMode {
            case .byTime:
                grouped[type]?.sort { $0.date > $1.date }  // always newest first

            case .byShotType:
                let order: [ShotType] = [.layups, .freeThrows, .midrange, .threePointers, .deep, .allShots]
                grouped[type]?.sort {
                    guard let i1 = order.firstIndex(of: $0.shotType),
                          let i2 = order.firstIndex(of: $1.shotType) else { return false }
                    return i1 < i2
                }
            }
        }

        return grouped
    }
    
    
    // 1. Track which quote to show and persist across launches
    @AppStorage("quoteIndex") private var quoteIndex: Int = -1
    @State private var displayedQuote: String = ""
    
    // 2. Your list of quotes
    let quotes: [String] = [
        "I've missed more than 9,000 shots in my career. I've lost almost 300 games. Twenty-six times, I've been trusted to take the game-winning shot and missed. I've failed over and over and over again in my life. And that is why I succeed.\n- Michael Jordan",
        "The most important thing is to try and inspire people so that they can be great in whatever they want to do.\n- Kobe Bryant",
        "I've got a theory that if you give 100% all of the time, somehow things will work out in the end.\n- Larry Bird",
        "Ask not what your teammates can do for you. Ask what you can do for your teammates.\n- Magic Johnson",
        "You can't be afraid to fail. It's the only way you succeed—you’re not gonna succeed all the time, and I know that.\n- LeBron James",
        "Good, better, best. Never let it rest. Until your good is better and your better is best.\n- Tim Duncan",
        "Hard work beats talent when talent fails to work hard.\n- Kevin Durant",
        "Excellence is not a singular act, but a habit. You are what you repeatedly do.\n- Shaquille O’Neal",
        "Sometimes a player's greatest challenge is coming to grips with his role on the team.\n- Scottie Pippen",
        "The only difference between a good shot and a bad shot is if it goes in or not.\n- Charles Barkley",
        "The strength of the team is each individual member. The strength of each member is the team.\n- Phil Jackson",
        "There can only be one winner, and the rest are losers, but winners know they are winners before the results are in.\n- Pat Riley",
        "Concentration and mental toughness are the margins of victory.\n- Bill Russell",
        "My belief is stronger than your doubt.\n- Dwyane Wade",
        "Things turn out best for the people who make the best of the way things turn out.\n- John Wooden",
        "One man can be a crucial ingredient on a team, but one man cannot make a team.\n- Kareem Abdul-Jabbar",
        "They say that nobody is perfect. Then they tell you practice makes perfect. I wish they'd make up their minds.\n- Wilt Chamberlain",
        "Your biggest opponent isn't the other guy. It's human nature.\n- Derek Fisher",
        "A lot of people say they want to be great, but they're not willing to make the sacrifices necessary to achieve greatness.\n- Jason Kidd",
        "Every morning you have two choices: continue to sleep with your dreams, or wake up and chase them.\n- Carmelo Anthony",
        "Being a professional is doing the things you love to do, on the days you don't feel like doing them.\n- Julius Erving",
        "I always keep a ball in the car. You never know.\n- Hakeem Olajuwon",
        "You win by effort, by commitment, by ambition, by quality, by expressing yourself individually but in the team context.\n- Doc Rivers"
    ]

    
    // MARK: - Body
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 15) {
                    
                    // Secret message header (hidden until pulled down)
                    GeometryReader { geo in
                        let y = geo.frame(in: .named("scroll")).minY

                        // begin fading when the view is 20pt above the top,
                        // finish by the time it's 100pt into view
                        let fadeStart: CGFloat = -60
                        let fadeEnd:   CGFloat = 60
                        let raw = (y - fadeStart) / (fadeEnd - fadeStart)
                        let clamped = min(max(raw, 0), 1)

                        // optional smoothstep for an extra-soft curve
                        let eased = clamped * clamped * (3 - 2 * clamped)

                        QuoteView(raw: displayedQuote)
                            .opacity(eased)
                            .frame(height: 80)
                            .offset(y: -15)
                    }
                    .frame(height: 80)
                        
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
                .offset(y: -100)
                .padding(.horizontal)
                // Hide scroll indicators and animate changes to the sessions array.
                .scrollIndicators(.hidden)
                .animation(.smooth, value: sessions)
            }
            .coordinateSpace(name: "scroll")
            // Additional scroll settings.
            .scrollIndicators(.hidden)
            // Use the selectedDate to control scrolling (for example, when the date filter changes).
            .id(selectedDate)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .ignoresSafeArea()
            .onAppear {
                // only do this once per launch
                guard displayedQuote.isEmpty else { return }
                let next = (quoteIndex + 1) % quotes.count
                quoteIndex = next
                displayedQuote = quotes[next]
            }
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
        case "Drill": return "Run some Drills!"
        default: return "Shoot hoops!"
        }
    }
}



struct QuoteView: View {
    /// incoming string in the form
    ///    "…quote body…\n- Author Name"
    let raw: String

    private var parts: (body: String, author: String) {
        let comps = raw.components(separatedBy: "\n- ")
        let body = comps.first ?? raw
        let author = comps.dropFirst().first.map { "- " + $0 } ?? ""
        return (body, author)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("“\(parts.body)”")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(parts.author)
                .font(.caption2)
                .italic()
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.gray.opacity(0.875))
        .padding(.horizontal, 25)
        // if you still want to limit overall height, center within that:
        .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
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
    @Binding var sortMode: SortMode
    
    @AppStorage(AppSettingsKeys.dateFormat) private var dateFormat: String = "M dd, yyyy"
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        HStack {
            // A button displaying the current date.
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
            
            Spacer()
            
            // Filter menu for shot type visibility.
            FilterMenuView(shotTypeVisibility: $shotTypeVisibility)
            
            // A button (with sort/filter icon) for additional actions.
            Menu {
                Button {
                    withAnimation {
                        sortMode = .byTime
                    }
                } label: {
                    Label("Sort by Time", systemImage: sortMode == .byTime ? "checkmark" : "")
                }
                
                Button {
                    withAnimation {
                        sortMode = .byShotType
                    }
                } label: {
                    Label("Group by Shot Type", systemImage: sortMode == .byShotType ? "checkmark" : "")
                }
            } label: {
                Image(systemName: sortMode == .byTime ? "timer" : "rectangle.3.group")
                    .buttonStyle()
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                            .foregroundColor(.gray.opacity(0.25))
                    )
                    .transition(.scale.combined(with: .opacity))
                    .id(sortMode == .byTime ? "time" : "grouped")
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
                .fontWeight(.bold)
                .padding(6)
                .background(
                    ZStack {
                        if shotTypeVisibility.values.contains(true) {
                            Color.orange
                        } else {
                            Color.clear
                        }

                        if !shotTypeVisibility.values.contains(true) {
                            Color.clear.background(.ultraThinMaterial)
                        }
                    }
                )
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
        ], sortMode: .byTime,
        onSessionSelected: { }
    )
    .modelContainer(HoopSession.preview)
}
