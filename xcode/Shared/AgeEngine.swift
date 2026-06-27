import Foundation

// Pure computation. No UI. Shared by app + widget targets.
struct AgeEngine {
    let birth: Date

    /// Full calendar breakdown at a given moment, using the user's calendar
    /// (handles leap years, varying month lengths, DST, etc.).
    func components(at now: Date = Date()) -> DateComponents {
        Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: birth,
            to: now
        )
    }

    /// Total seconds lived — use this when you want one ever-growing number.
    func totalSeconds(at now: Date = Date()) -> TimeInterval {
        now.timeIntervalSince(birth)
    }

    /// Age as decimal years, e.g. 29.123456789.
    func decimalYears(at now: Date = Date()) -> Double {
        totalSeconds(at: now) / (365.2425 * 24 * 60 * 60)
    }

    /// "29 years  4 months  12 days  05:23:11"
    func longString(at now: Date = Date()) -> String {
        let c = components(at: now)
        return String(
            format: "%d years  %d months  %d days  %02d:%02d:%02d",
            c.year ?? 0, c.month ?? 0, c.day ?? 0,
            c.hour ?? 0, c.minute ?? 0, c.second ?? 0
        )
    }

    /// Compact "29y 4m 12d  05:23" — good for small widgets.
    func compactString(at now: Date = Date()) -> String {
        let c = components(at: now)
        return String(
            format: "%dy %dm %dd  %02d:%02d",
            c.year ?? 0, c.month ?? 0, c.day ?? 0,
            c.hour ?? 0, c.minute ?? 0
        )
    }
}
