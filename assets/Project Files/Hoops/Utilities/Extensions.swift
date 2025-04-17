//
//  DateExtension.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import Foundation
import SwiftUI

// MARK: - Date Extensions

extension Date {
    /// Returns the start of the day for the date using the current calendar.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

// MARK: - Image Extensions

extension Image {
    /// Applies a consistent "icon" style to the image.
    /// The image is made resizable, set to a 22x22 frame, and styled with a gray color and semibold weight.
    func iconStyle() -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 22, height: 22)
            .foregroundStyle(.gray)
            .fontWeight(.semibold)
    }
    
    /// Applies a consistent "button" style to the image.
    /// The image is made resizable, set to a 17.5x17.5 frame, styled with an orange tint, padded, and given a rounded background.
    func buttonStyle() -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 17.5, height: 17.5)
            .foregroundStyle(.orange)
            .fontWeight(.semibold)
            .padding(6)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
    }
}
