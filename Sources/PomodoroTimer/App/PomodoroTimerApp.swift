import SwiftUI
import AppKit

@main
struct PomodoroTimerApp: App {
    @NSApplicationDelegateAdaptor(StatusBarController.self) var statusBar

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class StatusBarController: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var progressView: RingView!
    var popover: NSPopover!
    var standaloneController: StandaloneWindowController?
    var statusMenu: NSMenu?
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
            rootView: MenuBarContentView(onOpenStandalone: { [weak self] in
                self?.openStandaloneWindow()
            })
            .environment(appState)
        )
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = hostingView

        // Create status item with custom ring view
        statusItem = NSStatusBar.system.statusItem(withLength: 28)
        let ring = RingView(frame: NSRect(x: 0, y: 0, width: 22, height: 22))
        self.progressView = ring

        // Right-click menu (button.menu alone is ignored when button.action is set)
        let menu = NSMenu()
        menu.addItem(withTitle: "退出", action: #selector(quitApp), keyEquivalent: "q")
        for item in menu.items {
            item.target = self
        }
        self.statusMenu = menu

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
            button.action = #selector(statusBarClicked(_:))
            button.target = self
            // Listen for both left and right mouse up
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
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

    @objc private func statusBarClicked(_ sender: AnyObject?) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            showStatusMenu()
            return
        }
        togglePopover(sender)
    }

    private func showStatusMenu() {
        guard let button = statusItem.button, let menu = statusMenu else { return }
        let point = NSPoint(x: 0, y: button.frame.maxY + 4)
        menu.popUp(positioning: nil, at: point, in: button)
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    private func openStandaloneWindow() {
        if standaloneController == nil {
            standaloneController = StandaloneWindowController(appState: appState)
        }
        popover.performClose(nil)
        standaloneController?.show()
    }

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
        arcLayer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
        layer?.addSublayer(arcLayer)
    }

    private func updateArc() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        arcLayer.strokeColor = NSColor.systemRed.cgColor
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
