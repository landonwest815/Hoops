//
//  SelectionList.swift
//  Hoops
//
//  Created by Landon West on 5/14/25.
//

import SwiftUI

struct SelectionList<Item: Hashable>: View {
    let title: String
    let items: [Item]
    let label: (Item) -> String
    let tint: (Item) -> Color
    let destination: (Item) -> AppRoute
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            ForEach(items, id: \.self) { item in
                NavigationLink(value: destination(item)) {
                    Text(label(item))
                }
                .hapticNavLinkStyle()
                .tint(tint(item))
            }
        }
        .navigationTitle(title)
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    SelectionList(
        title: "Shot Type",
        items: ShotType.allCases,
        label: { $0.displayName },
        tint: { $0.color },
        destination: { shot in
            .session(mode: .freestyle, shot: shot, duration: nil)
        },
        path: $path
    )
}
