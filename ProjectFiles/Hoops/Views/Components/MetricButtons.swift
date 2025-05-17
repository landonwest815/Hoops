//
//  MetricButtonVariant.swift
//  Hoops
//
//  Created by Landon West on 4/10/25.
//

import SwiftUI
import SwiftData

/// Represents the layout variants available for a MetricButton.
/// - `compact`: A button with a fixed maximum width.
/// - `expanded`: A button that takes the full available width.
enum MetricButtonVariant {
    case compact
    case expanded
}

/// A customizable button view used for displaying a metric (such as sessions, makes, average, etc.).
/// The button shows an icon, a primary numeric value, and a title. It also supports a "selected" state.
struct MetricButton: View {
    // MARK: - Properties
    
    /// The system icon name to display.
    let icon: String
    /// The title describing the metric.
    let title: String
    /// The metric value to display as text.
    let value: String
    /// The color used for the icon and any accent styling.
    let color: Color
    /// A Boolean indicating if the button is currently selected.
    let isSelected: Bool
    /// The layout variant used to determine the maximum width of the button.
    let variant: MetricButtonVariant
    /// The action to perform when the button is pressed.
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            // Arrange the icon, value, and title vertically.
            VStack(alignment: .leading, spacing: 2.5) {
                // Top row: Icon and value.
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
                
                // Bottom row: Title text.
                Text(title)
                    .font(.caption)
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            // Set maximum width based on the variant.
            .frame(maxWidth: variant == .compact ? 105 : .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            // If selected, overlay a highlighted border.
            .overlay(
                isSelected ? RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.66), lineWidth: 2.5)
                : nil
            )
        }
        // Outer overlay to provide a uniform border style.
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
    ) {
        // Preview action (placeholder)
    }
}
