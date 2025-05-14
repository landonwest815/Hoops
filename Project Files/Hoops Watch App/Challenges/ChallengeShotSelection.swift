import SwiftUI

struct ChallengeShotSelection: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(ShotType.allCases, id: \.self) { type in
                    NavigationLink(destination: ChallengeDurationSelection(shotType: type)) {
                        Text(type.rawValue.capitalized)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        WKInterfaceDevice.current().play(.click)
                    })
                    .tint(color(for: type))
                }
            }
            .navigationTitle("Choose Shot Type")
        }
    }
    
    func color(for type: ShotType) -> Color {
        switch type {
        case .layups: return .red
        case .freeThrows: return .blue
        case .midrange: return .blue
        case .threePointers: return .green
        case .deep: return .purple
        case .allShots: return .orange
        }
    }
}
