import WidgetKit
import SwiftUI

struct AgeEntry: TimelineEntry {
    let date: Date
}

struct AgeProvider: TimelineProvider {
    func placeholder(in context: Context) -> AgeEntry { AgeEntry(date: .now) }

    func getSnapshot(in context: Context, completion: @escaping (AgeEntry) -> Void) {
        completion(AgeEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AgeEntry>) -> Void) {
        // KEY TRICK: provide ONE entry per minute for the next 5 hours in a single
        // timeline. WidgetKit steps through pre-supplied entries WITHOUT spending
        // reload budget, so the precise minute-level snapshot advances "for free".
        // `.atEnd` asks for a fresh timeline once these run out.
        let now = Date()
        let entries = (0..<300).compactMap { i in
            Calendar.current.date(byAdding: .minute, value: i, to: now).map(AgeEntry.init)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct AgeWidgetView: View {
    var entry: AgeEntry
    @Environment(\.widgetFamily) private var family

    private let birth = AgeConfig.birthDate
    private var engine: AgeEngine { AgeEngine(birth: birth) }

    var body: some View {
        switch family {

        // Lock-screen inline (watch/iPhone): coarse but self-updating, zero budget.
        case .accessoryInline:
            Text(birth, style: .relative)

        // Lock-screen rectangular/circular & watch complications.
        case .accessoryRectangular, .accessoryCircular:
            VStack(alignment: .leading, spacing: 2) {
                Text(AgeConfig.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                // .timer self-renders every second (shows H:M:S elapsed).
                Text(birth, style: .timer)
                    .monospacedDigit()
                    .font(.headline)
            }

        // Home-screen systemSmall / systemMedium (and macOS desktop).
        default:
            VStack(alignment: .leading, spacing: 6) {
                Text(AgeConfig.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Precise snapshot from the per-minute timeline (no seconds, but free).
                Text(engine.compactString(at: entry.date))
                    .font(.system(.headline, design: .monospaced))
                    .monospacedDigit()

                // True per-second live element (renders as an ever-growing stopwatch).
                HStack(spacing: 4) {
                    Text("live").foregroundStyle(.secondary)
                    Text(birth, style: .timer).monospacedDigit()
                }
                .font(.system(.caption, design: .monospaced))

                // Coarse, auto-updating years.
                Text(birth, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(8)
        }
    }
}

struct AgeWidget: Widget {
    let kind = "AgeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AgeProvider()) { entry in
            AgeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Age")
        .description("Shows your live age.")
        .supportedFamilies([
            .systemSmall, .systemMedium,
            .accessoryInline, .accessoryCircular, .accessoryRectangular
        ])
    }
}
