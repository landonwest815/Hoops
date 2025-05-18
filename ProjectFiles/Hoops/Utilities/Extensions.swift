import SwiftUI

extension View {
    func sheetStyle() -> some View {
        presentationCornerRadius(32)
            .presentationBackground(.ultraThickMaterial)
            .presentationDragIndicator(.visible)
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension Image {
    func iconStyle() -> some View {
        resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 22, height: 22)
            .foregroundStyle(.gray)
            .fontWeight(.semibold)
    }

    func buttonStyle() -> some View {
        resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 17.5, height: 17.5)
            .foregroundStyle(.orange)
            .fontWeight(.semibold)
            .padding(6)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
    }
}

extension UIScreen {
  static var isShortScreen: Bool {
    UIScreen.main.bounds.height <= 667
  }
}
