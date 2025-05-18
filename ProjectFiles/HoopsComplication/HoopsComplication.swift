import WidgetKit
import SwiftUI

// 1) Your entry only needs a date
struct SimpleEntry: TimelineEntry {
    let date: Date
}

// 2) Make Provider conform to TimelineProvider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        // Just one entry, refresh never
        let entry = SimpleEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

@main
struct HoopsComplication: Widget {
    let kind = "HoopsComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ComplicationView()
                .widgetAccentable()
                .widgetURL(URL(string: "hoops://modeSelection")!)
                // ← add this:
                .containerBackground(for: .widget) {
                    // you can pick any color or material here
                    Color.clear
                }
        }
        .configurationDisplayName("Quick Start")
        .description("Tap to jump straight into mode selection.")
        .supportedFamilies([.accessoryCircular])
    }
}
