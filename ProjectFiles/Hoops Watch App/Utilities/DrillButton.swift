//
//  LogMakeButton.swift
//  Hoops
//
//  Created by Landon West on 5/17/25.
//

import SwiftUI


struct DrillButton: View {
    @Binding var makes: Int
    @Binding var currentStage: Int
    let shotType: ShotType
    private var totalStages: Int { shotType.shots.count }
    let onComplete: () -> Void

    @State private var stageMakes = 0

    var body: some View {
        Button(action: logMake) {
            VStack(spacing: 5) {
                Spacer()

                HStack(spacing: 10) {
                    ForEach(0..<2, id: \.self) { idx in
                        iconView(filled: stageMakes > idx)
                    }
                }

                HStack(spacing: 10) {
                    ForEach(0..<max(0, totalStages - 2), id: \.self) { idx in
                        iconView(filled: stageMakes > idx + 2)
                    }
                }

                Spacer()

                Text(shotType.shots[currentStage - 1])
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.green)
                    .contentTransition(.numericText())
                    .padding(.bottom, 10)
            }
        }
        .tint(.green)
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 40))
        .edgesIgnoringSafeArea(.all)
    }

    private func logMake() {
        WKInterfaceDevice.current().play(.success)
        handleStageProgress()
        makes += 1
    }

    private func handleStageProgress() {
        if stageMakes < 4 {
            stageMakes += 1
        } else {
            stageMakes += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation {
                    stageMakes = 0
                    if currentStage < totalStages {
                        currentStage += 1
                    } else {
                        onComplete()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func iconView(filled: Bool) -> some View {
        Image(systemName: "basketball.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 35)
            .fontWeight(.semibold)
            .foregroundStyle(.green.opacity(filled ? 0.75 : 0.25))
            .animation(.easeIn(duration: 0.25), value: filled)
    }
}


struct LogMakeButton_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var makes = 0
        @State private var currentStage = 1

        var body: some View {
            DrillButton(
                makes: $makes,
                currentStage: $currentStage,
                shotType: .layups,
                onComplete: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
