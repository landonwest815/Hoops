//
//  SessionListView.swift
//  Hoops
//
//  Created by Landon West on 4/10/25.
//

import SwiftUI
import SwiftData

struct SessionListView: View {
    let sessions: [HoopSession]
    let context: ModelContext
    @Binding var selectedSession: HoopSession
    @Binding var selectedDate: Date
    let shotTypeVisibility: [ShotType: Bool]
    let sortMode: SortMode
    let onSessionSelected: () -> Void

    @State private var sessionToDelete: HoopSession?
    @State private var showConfirmDelete = false
    private let sessionTypes = ["Freestyle", "Challenge", "Drill"]

    private var filteredSessionsForDay: [HoopSession] {
        sessions.filter { $0.date.startOfDay == selectedDate.startOfDay }
    }

    private var groupedSessions: [String: [HoopSession]] {
        let base = filteredSessionsForDay
        let allOff = shotTypeVisibility.values.allSatisfy { !$0 }
        let filtered = allOff
            ? base
            : base.filter { shotTypeVisibility[$0.shotType] == true }

        var grouped = Dictionary(grouping: filtered) { $0.sessionType.rawValue }
        for type in sessionTypes where grouped[type] == nil {
            grouped[type] = []
        }

        for type in grouped.keys {
            switch sortMode {
            case .byTime:
                grouped[type]?.sort { $0.date > $1.date }
            case .byShotType:
                let order: [ShotType] = [.layups, .freeThrows, .midrange, .threePointers, .deep, .allShots]
                grouped[type]?.sort {
                    order.firstIndex(of: $0.shotType)! < order.firstIndex(of: $1.shotType)!
                }
            }
        }
        return grouped
    }

    @AppStorage("quoteIndex") private var quoteIndex = -1
    @State private var displayedQuote = "I've missed more than 9,000 shots in my career. I've lost almost 300 games. Twenty-six times, I've been trusted to take the game-winning shot and missed. I've failed over and over and over again in my life. And that is why I succeed.\n- Michael Jordan"
    
    private let quotes: [String] = [
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

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 15) {
                    GeometryReader { geo in
                        let y = geo.frame(in: .named("scroll")).minY
                        let start: CGFloat = -60, end: CGFloat = 60
                        let raw = (y - start) / (end - start)
                        let eased = min(max(raw, 0), 1)
                        QuoteView(raw: displayedQuote)
                            .opacity(eased * eased * (3 - 2 * eased))
                            .frame(height: 80)
                            .offset(y: -15)
                    }
                    .frame(height: 80)

                    Color.clear.frame(height: 1)

                    ForEach(sessionTypes, id: \.self) { type in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: iconName(for: type))
                                Text(type)
                                Spacer()
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 15)
                            .padding(.top, 5)
                            .scrollTransition { content, phase in
                                content.opacity(phase.isIdentity ? 1 : 0)
                            }

                            if let list = groupedSessions[type], !list.isEmpty {
                                ForEach(list, id: \.id) { session in
                                    SessionThumbnail(
                                        date: session.date,
                                        makes: session.makes,
                                        length: session.length,
                                        average: Double(session.makes) / (Double(session.length) / 60),
                                        shotType: session.shotType
                                    )
                                    .transition(.identity)
                                    .contextMenu {
                                        Button {
                                            selectedSession = session
                                            onSessionSelected()
                                        } label: {
                                            Label("Edit Session", systemImage: "pencil")
                                        }
                                        Button(role: .destructive) {
                                            sessionToDelete = session
                                            showConfirmDelete = true
                                        } label: {
                                            Label("Delete Session", systemImage: "trash")
                                        }
                                    }
                                    .onTapGesture {
                                        selectedSession = session
                                        onSessionSelected()
                                    }
                                    .frame(height: 75)
                                    .id(session.id)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0.25)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                    }
                                }
                            } else {
                                PlaceholderThumbnail(prompt: promptText(for: type))
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0.25)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                    }
                            }
                        }
                    }

                    Spacer(minLength: 200)
                }
                .offset(y: -100)
                .padding(.horizontal)
                .scrollIndicators(.hidden)
                .animation(.smooth, value: sessions)
            }
            .coordinateSpace(name: "scroll")
            .id(selectedDate)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .ignoresSafeArea()
        }
        .onAppear {
            guard displayedQuote.isEmpty else { return }
            let next = (quoteIndex + 1) % quotes.count
            quoteIndex = next
            displayedQuote = quotes[next]
        }
        .confirmationDialog(
            "Are you sure you want to delete this session?",
            isPresented: $showConfirmDelete,
            titleVisibility: .visible
        ) {
            if let session = sessionToDelete {
                Button("Delete", role: .destructive) {
                    withAnimation { context.delete(session) }
                    sessionToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                sessionToDelete = nil
            }
        }
    }

    private func iconName(for type: String) -> String {
        switch type {
        case "Freestyle": return "figure.cooldown"
        case "Challenge": return "figure.bowling"
        case "Drill": return "figure.basketball"
        default: return "questionmark.circle"
        }
    }

    private func promptText(for type: String) -> String {
        switch type {
        case "Freestyle": return "Shoot hoops!"
        case "Challenge": return "Challenge yourself!"
        case "Drill": return "Run some drills!"
        default: return "Shoot hoops!"
        }
    }
}

struct QuoteView: View {
    let raw: String

    private var parts: (body: String, author: String) {
        // Split on newline-dash-space so we keep the author prefix intact
        let comps = raw.components(separatedBy: "\n- ")
        let body = comps.first ?? raw
        // If there’s an author piece, re-prepend the “- ”
        let author = comps.count > 1 ? "- " + comps[1] : ""
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
        .frame(maxWidth: .infinity, minHeight: 60)
    }
}


struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
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
        .padding(.horizontal, 25)
        .padding(.bottom)
    }
}

struct HeaderView: View {
    @Binding var shotTypeVisibility: [ShotType: Bool]
    @Binding var selectedDate: Date
    @Binding var sortMode: SortMode

    @AppStorage(AppSettingsKeys.dateFormat) private var dateFormat = "MMM d, yyyy"

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        HStack {
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
            .contentTransition(.numericText())
            .frame(height: 20)
            .padding(.leading, 5)

            Spacer()

            FilterMenuView(shotTypeVisibility: $shotTypeVisibility)

            Menu {
                Button {
                    withAnimation { sortMode = .byTime }
                } label: {
                    Label("Sort by Time", systemImage: sortMode == .byTime ? "checkmark" : "")
                }
                Button {
                    withAnimation { sortMode = .byShotType }
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

struct FilterMenuView: View {
    @Binding var shotTypeVisibility: [ShotType: Bool]

    var body: some View {
        Menu {
            Button {
                withAnimation {
                    for key in shotTypeVisibility.keys {
                        shotTypeVisibility[key] = false
                    }
                }
            } label: {
                Label("All Shots", systemImage: shotTypeVisibility.values.contains(true) ? "" : "checkmark")
            }
            Divider()
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
            Image(systemName: "line.3.horizontal.decrease")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 17.5, height: 17.5)
                .fontWeight(.bold)
                .foregroundStyle(shotTypeVisibility.values.contains(true) ? .black.opacity(0.875) : .orange)
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
    @Previewable @State var selectedSession = HoopSession(date: .now, makes: 0, length: 0, shotType: .allShots)
    SessionListView(
        sessions: [],
        context: HoopSession.preview.mainContext,
        selectedSession: $selectedSession,
        selectedDate: .constant(.now),
        shotTypeVisibility: ShotType.allCases.reduce(into: [:]) { $0[$1] = false },
        sortMode: .byTime,
        onSessionSelected: {}
    )
    .modelContainer(HoopSession.preview)
}
