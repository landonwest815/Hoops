//
//  Sessions.swift
//  Hoops
//
//  Created by Landon West on 1/3/24.
//

import SwiftUI
import SwiftData

struct Sessions: View {
    @Environment(\.modelContext) var context
    
    @Query(sort: \HoopSession.date, order: .reverse) var sessions: [HoopSession]
    
    @Binding var selectedShotType: ShotType
    
    @State var selectedDate = Date.now
            
    private var filteredSessions: [HoopSession] {
        if selectedShotType != .allShots {
            return sessions.filter { $0.shotType == selectedShotType }
        } else {
            return sessions
        }
    }
    
    private var groupedSessions: [(key: Date, value: [HoopSession])] {
        Dictionary(grouping: filteredSessions) { $0.date.startOfDay }
            .sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: -10) {
                
                VStack(spacing: -10) {
                    WeekView(selectedDate: $selectedDate)
                        .offset(y: -15)
                        .padding(.bottom, 5)
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(.orange)
                        .offset(y: -10)
                }
                .background(.ultraThinMaterial)
                
                
                VStack(alignment: .trailing, spacing: 0) {
                    
                    // List of sessions
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            // Date label and buttons
                            HStack {
                                Text(selectedDate, style: .date)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Button {
                                    
                                } label: {
                                    ZStack {
                                        Circle()
                                            .foregroundStyle(.clear)
                                            .frame(width: 25, height: 25)
                                            .background(.ultraThickMaterial)
                                            .clipShape(Circle())
                                        Image(systemName: "arrow.up.arrow.down")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 15)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                                        
                                Button {
                                    
                                } label: {
                                    ZStack {
                                        Circle()
                                            .foregroundStyle(.clear)
                                            .frame(width: 25, height: 25)
                                            .background(.ultraThickMaterial)
                                            .clipShape(Circle())
                                        Image(systemName: "line.3.horizontal.decrease")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 15)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                
                            }
                            .padding(.horizontal)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                    .blur(radius: phase.isIdentity ? 0 : 10)
                            }
                            
                            // Compute sessions for the selected date inside the body
                            let selectedDaySessions = groupedSessions.first(where: { $0.key == selectedDate.startOfDay })?.value ?? []

                            // Show message if there are no sessions
                            if selectedDaySessions.isEmpty {
                                VStack {
                                    Text("Go put some shots up!")
                                        .font(.subheadline)
                                        .fontWeight(.regular)
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 20)
                                }
                            } else {
                                // Filtered session list
                                ForEach(selectedDaySessions, id: \.self) { session in
                                    SessionThumbnail(
                                        date: session.date,
                                        makes: session.makes,
                                        length: session.length,
                                        average: Double(session.makes) / (Double(session.length) / 60.0),
                                        shotType: session.shotType
                                    )
                                    .onLongPressGesture {
                                        context.delete(session)
                                    }
                                    .frame(height: 75)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                            .blur(radius: phase.isIdentity ? 0 : 10)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .background(.black)
            }
            //.background(.ultraThinMaterial)
        }
        
    }
    
}

#Preview {
    @Previewable @State var shotType = ShotType.allShots
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HoopSession.self, configurations: config)
    
    let hoopSession = HoopSession(date: Date.now, makes: 5, length: 120, shotType: .threePointers)
    container.mainContext.insert(hoopSession)
    
    let hoopSession2 = HoopSession(date: Date.now, makes: 10, length: 120, shotType: .threePointers)
    container.mainContext.insert(hoopSession2)
    
    return Sessions(selectedShotType: $shotType)
        .modelContainer(container)
}
