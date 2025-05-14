import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Query(sort: \HoopSession.date, order: .reverse) var sessions: [HoopSession]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
               
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            Color.clear.frame(height: 1) // spacer for smooth scroll
                            
                            ForEach(sessions, id: \.id) { session in
                                SessionThumbnail(
                                    date: session.date,
                                    makes: session.makes,
                                    length: session.length,
                                    average: Double(session.makes) / (Double(session.length) / 60.0),
                                    shotType: session.shotType
                                )
                                .frame(height: 75)
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.25)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                }
                            }
                            
                            Spacer(minLength: 200)
                        }
                        .scrollIndicators(.hidden)
                        .padding(.horizontal)
                    }
                }
                
                
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 35, height: 35)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.gray.opacity(0.25), lineWidth: 1)
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.top, 25)
                
                
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
}
