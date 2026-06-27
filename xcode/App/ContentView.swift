import SwiftUI

struct ContentView: View {
    private let engine = AgeEngine(birth: AgeConfig.birthDate)

    var body: some View {
        // .periodic re-runs this closure every second WHILE THE APP IS FOREGROUND.
        // This is the only surface that can show a smooth, full-format per-second age.
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(spacing: 14) {
                Text(AgeConfig.displayName)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(engine.longString(at: context.date))
                    .font(.system(.title2, design: .monospaced))
                    .monospacedDigit()
                    .multilineTextAlignment(.center)

                Text(String(format: "%.9f years", engine.decimalYears(at: context.date)))
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.secondary)

                #if os(iOS)
                Button("Start Lock-Screen Live Activity") {
                    AgeActivityController.start()
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
                #endif
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
