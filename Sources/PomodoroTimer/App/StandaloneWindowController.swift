import SwiftUI
import AppKit

final class StandaloneWindowController: NSWindowController, NSWindowDelegate {
    private var isPinned: Bool = true
    private static let positionKey = "StandaloneWindowPosition"

    init(appState: AppState) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 160, height: 56),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.isMovableByWindowBackground = true
        window.hasShadow = true
        window.backgroundColor = .clear
        window.level = .floating
        window.contentView?.postsBoundsChangedNotifications = true

        // Position: restore saved, or default to top-right
        if let saved = UserDefaults.standard.string(forKey: Self.positionKey) {
            let point = NSPointFromString(saved)
            window.setFrameOrigin(point)
        } else if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.maxX - 180
            let y = screenFrame.maxY - 50
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }

        let host = NSHostingView(
            rootView: StandaloneWindowHost(appState: appState, isPinned: { [weak window] in
                window?.level == .floating
            }, setPinned: { [weak window] pinned in
                window?.level = pinned ? .floating : .normal
            }, onClose: { [weak window] in
                window?.orderOut(nil)
            })
        )
        host.autoresizingMask = [.width, .height]
        window.contentView = host
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.6).cgColor
        window.contentView?.layer?.cornerRadius = 12
        window.contentView?.layer?.cornerCurve = .continuous

        super.init(window: window)
        window.delegate = self
    }

    required init?(coder: NSCoder) { fatalError() }

    func show() {
        guard let window = self.window else { return }
        if !window.isVisible {
            window.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowDidMove(_ notification: Notification) {
        guard let window = self.window else { return }
        let origin = window.frame.origin
        UserDefaults.standard.set(NSStringFromPoint(origin), forKey: Self.positionKey)
    }
}

/// Bridges the SwiftUI view with the parent NSWindow for pin-state control.
struct StandaloneWindowHost: View {
    let appState: AppState
    let isPinned: () -> Bool
    let setPinned: (Bool) -> Void
    let onClose: () -> Void

    @State private var pinned: Bool = true

    var body: some View {
        StandaloneWindowView(isPinned: $pinned, onClose: onClose)
            .environment(appState)
            .onChange(of: pinned) { _, newValue in
                setPinned(newValue)
            }
            .onAppear {
                pinned = isPinned()
            }
    }
}
