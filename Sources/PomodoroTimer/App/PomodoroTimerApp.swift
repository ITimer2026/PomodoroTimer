import SwiftUI
import AppKit

@main
struct PomodoroTimerApp: App {
    @NSApplicationDelegateAdaptor(StatusBarController.self) var statusBar

    var body: some Scene {
        Window("History", id: "history") {
            HistoryView()
                .environment(statusBar.appState)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 420, height: 480)

        Settings {
            SettingsView()
                .environment(statusBar.appState)
        }
    }
}

final class StatusBarController: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var progressView: RingView!
    var popover: NSPopover!
    let appState = AppState()
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep app alive even when all windows are closed
        NSApp.setActivationPolicy(.accessory)
        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 340)
        popover.behavior = .transient
        let hostingView = NSHostingView(
            rootView: MenuBarContentView()
                .environment(appState)
        )
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = hostingView

        // Create status item with custom ring view
        statusItem = NSStatusBar.system.statusItem(withLength: 28)
        let ring = RingView(frame: NSRect(x: 0, y: 0, width: 22, height: 22))
        self.progressView = ring

        if let button = statusItem.button {
            button.image = nil
            button.addSubview(ring)
            ring.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                ring.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                ring.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                ring.widthAnchor.constraint(equalToConstant: 22),
                ring.heightAnchor.constraint(equalToConstant: 22),
            ])
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Update progress ring every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        tick()
    }

    private func tick() {
        progressView.progress = appState.timer.progress
        progressView.phase = appState.timer.phase
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    // Prevent app from terminating when windows close
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return .terminateNow
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

// MARK: - RingView: uses CAShapeLayer for smooth, non-flickering progress

final class RingView: NSView {
    var progress: Double = 0 {
        didSet { updateArc() }
    }
    var phase: PomodoroPhase = .work {
        didSet { updateArc() }
    }

    private let trackLayer = CAShapeLayer()
    private let arcLayer = CAShapeLayer()

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        setupLayers()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layout() {
        super.layout()
        let path = circlePath()
        trackLayer.path = path
        arcLayer.path = path
        arcLayer.frame = bounds
        trackLayer.frame = bounds
        updateArc()
    }

    private func setupLayers() {
        let lineWidth: CGFloat = 2.8

        trackLayer.fillColor = nil
        trackLayer.strokeColor = NSColor.gray.withAlphaComponent(0.35).cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineCap = .round
        layer?.addSublayer(trackLayer)

        arcLayer.fillColor = nil
        arcLayer.strokeColor = NSColor.systemRed.cgColor
        arcLayer.lineWidth = lineWidth
        arcLayer.lineCap = .round
        // Start from top (12 o'clock): rotate -90° from default 3 o'clock
        arcLayer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
        layer?.addSublayer(arcLayer)
    }

    private func updateArc() {
        let color: CGColor
        switch phase {
        case .work: color = NSColor.systemRed.cgColor
        case .shortBreak: color = NSColor.systemGreen.cgColor
        case .longBreak: color = NSColor.systemBlue.cgColor
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        arcLayer.strokeColor = color
        arcLayer.strokeEnd = CGFloat(progress)
        CATransaction.commit()
    }

    private func circlePath() -> CGPath {
        let lineWidth: CGFloat = 2.8
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        return CGPath(ellipseIn: CGRect(
            x: center.x - radius, y: center.y - radius,
            width: radius * 2, height: radius * 2
        ), transform: nil)
    }
}
