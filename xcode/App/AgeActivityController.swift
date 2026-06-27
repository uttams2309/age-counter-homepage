#if os(iOS)
import ActivityKit
import Foundation

// Starts a Live Activity. The activity's timer text self-updates every second,
// so we never have to push state updates — one request and it ticks on its own.
// Requires "Supports Live Activities" = YES in the app target's Info settings.
enum AgeActivityController {
    static func start() {
        // Don't stack duplicates.
        guard Activity<AgeAttributes>.activities.isEmpty else { return }

        let attributes = AgeAttributes(birthEpoch: AgeConfig.birthDate.timeIntervalSince1970)
        let content = ActivityContent(state: AgeAttributes.ContentState(), staleDate: nil)

        do {
            _ = try Activity.request(attributes: attributes, content: content, pushType: nil)
        } catch {
            print("Live Activity request failed: \(error)")
        }
    }

    static func stopAll() {
        Task {
            for activity in Activity<AgeAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
#endif
