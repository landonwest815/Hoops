import SwiftUI

struct ChallengeShotSelection: View {
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
//            NavigationLink(value: AppRoute.challengeDurationSelection(.layups)) {
//                Text("Layups")
//            }
//            .hapticNavLinkStyle()
//            .tint(.red)
//
//            NavigationLink(value: AppRoute.challengeDurationSelection(.freeThrows)) {
//                Text("Free Throws")
//            }
//            .hapticNavLinkStyle()
//            .tint(.blue)
//
//            NavigationLink(value: AppRoute.challengeDurationSelection(.midrange)) {
//                Text("Midrange")
//            }
//            .hapticNavLinkStyle()
//            .tint(.orange)
//
//            NavigationLink(value: AppRoute.challengeDurationSelection(.threePointers)) {
//                Text("Threes")
//            }
//            .hapticNavLinkStyle()
//            .tint(.green)
//
//            NavigationLink(value: AppRoute.challengeDurationSelection(.deep)) {
//                Text("Deep")
//            }
//            .hapticNavLinkStyle()
//            .tint(.purple)
        }
        .navigationTitle("Shot Type")
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
