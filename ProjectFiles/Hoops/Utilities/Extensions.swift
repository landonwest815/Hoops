//
//  DateExtension.swift
//  Hoops
//
//  Created by Landon West on 3/8/24.
//

import Foundation
import SwiftUI



extension View {
    func sheetStyle() -> some View {
        self
            .presentationCornerRadius(32)
            .presentationBackground(.ultraThickMaterial)
            .presentationDragIndicator(.visible)
    }
}


// MARK: - Date Extensions

extension Date {
    /// Start of this day in the current calendar.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

// MARK: - Image Extensions

extension Image {
    /// 22×22 gray “icon” style.
    func iconStyle() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 22, height: 22)
            .foregroundStyle(.gray)
            .fontWeight(.semibold)
    }
    
    /// 17.5×17.5 orange “button” icon with background.
    func buttonStyle() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 17.5, height: 17.5)
            .foregroundStyle(.orange)
            .fontWeight(.semibold)
            .padding(6)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
    }
}
