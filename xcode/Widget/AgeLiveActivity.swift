#if os(iOS)
import ActivityKit
import WidgetKit
import SwiftUI

// Static attributes carry the DOB; ContentState is empty because the timer text
// renders itself live — no state pushes needed.
struct AgeAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {}
    var birthEpoch: Double
}

struct AgeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AgeAttributes.self) { context in
            // Lock Screen / banner presentation.
            let birth = Date(timeIntervalSince1970: context.attributes.birthEpoch)
            HStack {
                Text(AgeConfig.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(birth, style: .timer)
                    .monospacedDigit()
                    .font(.headline)
            }
            .padding()
            .activityBackgroundTint(.black.opacity(0.4))

        } dynamicIsland: { context in
            let birth = Date(timeIntervalSince1970: context.attributes.birthEpoch)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(birth, style: .timer)
                        .monospacedDigit()
                        .font(.title2)
                }
            } compactLeading: {
                Image(systemName: "hourglass")
            } compactTrailing: {
                Text(birth, style: .timer)
                    .monospacedDigit()
                    .frame(maxWidth: 64)
            } minimal: {
                Image(systemName: "hourglass")
            }
        }
    }
}
#endif
