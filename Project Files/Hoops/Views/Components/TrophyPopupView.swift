//
//  TrophyPopupView.swift
//  Hoops
//
//  Created by Landon West on 4/10/25.
//

import SwiftUI
import SwiftData

/// A popup view that congratulates the user for upgrading a trophy.
/// It displays the unlocked threshold and uses decorative graphics based on the trophy level.
struct TrophyPopupView: View {
    // MARK: - Properties
    /// The accolade (trophy) being displayed.
    let accolade: Accolade
    /// Callback to call when the popup is dismissed.
    let onDismiss: () -> Void

    // MARK: - Trophy Level & Appearance

    /// Computes the trophy level for the accolade using your business logic.
    var trophyLevel: TrophyLevel {
        Hoops.trophyLevel(for: accolade.value, thresholds: accolade.thresholds)
    }
    
    /// Maps the trophy level to a display color.
    var trophyColor: Color {
        switch trophyLevel {
        case .bronze:
            return .brown
        case .silver:
            return .gray
        case .gold:
            return .yellow
        default:
            return .gray.opacity(0.25)
        }
    }
    
    /// Determines the threshold value to display based on the trophy level unlocked.
    var displayedThreshold: Int {
        switch trophyLevel {
        case .bronze:
            return accolade.thresholds.bronze
        case .silver:
            return accolade.thresholds.silver
        case .gold:
            return accolade.thresholds.gold
        default:
            return 0
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Dimmed background covering the entire screen.
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            // Popup card that displays trophy information.
            VStack(spacing: 20) {
                // Top row: Trophy graphic and the unlocked threshold.
                HStack(spacing: 15) {
                    ZStack {
                        // Main trophy icon with a resizable style.
                        Image(systemName: "trophy.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 90)
                            .foregroundStyle(trophyColor)
                        
                        // Overlay the accolade's own icon for extra detail.
                        Image(systemName: accolade.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25)
                            .foregroundStyle(.black.opacity(0.2))
                            .offset(y: -20)
                    }
                    
                    // Display the threshold value that was unlocked.
                    Text(String(displayedThreshold))
                        .font(.system(size: 125))
                        .fontWeight(.heavy)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white.opacity(0.25))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                
                // Congratulatory message.
                Text("Congrats, you’ve upgraded your\nAll-Time \(accolade.title) Trophy!")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Dismiss button.
                Button {
                    withAnimation {
                        onDismiss()
                    }
                } label: {
                    Text("Awesome")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(trophyColor)
                        .cornerRadius(18)
                        .foregroundColor(trophyLevel == .gold ? .black : .white)
                }
            }
            .padding(30)
            // Popup card background color.
            .background(Color(red: 0.125, green: 0.125, blue: 0.125))
            .cornerRadius(28)
            .shadow(radius: 20)
            .padding(.horizontal)
        }
    }
}

#Preview {
    // For preview purposes, create a sample Accolade.
    let sampleAccolade = Accolade(
        title: "Sessions",
        value: 30,
        thresholds: (bronze: 10, silver: 25, gold: 50),
        icon: "basketball.fill"
    )
    
    TrophyPopupView(accolade: sampleAccolade, onDismiss: { })
}
