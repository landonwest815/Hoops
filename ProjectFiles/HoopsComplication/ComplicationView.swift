//
//  ComplicationView.swift
//  Hoops
//
//  Created by Landon West on 5/18/25.
//

import SwiftUI
import WidgetKit

struct ComplicationView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    var body: some View {
            Image("curved")
              .renderingMode(.template)
              .resizable()
              .scaledToFit()
              .foregroundColor(.accentColor)
        
    }
}
