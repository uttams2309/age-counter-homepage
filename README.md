# Live Age Counter — Mac (Übersicht) + iOS / iPadOS / watchOS (SwiftUI)

Two implementations of the same idea, each tuned to what its platform actually allows.

```
age-counter/
├── ubersicht/age.jsx            # Mac desktop — true per-second, full Y/M/D/H/M/S
└── xcode/
    ├── Shared/                  # add BOTH files to app + widget targets
    │   ├── AgeConfig.swift      # ← set your DOB here (Swift side)
    │   └── AgeEngine.swift
    ├── App/                     # app target
    │   ├── AgeApp.swift
    │   ├── ContentView.swift    # smooth per-second age (foreground)
    │   └── AgeActivityController.swift   # iOS only
    └── Widget/                  # widget-extension target
        ├── AgeWidget.swift      # home-screen + lock-screen + watch complication
        ├── AgeLiveActivity.swift            # iOS only
        └── AgeWidgetBundle.swift
```

---

## 1. Mac (Übersicht) — the easy, fully-live one

There is no refresh budget on the desktop, so this shows the complete breakdown ticking every second.

1. Install Übersicht: `brew install --cask ubersicht` (or from tracesof.net), then launch it.
2. Open the widgets folder: Übersicht menu-bar icon → **Open Widgets Folder** (`~/Library/Application Support/Übersicht/widgets/`).
3. Copy `ubersicht/age.jsx` into that folder.
4. Edit the top of the file: set `BIRTH` (⚠️ JS months are 0-indexed — `7` means August) and `NAME`. Drag the widget anywhere via the Übersicht menu.

For an always-in-the-menu-bar alternative instead of a desktop widget, a ~50-line `NSStatusItem` + `Timer` app does the same; say the word and I'll add that target.

---

## 2. Xcode project — iOS / iPadOS / watchOS

I'm giving you source files rather than a prebuilt `.xcodeproj` on purpose: hand-authored `project.pbxproj` files are fragile and often won't open. Wiring three files into targets takes ~3 minutes and is far more robust.

### Fastest path — generate the project with XcodeGen

`xcode/project.yml` describes the whole project (app target, widget-extension target, shared-file membership, Live Activity Info.plist keys). Let a tool build a clean `.xcodeproj` from it instead of clicking through Xcode:

```bash
brew install xcodegen      # one-time
cd xcode && xcodegen       # creates Age.xcodeproj
open Age.xcodeproj         # needs full Xcode, not just Command Line Tools
```

Then set your DOB in `Shared/AgeConfig.swift` (⚠️ Swift months are **1-indexed** — September = `9`, unlike the Übersicht file), pick a signing team under **Signing & Capabilities**, choose a simulator or your iPhone, and press ⌘R. The generated `.xcodeproj` and `Info.plist` files are gitignored — re-run `xcodegen` after pulling changes. Edit `project.yml`, not the project inside Xcode.

If you'd rather wire it by hand instead, follow the manual steps below.

**Create the project**
1. Xcode → New Project → **App**. Interface SwiftUI, name e.g. `Age`. Min deployment **iOS 17 / watchOS 10 / macOS 14** (uses `containerBackground`).
2. Add a **Widget Extension** target: File → New → Target → Widget Extension. Tick **Include Live Activity** if you want the lock-screen ticker. Name it `AgeWidget`.
3. (Optional watch) Add a **watchOS App** target if you want the in-app per-second view on the wrist; the widget extension already covers complications cross-platform.

**Drop the files in**
- Delete the boilerplate `ContentView.swift` / widget files Xcode generated, then add the files from `xcode/` matching the folder names.
- `Shared/AgeConfig.swift` and `Shared/AgeEngine.swift` → in the File Inspector, tick **both** the app target and the widget-extension target under *Target Membership*. Everything else belongs to exactly one target (App/ → app, Widget/ → extension).
- Live Activities: in the **app** target's Info settings add `NSSupportsLiveActivities` = `YES`. To skip Live Activities entirely, delete `AgeLiveActivity.swift` and the `AgeLiveActivity()` line in `AgeWidgetBundle.swift`.

**Set your DOB** in `Shared/AgeConfig.swift`, build, then long-press the home/lock screen to add the widget.

---

## What each surface can actually show (and why)

| Surface | Capability | Mechanism |
|---|---|---|
| Mac / Übersicht | **Full Y/M/D/H/M/S, per second** | `setInterval` 1 s — no budget on desktop |
| App (foreground) | **Full Y/M/D/H/M/S, per second** | `TimelineView(.periodic(by: 1))` |
| Widget — snapshot | Y/M/D/H/M, updates **every minute** | 300 pre-supplied per-minute entries = no reload budget spent |
| Widget — `live` line | Ticks **every second**, but as an H:M:S stopwatch | `Text(birth, style: .timer)` self-renders |
| Widget — years line | "29 years", coarse, auto-updates | `Text(birth, style: .relative)` |
| Live Activity / Dynamic Island | Per-second H:M:S on lock screen | same `.timer` text; lasts up to ~8 h |

**The wall:** a home-screen widget or watch complication cannot re-run code every second (it gets ~40–70 refreshes/day). The self-updating timer-text views ARE rendered live by the system, but they only format *elapsed* time (H:M:S / days) — they can't render "29 years 4 months …" while also ticking seconds. So a years-precise figure that also ticks seconds exists only in the app foreground or on the Mac. The widget gets the best stock approximation: a minute-fresh precise snapshot **plus** a per-second live stopwatch line.

Want me to add the menu-bar Mac app target, or swap the widget's primary number to "total seconds lived" (which *can* tick every second cleanly)? Both are quick changes.
