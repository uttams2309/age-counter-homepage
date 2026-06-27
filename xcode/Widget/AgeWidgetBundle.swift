import WidgetKit
import SwiftUI

@main
struct AgeWidgetBundle: WidgetBundle {
    var body: some Widget {
        AgeWidget()
        #if os(iOS)
        AgeLiveActivity()   // delete this line (and AgeLiveActivity.swift) to skip Live Activities
        #endif
    }
}
