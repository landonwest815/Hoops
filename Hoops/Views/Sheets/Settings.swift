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
    
    @Query var userSettingsArray: [UserSettings]
    
    @State private var showConfirmation = false

    // UI
    var body: some View {
        
        NavigationStack {
            
            Form {
                Section {
                    HStack {

                        Text("Version")
                            .foregroundColor(.white)

                        Spacer()
                        
                        Text("1.0")
                            .foregroundColor(.white)

                    }
                    HStack {

                        Text("Developer")
                            .foregroundColor(.white)

                        Spacer()
                        
                        Text("Landon West")
                            .foregroundColor(.white)

                    }
                }
                header: {
                    Text("Developer Info")
                }
                
                Section {
                    Button {
                        showConfirmation = true
                    } label: {
                        Text("Reset Data")
                            .foregroundColor(.red)
                    }
                    .confirmationDialog("Delete data?", isPresented: $showConfirmation) {
                        Button("Delete everything!", role: .destructive, action: {
                                do {
                                    try context.delete(model: HoopSession.self)
                                    try context.delete(model: UserSettings.self)
                                } catch {
                                    print("Failed to clear all data.")
                                }
                        })
                        
                        // This button overrides the default Cancel button.
                        Button("Mmm.. nevermind", role: .cancel, action: {})
                    }
                    message: {
                        Text("Careful! This action is permanent and cannot be undone.")
                    }
                }
                header: {
                    Text("Data")
                }
            }
            .toolbar() {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Image(systemName: "gear")
                        .foregroundStyle(.orange)
                        .fontWeight(.heavy)
                }
            }
            .navigationTitle("Settings")
        }
        .onAppear() {
            pullFromUserSettings()
        }
    }
    
    private func pullFromUserSettings() {
        //if let userSettings = userSettingsArray.first {
            // do stuff
        //}
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
       let container = try! ModelContainer(for: HoopSession.self, UserSettings.self, configurations: config)
    let userSettings = UserSettings()
    container.mainContext.insert(userSettings)

    return Settings()
           .modelContainer(container)
}
