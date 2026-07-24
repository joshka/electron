import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
  private var window: NSWindow!
  private var resultLabel: NSTextField!
  private var actionButtons: [NSButton] = []

  func applicationDidFinishLaunching(_ notification: Notification) {
    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 620, height: 300),
      styleMask: [.titled, .closable, .miniaturizable],
      backing: .buffered,
      defer: false
    )
    window.title = "NSButton Destructive Action Probe"
    window.center()

    let stack = NSStackView()
    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = 16
    stack.translatesAutoresizingMaskIntoConstraints = false

    let description = NSTextField(
      wrappingLabelWithString:
        """
        Reproduces VS Code's native order: Save, Cancel, Don't Save.
        Compare initial focus with and without hasDestructiveAction.
        """
    )
    let buttonRow = NSStackView()
    buttonRow.orientation = .horizontal
    buttonRow.spacing = 12

    let baseline = NSButton(title: "Open baseline", target: self, action: #selector(openBaseline))
    let destructive = NSButton(
      title: "Open destructive variant",
      target: self,
      action: #selector(openDestructive)
    )
    actionButtons = [baseline, destructive]
    buttonRow.addArrangedSubview(baseline)
    buttonRow.addArrangedSubview(destructive)

    resultLabel = NSTextField(labelWithString: "No response yet.")
    stack.addArrangedSubview(description)
    stack.addArrangedSubview(buttonRow)
    stack.addArrangedSubview(resultLabel)

    window.contentView?.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 28),
      stack.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: -28),
      stack.topAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: 28),
    ])

    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  @objc private func openBaseline() {
    showAlert(destructive: false)
  }

  @objc private func openDestructive() {
    showAlert(destructive: true)
  }

  private func showAlert(destructive: Bool) {
    actionButtons.forEach { $0.isEnabled = false }
    // VS Code moves Cancel to native index 1 before calling Electron.
    // AppKit presents these visually as Save, Don't Save, Cancel.
    let labels = ["Save", "Cancel", "Don't Save"]
    let variant = destructive ? "destructive" : "baseline"
    let alert = NSAlert()
    alert.alertStyle = .warning
    alert.messageText = "Do you want to save the changes you made?"
    alert.informativeText = "Your changes will be lost if you do not save them."

    for label in labels {
      alert.addButton(withTitle: label)
    }

    alert.buttons[0].keyEquivalent = "\r"
    alert.buttons[1].keyEquivalent = "\u{1b}"
    alert.buttons[2].hasDestructiveAction = destructive

    var initialFocus = "not measured"
    alert.beginSheetModal(for: window) { [weak self] response in
      let index = Int(response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue)
      let result =
        "\(variant): initial focus \(initialFocus); response \(index) (\(labels[index]))"
      self?.resultLabel.stringValue = result
      self?.actionButtons.forEach { $0.isEnabled = true }
      print(result)
    }

    DispatchQueue.main.async { [weak self] in
      if let button = alert.window.firstResponder as? NSButton {
        initialFocus = button.title
      } else {
        initialFocus = String(describing: alert.window.firstResponder)
      }

      alert.informativeText =
        """
        Your changes will be lost if you do not save them.

        Measured initial keyboard focus: \(initialFocus)
        """
      self?.resultLabel.stringValue = "\(variant): initial focus \(initialFocus); dialog open"
      print("\(variant): initial focus \(initialFocus)")
    }
  }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
