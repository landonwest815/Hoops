//
//  MetricButtonVariant.swift
//  Hoops
//
//  Created by Landon West on 4/10/25.
//

import SwiftUI

enum MetricButtonVariant {
    case compact, expanded
}

struct MetricButton: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let isSelected: Bool
    let variant: MetricButtonVariant
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2.5) {
                HStack {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 16)
                        .foregroundStyle(color)
                        .fontWeight(.semibold)

                    Text(value)
                        .font(.title3)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .contentTransition(.numericText())
                        .foregroundStyle(.white)
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .frame(maxWidth: variant == .compact ? 105 : .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .overlay(
                isSelected
                    ? RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.66), lineWidth: 2.5)
                    : nil
            )
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundColor(.gray.opacity(0.25))
        )
    }
}

#Preview {
    MetricButton(
        icon: "basketball.fill",
        title: "Total Makes",
        value: "7",
        color: .orange,
        isSelected: false,
        variant: .compact
    ) { }
}
