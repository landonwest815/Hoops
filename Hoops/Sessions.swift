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
    
    @Query var sessions: [HoopSession]
    
    var body: some View {
        
        NavigationStack {
            
            // MARK: - List of Wants
                Form {
                    ForEach(sessions, id: \.self) { session in
                        // If a want is tapped, bring up its information using WantView
                        Section {
                            Text("\(session.makes)")
                            Text("\(session.length)")
//                            Text(String(session.makes))
//                            Text(session.length)
//                            NavigationLink(session.date) {
//                                SessionView(item: session)
//                            }
//                            .fontWeight(.semibold)

                        }
                    }
                    .listSectionSpacing(15)
                    .listRowSeparator(.hidden)
                }
                .toolbar() {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Image(systemName: "basketball.fill")
                            .foregroundStyle(.orange)
                    }
                }
                .navigationTitle("Sessions")
                //.onDelete(perform: delete)
            }
        
    }
}

#Preview {
    Sessions()
}
