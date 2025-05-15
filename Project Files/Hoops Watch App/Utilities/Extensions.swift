//
//  Extensions.swift
//  Hoops
//
//  Created by Landon West on 5/14/25.
//
import SwiftUI
import Combine

extension View {
    func hapticNavLinkStyle() -> some View {
        self.simultaneousGesture(TapGesture().onEnded {
            WKInterfaceDevice.current().play(.click)
        })
    }
}

struct TimeFormatter {
    static func format(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

class SessionTimer: ObservableObject {
    @Published var elapsedTime: Int = 0
    private var startTime: Date?
    private var timer: AnyCancellable?

    func start() {
        startTime = Date()
        elapsedTime = 0
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            guard let start = self.startTime else { return }
            self.elapsedTime = Int(Date().timeIntervalSince(start))
        }
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }
}

struct UIConstants {
    static let ballIconSize: CGFloat = 250
}
