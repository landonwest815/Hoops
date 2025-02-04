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
//        if selectedShotType != .allShots {
//            return sessions.filter { $0.shotType == selectedShotType }
//        } else {
            return sessions
        //}
    }
    
    private var totalMakes: Int {
        filteredSessions.reduce(0) { $0 + $1.makes }
    }

    private var totalTime: Int {
        filteredSessions.reduce(0) { $0 + $1.length } // Duration is in minutes
    }

    private var averageMakes: Double {
        guard !filteredSessions.isEmpty else { return 0 }
        return Double(totalMakes) / Double(filteredSessions.count)
    }

    private var averageMakesPerMinute: Double {
        guard totalTime > 0 else { return 0 }
        return Double(totalMakes) / Double(totalTime) // No need to divide by 60 since time is already in minutes
    }
    
    private var groupedSessions: [(key: Date, value: [HoopSession])] {
        Dictionary(grouping: filteredSessions) { $0.date.startOfDay }
            .sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
                
//                CardView()
//                    .padding(.bottom)
//                    .frame(maxWidth: .infinity)
//                    .background(.ultraThinMaterial)
                
            ZStack(alignment: .top) {
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        
                        // List of sessions
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                
                                HStack(spacing: 15) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "basketball.fill")
                                                .foregroundStyle(.orange)
                                                .fontWeight(.semibold)
                                            
                                            Text("\(filteredSessions.count)")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        Text("Sessions")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .fontDesign(.rounded)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Divider()
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "scope")
                                                .foregroundStyle(.red)
                                                .fontWeight(.semibold)
                                            
                                            Text("\(totalMakes)")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                        }
                                        
                                        Text("Total Makes")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .fontDesign(.rounded)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Divider()
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "chart.line.uptrend.xyaxis")
                                                .foregroundStyle(.blue)
                                                .fontWeight(.semibold)
                                            
                                            HStack(spacing: 5) {
                                                Text("\(averageMakesPerMinute)")
                                                    .font(.title3)
                                                    .fontDesign(.rounded)
                                                    .fontWeight(.semibold)
                                                
                                                Text("/min")
                                                    .font(.subheadline)
                                                    .fontDesign(.rounded)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        
                                        Text("Average Makes")
                                            .font(.subheadline)
                                            .fontWeight(.regular)
                                            .fontDesign(.rounded)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                        .blur(radius: phase.isIdentity ? 0 : 10)
                                }
                                .padding(.top)
                                
                                // Date label and buttons
                                HStack {
                                    Text(selectedDate, style: .date)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                    
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
                                .padding(.top)
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
                    .padding(.top, 90)
                    
                    VStack(spacing: 0) {
                        WeekView(selectedDate: $selectedDate)
                            .padding(.top, 5)
                        
                        Divider()
                            .frame(height: 1)
                            .overlay(.orange.opacity(0.66))
                            .shadow(color: .orange.opacity(0.66), radius: 5, y: 1.5)
                            .shadow(color: .orange.opacity(0.66), radius: 5, y: 1.5)
                            .shadow(color: .orange.opacity(0.66), radius: 5, y: 1.5)

                    }
                    .background(.ultraThinMaterial)
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
