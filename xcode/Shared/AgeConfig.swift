import Foundation

// Shared by the app target AND the widget-extension target.
// In Xcode, select this file and tick BOTH targets under "Target Membership".
enum AgeConfig {

    /// Your date of birth. Year/month/day are required; hour/minute are optional
    /// but make the second-level ticking exact.
    static let birthDate: Date = {
        var c = DateComponents()
        c.year = 1996
        c.month = 8
        c.day = 15
        c.hour = 6      // birth time, if known
        c.minute = 30
        return Calendar.current.date(from: c) ?? .distantPast
    }()

    static let displayName = "My Age"
}
