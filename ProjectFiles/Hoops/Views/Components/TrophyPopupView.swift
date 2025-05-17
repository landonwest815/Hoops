//
//  TrophyPopupView.swift
//  Hoops
//
//  Created by Landon West on 4/10/25.
//

import SwiftUI

struct TrophyPopupView: View {
    let accolade: Accolade
    let onDismiss: () -> Void

    private var trophyLevel: TrophyLevel {
        Hoops.trophyLevel(for: accolade.value, thresholds: accolade.thresholds)
    }
    private var trophyColor: Color {
        switch trophyLevel {
        case .bronze: return .brown
        case .silver: return .gray
        case .gold:   return .yellow
        default:      return .gray.opacity(0.25)
        }
    }
    private var displayedThreshold: Int {
        switch trophyLevel {
        case .bronze: return accolade.thresholds.bronze
        case .silver: return accolade.thresholds.silver
        case .gold:   return accolade.thresholds.gold
        default:      return 0
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                HStack(spacing: 15) {
                    ZStack {
                        Image(systemName: "trophy.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 90)
                            .foregroundStyle(trophyColor)

                        Image(systemName: accolade.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25)
                            .foregroundStyle(.black.opacity(0.2))
                            .offset(y: -20)
                    }

                    Text("\(displayedThreshold)")
                        .font(.system(size: 125))
                        .fontWeight(.heavy)
                        .fontDesign(.rounded)
                        .foregroundStyle(.white.opacity(0.25))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }

                Text("Congrats, you’ve upgraded your\nAll-Time \(accolade.title) Trophy!")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(.white)

                Button {
                    withAnimation { onDismiss() }
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
            .background(Color(red: 0.125, green: 0.125, blue: 0.125))
            .cornerRadius(28)
            .shadow(radius: 20)
            .padding(.horizontal)
        }
    }
}

#Preview {
    let sample = Accolade(
        title: "Sessions",
        value: 30,
        thresholds: (bronze: 10, silver: 25, gold: 50),
        icon: "basketball.fill"
    )
    TrophyPopupView(accolade: sample) { }
}
